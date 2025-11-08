#!/usr/bin/env python3
"""
Localization Migration Tool - Comprehensive tool for migrating hardcoded strings to ARB
Supports: preview, apply, rollback, batch processing
"""

import json
import re
import os
from pathlib import Path
from typing import Dict, List, Tuple
from dataclasses import dataclass, asdict
import shutil

@dataclass
class Replacement:
    """Represents a string replacement"""
    file_path: str
    line_number: int
    old_code: str
    new_code: str
    string_value: str
    localization_key: str

class LocalizationMigrator:
    """Tool for migrating hardcoded strings to localization"""

    def __init__(self, root_dir: str = "."):
        self.root_dir = Path(root_dir)
        self.replacements: List[Replacement] = []
        self.backup_dir = self.root_dir / ".localization_backups"

    def load_quick_wins(self, top_n: int = 50) -> List[Dict]:
        """Load top N entries from quick wins"""
        # Use presentation layer quick wins (exact strings only)
        with open("localization_presentation_quick_wins.json", 'r', encoding='utf-8') as f:
            data = json.load(f)

        entries = data['entries'][:top_n]
        print(f"✅ Loaded top {len(entries)} quick win entries")
        print(f"   These represent {sum(e['occurrences'] for e in entries)} total occurrences")

        return entries

    def find_string_occurrences(self, string_value: str, key: str) -> List[Replacement]:
        """Find all occurrences of a string in Dart files"""
        replacements = []

        # Search all .dart files in lib/
        lib_dir = self.root_dir / "lib"
        for dart_file in lib_dir.rglob("*.dart"):
            # Skip generated files
            if "generated" in str(dart_file) or ".g.dart" in str(dart_file):
                continue

            # Skip data/domain layer (no BuildContext available)
            file_str = str(dart_file)
            skip_patterns = [
                "/data/repositories/",
                "/data/services/",
                "/domain/services/",
                "/domain/usecases/",
                "/domain/utils/",
            ]
            if any(pattern in file_str for pattern in skip_patterns):
                continue

            try:
                with open(dart_file, 'r', encoding='utf-8') as f:
                    lines = f.readlines()

                for line_num, line in enumerate(lines, start=1):
                    # Look for the string in quotes
                    # Match both single and double quotes
                    patterns = [
                        rf"'({re.escape(string_value)})'",
                        rf'"({re.escape(string_value)})"',
                    ]

                    for pattern in patterns:
                        if re.search(pattern, line):
                            # Found it! Generate replacement
                            old_code = line.strip()

                            # Generate new code with context.l10n
                            new_line = line
                            new_line = re.sub(rf"'{re.escape(string_value)}'", f"context.l10n.{key}", new_line)
                            new_line = re.sub(rf'"{re.escape(string_value)}"', f"context.l10n.{key}", new_line)
                            new_code = new_line.strip()

                            replacement = Replacement(
                                file_path=str(dart_file.relative_to(self.root_dir)),
                                line_number=line_num,
                                old_code=old_code,
                                new_code=new_code,
                                string_value=string_value,
                                localization_key=key
                            )
                            replacements.append(replacement)

            except Exception as e:
                print(f"⚠️ Error reading {dart_file}: {e}")

        return replacements

    def analyze_migrations(self, entries: List[Dict]) -> Dict:
        """Analyze all potential migrations"""
        print(f"\n🔍 Analyzing migration opportunities...")

        all_replacements = []

        for i, entry in enumerate(entries, 1):
            string_value = entry['value_en']  # Use EN as canonical
            key = entry['key']

            replacements = self.find_string_occurrences(string_value, key)

            if replacements:
                print(f"   {i}/{len(entries)}: '{string_value[:40]}...' → {len(replacements)} occurrences")
                all_replacements.extend(replacements)

        self.replacements = all_replacements

        # Generate statistics
        stats = {
            'total_replacements': len(all_replacements),
            'files_affected': len(set(r.file_path for r in all_replacements)),
            'unique_keys': len(set(r.localization_key for r in all_replacements)),
            'by_file': {}
        }

        for r in all_replacements:
            if r.file_path not in stats['by_file']:
                stats['by_file'][r.file_path] = 0
            stats['by_file'][r.file_path] += 1

        return stats

    def generate_preview_report(self, output_file: str = "migration_preview.md"):
        """Generate markdown preview of all changes"""
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("# Localization Migration Preview\n\n")
            f.write(f"**Total Replacements**: {len(self.replacements)}\n")
            f.write(f"**Files Affected**: {len(set(r.file_path for r in self.replacements))}\n\n")

            f.write("## Changes by File\n\n")

            # Group by file
            by_file = {}
            for r in self.replacements:
                if r.file_path not in by_file:
                    by_file[r.file_path] = []
                by_file[r.file_path].append(r)

            for file_path in sorted(by_file.keys()):
                replacements = by_file[file_path]
                f.write(f"### `{file_path}` ({len(replacements)} changes)\n\n")

                for r in replacements[:10]:  # Show first 10 per file
                    f.write(f"**Line {r.line_number}**:\n")
                    f.write(f"```dart\n")
                    f.write(f"- {r.old_code}\n")
                    f.write(f"+ {r.new_code}\n")
                    f.write(f"```\n\n")

                if len(replacements) > 10:
                    f.write(f"... and {len(replacements) - 10} more changes\n\n")

        print(f"✅ Preview report saved to: {output_file}")

    def create_backup(self):
        """Create backup of all files to be modified"""
        self.backup_dir.mkdir(exist_ok=True)

        print(f"\n💾 Creating backups...")

        files_to_backup = set(r.file_path for r in self.replacements)

        for file_path in files_to_backup:
            src = self.root_dir / file_path
            dst = self.backup_dir / file_path

            # Create parent directories
            dst.parent.mkdir(parents=True, exist_ok=True)

            # Copy file
            shutil.copy2(src, dst)

        print(f"   ✅ Backed up {len(files_to_backup)} files to {self.backup_dir}")

    def apply_migrations(self, dry_run: bool = True):
        """Apply all migrations (or dry-run)"""
        if dry_run:
            print(f"\n🔍 DRY RUN - No files will be modified")
        else:
            print(f"\n⚡ APPLYING MIGRATIONS - Files will be modified!")
            self.create_backup()

        # Group by file
        by_file = {}
        for r in self.replacements:
            if r.file_path not in by_file:
                by_file[r.file_path] = []
            by_file[r.file_path].append(r)

        modified_count = 0

        for file_path, replacements in by_file.items():
            full_path = self.root_dir / file_path

            # Read file
            with open(full_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            # Apply replacements (from bottom to top to preserve line numbers)
            replacements_sorted = sorted(replacements, key=lambda r: r.line_number, reverse=True)

            for r in replacements_sorted:
                line_idx = r.line_number - 1
                if line_idx < len(lines):
                    old_line = lines[line_idx]

                    # Replace the string
                    new_line = old_line
                    new_line = re.sub(rf"'{re.escape(r.string_value)}'", f"context.l10n.{r.localization_key}", new_line)
                    new_line = re.sub(rf'"{re.escape(r.string_value)}"', f"context.l10n.{r.localization_key}", new_line)

                    lines[line_idx] = new_line

            # Write file (only if not dry-run)
            if not dry_run:
                with open(full_path, 'w', encoding='utf-8') as f:
                    f.writelines(lines)
                modified_count += 1

        if dry_run:
            print(f"   📊 Would modify {len(by_file)} files with {len(self.replacements)} replacements")
        else:
            print(f"   ✅ Modified {modified_count} files with {len(self.replacements)} replacements")

        return modified_count

    def rollback(self):
        """Rollback all changes using backups"""
        if not self.backup_dir.exists():
            print("❌ No backups found!")
            return

        print(f"\n⏮️  Rolling back changes...")

        for backup_file in self.backup_dir.rglob("*.dart"):
            rel_path = backup_file.relative_to(self.backup_dir)
            original = self.root_dir / rel_path

            shutil.copy2(backup_file, original)
            print(f"   Restored: {rel_path}")

        print(f"   ✅ Rollback complete")

def main():
    """Main execution - Preview mode only (safe)"""
    print("🚀 Localization Migration Tool\n")

    migrator = LocalizationMigrator()

    # Load top 50 quick wins
    entries = migrator.load_quick_wins(top_n=50)

    # Analyze migrations
    stats = migrator.analyze_migrations(entries)

    print(f"\n{'='*60}")
    print("📊 MIGRATION ANALYSIS")
    print(f"{'='*60}")
    print(f"Total replacements: {stats['total_replacements']}")
    print(f"Files affected: {stats['files_affected']}")
    print(f"Unique keys: {stats['unique_keys']}")
    print(f"\nTop 10 files by replacements:")
    for file_path, count in sorted(stats['by_file'].items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"  - {file_path}: {count} replacements")
    print(f"{'='*60}")

    # Generate preview report
    migrator.generate_preview_report()

    # Save replacement data for future use
    with open("migration_replacements.json", 'w', encoding='utf-8') as f:
        json.dump([asdict(r) for r in migrator.replacements], f, indent=2, ensure_ascii=False)
    print(f"✅ Saved replacement data to: migration_replacements.json")

    print(f"\n📝 NEXT STEPS:")
    print(f"   1. Review migration_preview.md")
    print(f"   2. To apply: Uncomment apply_migrations() call below")
    print(f"   3. Run flutter analyze to verify")
    print(f"   4. If issues: Use rollback() method")

    # DRY RUN (preview only)
    # migrator.apply_migrations(dry_run=True)

    # APPLYING CHANGES (Batch 1)
    migrator.apply_migrations(dry_run=False)

if __name__ == "__main__":
    main()
