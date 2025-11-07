#!/usr/bin/env python3
"""
Comprehensive Hardcoded Strings Scanner for Flutter/Dart codebase
Scans all .dart and .swift files to find hardcoded UI strings (IT + EN)
"""

import re
import json
import os
from pathlib import Path
from typing import Dict, List, Tuple
from dataclasses import dataclass, asdict

@dataclass
class HardcodedString:
    """Represents a hardcoded string found in code"""
    file_path: str
    line_number: int
    string_value: str
    language: str  # 'IT', 'EN', or 'UNKNOWN'
    context: str  # surrounding code for context
    string_type: str  # 'text', 'label', 'message', etc.

class HardcodedStringScanner:
    """Scans Dart/Swift files for hardcoded UI strings"""

    def __init__(self, root_dir: str):
        self.root_dir = Path(root_dir)
        self.results: List[HardcodedString] = []

        # Patterns to EXCLUDE (technical keys, not UI strings)
        self.exclude_patterns = [
            r'^[a-z_]+$',  # snake_case keys (userId, workout_id)
            r'^/[a-zA-Z0-9/_\-\.]+$',  # URLs/paths
            r'^https?://',  # URLs
            r'^assets/',  # Asset paths
            r'^\./',  # Relative paths
            r'^[A-Z_]+$',  # CONSTANT_NAMES
            r'^\d+$',  # Pure numbers
            r'^[a-z]+:[a-z]+$',  # Protocol strings (http:, file:)
            r'^#[0-9A-Fa-f]{6}$',  # Hex colors
            r'^0x[0-9A-Fa-f]+$',  # Hex numbers
            r'^[a-z]+\.[a-z]+$',  # Dot notation (context.read)
        ]

        # Keywords indicating UI strings
        self.ui_indicators = [
            'Text(', 'text:', 'labelText:', 'hintText:', 'title:', 'subtitle:',
            'message:', 'description:', 'placeholder:', 'errorText:',
            'showSnackBar', 'showDialog', 'AlertDialog', 'SnackBar',
            'AppBar(', 'tooltip:', 'semanticLabel:', 'label:',
        ]

        # Italian words to detect language
        self.italian_words = [
            'allenamento', 'esercizio', 'serie', 'ripetizioni', 'pausa',
            'completato', 'inizia', 'aggiungi', 'modifica', 'elimina',
            'salva', 'annulla', 'conferma', 'errore', 'successo',
            'carico', 'peso', 'tempo', 'data', 'note', 'storico',
            'profilo', 'impostazioni', 'notifiche', 'statistiche',
            'recupero', 'riposo', 'giorno', 'settimana', 'mese',
        ]

        # English words to detect language
        self.english_words = [
            'workout', 'exercise', 'set', 'reps', 'rest', 'completed',
            'start', 'add', 'edit', 'delete', 'save', 'cancel',
            'confirm', 'error', 'success', 'weight', 'time', 'date',
            'notes', 'history', 'profile', 'settings', 'notifications',
            'statistics', 'recovery', 'day', 'week', 'month',
        ]

    def is_excluded(self, string: str) -> bool:
        """Check if string matches exclusion patterns"""
        string = string.strip()
        if len(string) < 2:
            return True
        for pattern in self.exclude_patterns:
            if re.match(pattern, string, re.IGNORECASE):
                return True
        return False

    def detect_language(self, string: str) -> str:
        """Detect if string is Italian, English, or Unknown"""
        lower_string = string.lower()

        # Check for Italian words
        italian_count = sum(1 for word in self.italian_words if word in lower_string)
        # Check for English words
        english_count = sum(1 for word in self.english_words if word in lower_string)

        if italian_count > english_count and italian_count > 0:
            return 'IT'
        elif english_count > italian_count and english_count > 0:
            return 'EN'

        # Check for common Italian characters/patterns
        if any(word in lower_string for word in ['à', 'è', 'é', 'ì', 'ò', 'ù']):
            return 'IT'

        # If very short and contains common English words
        if len(string.split()) <= 2:
            if any(word.lower() in ['the', 'a', 'an', 'is', 'are', 'in', 'on', 'at'] for word in string.split()):
                return 'EN'

        return 'UNKNOWN'

    def detect_string_type(self, context: str) -> str:
        """Detect the type of string based on context"""
        context_lower = context.lower()

        if 'text(' in context_lower:
            return 'text_widget'
        elif any(key in context_lower for key in ['labeltext:', 'label:']):
            return 'label'
        elif 'hinttext:' in context_lower or 'placeholder' in context_lower:
            return 'hint'
        elif 'title:' in context_lower:
            return 'title'
        elif 'message:' in context_lower or 'showsnackbar' in context_lower:
            return 'message'
        elif 'errortext:' in context_lower or 'error' in context_lower:
            return 'error'
        elif 'tooltip:' in context_lower:
            return 'tooltip'
        elif 'appbar(' in context_lower:
            return 'appbar'
        else:
            return 'other'

    def extract_strings_from_dart(self, file_path: Path) -> List[HardcodedString]:
        """Extract hardcoded strings from a Dart file"""
        results = []

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            for line_num, line in enumerate(lines, start=1):
                # Skip comments
                if line.strip().startswith('//'):
                    continue

                # Find all string literals (single and double quotes)
                # Pattern matches: 'string' or "string" but not in comments
                string_pattern = r'''(['"])(?:(?=(\\?))\2.)*?\1'''
                matches = re.finditer(string_pattern, line)

                for match in matches:
                    string_value = match.group(0)[1:-1]  # Remove quotes

                    # Skip if excluded
                    if self.is_excluded(string_value):
                        continue

                    # Skip if it's likely a localization key (starts with lowercase, no spaces)
                    if not ' ' in string_value and string_value and string_value[0].islower() and len(string_value) < 30:
                        continue

                    # Get context (surrounding code)
                    context_start = max(0, line_num - 2)
                    context_end = min(len(lines), line_num + 1)
                    context = ''.join(lines[context_start:context_end]).strip()

                    # Check if it's likely a UI string (has UI indicators nearby)
                    is_ui_string = any(indicator in context for indicator in self.ui_indicators)

                    # If it looks like UI text or has spaces (likely user-facing), include it
                    if is_ui_string or ' ' in string_value:
                        language = self.detect_language(string_value)
                        string_type = self.detect_string_type(context)

                        results.append(HardcodedString(
                            file_path=str(file_path.relative_to(self.root_dir)),
                            line_number=line_num,
                            string_value=string_value,
                            language=language,
                            context=context[:200],  # Limit context length
                            string_type=string_type
                        ))

        except Exception as e:
            print(f"Error scanning {file_path}: {e}")

        return results

    def scan_directory(self, directory: str, pattern: str = "**/*.dart") -> None:
        """Scan all files matching pattern in directory"""
        dir_path = self.root_dir / directory
        files = list(dir_path.glob(pattern))

        print(f"Scanning {len(files)} files in {directory}...")

        for file_path in files:
            file_results = self.extract_strings_from_dart(file_path)
            self.results.extend(file_results)

        print(f"Found {len([r for r in self.results if str(file_path.relative_to(self.root_dir)).startswith(directory)])} hardcoded strings in {directory}")

    def save_results(self, output_file: str) -> None:
        """Save results to JSON file"""
        output_path = self.root_dir / output_file

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump([asdict(r) for r in self.results], f, indent=2, ensure_ascii=False)

        print(f"\n✅ Results saved to {output_file}")

    def generate_report(self) -> Dict:
        """Generate statistics report"""
        total = len(self.results)

        # Count by language
        italian = len([r for r in self.results if r.language == 'IT'])
        english = len([r for r in self.results if r.language == 'EN'])
        unknown = len([r for r in self.results if r.language == 'UNKNOWN'])

        # Count by type
        type_counts = {}
        for result in self.results:
            type_counts[result.string_type] = type_counts.get(result.string_type, 0) + 1

        # Count by directory
        dir_counts = {}
        for result in self.results:
            top_dir = result.file_path.split('/')[0] if '/' in result.file_path else result.file_path
            dir_counts[top_dir] = dir_counts.get(top_dir, 0) + 1

        return {
            'total_hardcoded_strings': total,
            'by_language': {
                'italian': italian,
                'english': english,
                'unknown': unknown
            },
            'by_type': type_counts,
            'by_directory': dir_counts,
            'total_files_scanned': len(set(r.file_path for r in self.results))
        }

def main():
    """Main execution function"""
    root_dir = "/Users/michele/gymbro_flutter_new"
    scanner = HardcodedStringScanner(root_dir)

    print("🔍 Starting comprehensive hardcoded strings scan (PASS 1)...\n")

    # Scan lib/features/
    print("📂 Scanning lib/features/...")
    scanner.scan_directory("lib/features")

    # Scan lib/shared/
    print("\n📂 Scanning lib/shared/...")
    scanner.scan_directory("lib/shared")

    # Scan ios/ Swift files
    print("\n📂 Scanning ios/ (Swift)...")
    scanner.scan_directory("ios", pattern="**/*.swift")

    # Save results
    scanner.save_results("hardcoded_strings_pass1.json")

    # Generate and print report
    report = scanner.generate_report()
    print("\n" + "="*60)
    print("📊 PASS 1 REPORT - lib/features/ + lib/shared/ + ios/")
    print("="*60)
    print(f"Total hardcoded strings found: {report['total_hardcoded_strings']}")
    print(f"\nBy Language:")
    print(f"  - Italian: {report['by_language']['italian']}")
    print(f"  - English: {report['by_language']['english']}")
    print(f"  - Unknown: {report['by_language']['unknown']}")
    print(f"\nBy Type:")
    for string_type, count in sorted(report['by_type'].items(), key=lambda x: x[1], reverse=True):
        print(f"  - {string_type}: {count}")
    print(f"\nBy Directory:")
    for directory, count in sorted(report['by_directory'].items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"  - {directory}: {count}")
    print(f"\nTotal files with hardcoded strings: {report['total_files_scanned']}")
    print("="*60)

if __name__ == "__main__":
    main()
