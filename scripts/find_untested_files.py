#!/usr/bin/env python3
"""
Trova tutti i file lib/ che NON hanno test corrispondenti.
Utile per identificare dove aggiungere test per aumentare coverage.
"""

import os
from pathlib import Path

def find_untested_files():
    lib_root = Path("lib")
    test_root = Path("test")

    # Categorie di file da cercare
    patterns = {
        "Repositories": "*_repository.dart",
        "Providers": "*_provider.dart",
        "Services": "*_service.dart",
        "Screens": "*_screen.dart",
        "Widgets": "*.dart"  # Solo per presentation/widgets/
    }

    results = {}

    for category, pattern in patterns.items():
        untested = []

        if category == "Widgets":
            # Solo widget in presentation/widgets/
            files = lib_root.glob("**/presentation/widgets/" + pattern)
        else:
            files = lib_root.rglob(pattern)

        for lib_file in files:
            # Skip generated files
            if ".g.dart" in str(lib_file) or ".freezed.dart" in str(lib_file):
                continue

            # Calcola path del test corrispondente
            rel_path = lib_file.relative_to(lib_root)
            test_file = test_root / rel_path.parent / (lib_file.stem + "_test.dart")

            if not test_file.exists():
                untested.append(str(lib_file))

        if untested:
            results[category] = untested

    return results

def main():
    print("🔍 Scanning for untested files...")
    print()

    results = find_untested_files()

    total_untested = sum(len(files) for files in results.values())

    if total_untested == 0:
        print("✅ All files have tests!")
        return

    print(f"📊 Found {total_untested} files without tests:\n")

    for category, files in sorted(results.items()):
        print(f"\n{category} ({len(files)} files):")
        print("=" * 50)
        for file in sorted(files)[:10]:  # Show first 10
            print(f"  ❌ {file}")
        if len(files) > 10:
            print(f"  ... and {len(files) - 10} more")

    print("\n" + "=" * 50)
    print(f"\n💡 Total: {total_untested} files need tests")
    print("\n🎯 Priority for 70% coverage:")
    print("  1. Repositories (business logic)")
    print("  2. Services (business logic)")
    print("  3. Providers (state management)")
    print("  4. Screens (UI)")
    print("  5. Widgets (UI components)")

if __name__ == "__main__":
    main()
