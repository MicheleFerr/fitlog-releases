#!/usr/bin/env python3
"""
Batch translation helper for exercises
Manages progressive translation with quality control
"""

import json
from pathlib import Path

# Paths
SCRIPT_DIR = Path(__file__).parent
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"
PROGRESS_FILE = SCRIPT_DIR / "translation_progress.json"


def load_exercises():
    """Load English exercises"""
    with open(EXERCISES_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


def load_progress():
    """Load translation progress"""
    if PROGRESS_FILE.exists():
        with open(PROGRESS_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {"translated_count": 0, "exercises": []}


def save_progress(progress):
    """Save translation progress"""
    with open(PROGRESS_FILE, 'w', encoding='utf-8') as f:
        json.dump(progress, f, indent=2, ensure_ascii=False)


def save_exercises(exercises):
    """Save Italian exercises"""
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(exercises, f, indent=2, ensure_ascii=False)


def get_next_batch(exercises, progress, batch_size=20):
    """Get next batch of exercises to translate"""
    start_idx = progress["translated_count"]
    end_idx = min(start_idx + batch_size, len(exercises))
    return exercises[start_idx:end_idx], start_idx, end_idx


def add_translated_batch(progress, translated_exercises):
    """Add newly translated exercises to progress"""
    progress["exercises"].extend(translated_exercises)
    progress["translated_count"] = len(progress["exercises"])
    save_progress(progress)
    save_exercises(progress["exercises"])


def show_status(exercises, progress):
    """Show current translation status"""
    total = len(exercises)
    translated = progress["translated_count"]
    remaining = total - translated
    percentage = (translated / total * 100) if total > 0 else 0

    print("=" * 70)
    print("📊 Translation Progress")
    print("=" * 70)
    print(f"Translated: {translated}/{total} ({percentage:.1f}%)")
    print(f"Remaining: {remaining}")
    print("=" * 70)


def main():
    exercises = load_exercises()
    progress = load_progress()

    show_status(exercises, progress)

    if progress["translated_count"] >= len(exercises):
        print("\n✨ All exercises already translated!")
        return

    batch, start_idx, end_idx = get_next_batch(exercises, progress)

    print(f"\n📋 Next batch: Exercises {start_idx + 1} to {end_idx}")
    print(f"Batch size: {len(batch)} exercises")
    print("\nReady for manual translation...")


if __name__ == "__main__":
    main()
