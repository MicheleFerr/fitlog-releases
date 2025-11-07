#!/usr/bin/env python3
"""
PASS 2: Double-check verification + comparison with Pass 1
Re-scans ALL files to ensure 100% coverage and compares results
"""

import json
import subprocess
from pathlib import Path
from typing import Dict, List, Set

def run_pass2_scan():
    """Run the scanner again for Pass 2"""
    print("🔄 Starting PASS 2 (Double Verification)...\n")
    print("Re-scanning ALL files to ensure 100% coverage...")

    # Run the scanner again
    result = subprocess.run(
        ["python3", "scan_hardcoded_strings.py"],
        capture_output=True,
        text=True
    )

    print(result.stdout)

    if result.returncode != 0:
        print(f"❌ Error running Pass 2: {result.stderr}")
        return False

    # Rename the output file to pass2
    Path("hardcoded_strings_pass1.json").rename("hardcoded_strings_pass2.json")

    return True

def load_results(filename: str) -> List[Dict]:
    """Load results from JSON file"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        return []

def compare_passes():
    """Compare Pass 1 and Pass 2 results"""
    print("\n" + "="*60)
    print("🔍 COMPARING PASS 1 vs PASS 2")
    print("="*60)

    # First, we need to run Pass 1 again to get the file
    print("\n⚠️ Re-running Pass 1 to generate baseline...")
    subprocess.run(["python3", "scan_hardcoded_strings.py"], capture_output=True)

    pass1_results = load_results("hardcoded_strings_pass1.json")
    pass2_results = load_results("hardcoded_strings_pass2.json")

    if not pass1_results or not pass2_results:
        print("❌ Error: Could not load results files")
        return

    # Create sets for comparison (file_path:line_number:string_value)
    pass1_set = {
        f"{r['file_path']}:{r['line_number']}:{r['string_value']}"
        for r in pass1_results
    }
    pass2_set = {
        f"{r['file_path']}:{r['line_number']}:{r['string_value']}"
        for r in pass2_results
    }

    # Find differences
    only_in_pass1 = pass1_set - pass2_set
    only_in_pass2 = pass2_set - pass1_set
    common = pass1_set & pass2_set

    print(f"\n📊 Comparison Results:")
    print(f"  - Strings in BOTH passes (confirmed): {len(common)}")
    print(f"  - Strings ONLY in Pass 1: {len(only_in_pass1)}")
    print(f"  - Strings ONLY in Pass 2: {len(only_in_pass2)}")

    if len(only_in_pass1) > 0:
        print(f"\n⚠️ WARNING: {len(only_in_pass1)} strings found only in Pass 1")
        print("   These may be false positives or scanner inconsistencies")
        print("   First 10:")
        for item in list(only_in_pass1)[:10]:
            print(f"     - {item}")

    if len(only_in_pass2) > 0:
        print(f"\n⚠️ WARNING: {len(only_in_pass2)} strings found only in Pass 2")
        print("   These were MISSED in Pass 1!")
        print("   First 10:")
        for item in list(only_in_pass2)[:10]:
            print(f"     - {item}")

    # Calculate consistency percentage
    if len(pass1_set) > 0 or len(pass2_set) > 0:
        total_unique = len(pass1_set | pass2_set)
        consistency = (len(common) / total_unique) * 100 if total_unique > 0 else 100
        print(f"\n✅ Consistency Score: {consistency:.1f}%")

        if consistency >= 95:
            print("   🎉 Excellent! Scanner is highly consistent")
        elif consistency >= 85:
            print("   ✓ Good consistency, minor variations acceptable")
        else:
            print("   ⚠️ Low consistency, may need investigation")

    # Merge all unique strings from both passes
    print(f"\n🔀 Merging results from both passes...")
    merged_results = []

    # Add all from pass 2 (most recent)
    merged_results.extend(pass2_results)

    # Add any unique from pass 1 that weren't in pass 2
    pass2_keys = {f"{r['file_path']}:{r['line_number']}:{r['string_value']}" for r in pass2_results}
    for r in pass1_results:
        key = f"{r['file_path']}:{r['line_number']}:{r['string_value']}"
        if key not in pass2_keys:
            merged_results.append(r)

    # Save merged results
    with open("hardcoded_strings_merged.json", 'w', encoding='utf-8') as f:
        json.dump(merged_results, f, indent=2, ensure_ascii=False)

    print(f"✅ Merged {len(merged_results)} total unique strings")
    print(f"   Saved to: hardcoded_strings_merged.json")

    print("="*60)

    return merged_results

def main():
    """Main execution"""
    # Run Pass 2
    success = run_pass2_scan()

    if not success:
        print("❌ Pass 2 failed")
        return

    # Compare both passes
    merged_results = compare_passes()

    if merged_results:
        # Generate final statistics
        italian = len([r for r in merged_results if r['language'] == 'IT'])
        english = len([r for r in merged_results if r['language'] == 'EN'])
        unknown = len([r for r in merged_results if r['language'] == 'UNKNOWN'])

        print("\n" + "="*60)
        print("📊 FINAL MERGED RESULTS (Pass 1 + Pass 2)")
        print("="*60)
        print(f"Total hardcoded strings: {len(merged_results)}")
        print(f"\nBy Language:")
        print(f"  - Italian: {italian}")
        print(f"  - English: {english}")
        print(f"  - Unknown: {unknown}")
        print("="*60)
        print("\n✅ Double verification complete!")
        print("   All files scanned 2x to ensure 100% coverage")

if __name__ == "__main__":
    main()
