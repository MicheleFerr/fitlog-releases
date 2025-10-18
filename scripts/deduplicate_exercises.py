#!/usr/bin/env python3
"""
Remove duplicate exercises from JSON files

Keeps the first occurrence and removes subsequent duplicates.
"""

import json
import sys
from pathlib import Path


def deduplicate_file(file_path: str) -> int:
    """
    Remove duplicates from exercises file, keep first occurrence

    Returns: Number of duplicates removed
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    seen_ids = set()
    deduplicated = []
    duplicates_removed = 0

    for exercise in data:
        exercise_id = exercise.get('id')
        if exercise_id not in seen_ids:
            seen_ids.add(exercise_id)
            deduplicated.append(exercise)
        else:
            duplicates_removed += 1
            print(f"Removing duplicate: {exercise_id} ({exercise.get('nome', 'N/A')})")

    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(deduplicated, f, ensure_ascii=False, indent=2)

    return duplicates_removed


if __name__ == "__main__":
    files = [
        "assets/data/exercises_it.json",
        "assets/data/exercises_en.json"
    ]

    for file_path in files:
        if Path(file_path).exists():
            print(f"\n📝 Processing {file_path}...")
            removed = deduplicate_file(file_path)
            print(f"   ✅ Removed {removed} duplicates")
        else:
            print(f"❌ File not found: {file_path}")
