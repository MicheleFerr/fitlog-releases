#!/usr/bin/env python3
"""
Script to generate scientifically-backed warmup information for all exercises
Populates: mobilitaPre, attivazionePre, warmupSets, tempoWarmup
"""

import json
import shutil
from pathlib import Path
from datetime import datetime

# Paths
SCRIPT_DIR = Path(__file__).parent
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
BACKUP_DIR = SCRIPT_DIR / "backups"

# Science-based warmup mappings

MOBILITY_BY_FOCUS = {
    # Lower Body
    "QUAD": "Hip circles 2x10, walking lunges 2x8, leg swings 2x10",
    "GLUT": "Hip circles 2x10, glute bridges 2x12, fire hydrants 2x10",
    "FEMOR": "Leg swings 2x10, good mornings (light) 2x12, dynamic hamstring stretch 2x8",
    "POLP": "Ankle circles 2x15, calf raises (light) 2x20, tibialis raises 2x15",
    "ADDO": "Lateral lunges 2x8, cossack squats 2x6, lateral leg swings 2x10",
    "ADD": "Fire hydrants 2x12, lateral band walks 2x15, clamshells 2x12",

    # Upper Body
    "PETT": "Arm circles 2x15, band pull-aparts 2x20, wall slides 2x12",
    "LAT": "Arm circles 2x15, band pull-aparts 2x20, thoracic rotations 2x10",
    "TRAP": "Shoulder shrugs 2x15, neck circles 2x10, band pull-aparts 2x20",
    "DELT": "Arm circles 2x15 each direction, shoulder dislocations 2x12, band pull-aparts 2x20",
    "BICI": "Wrist circles 2x10, arm swings 2x12, light band curls 2x15",
    "TRIC": "Arm circles 2x15, wrist circles 2x10, light overhead extensions 2x12",
    "AVA": "Wrist circles 2x10 each direction, finger flexion/extension 2x15, wrist rotations 2x10",

    # Core
    "CORE": "Cat-cow 2x10, bird dogs 2x8, dead bugs 2x10, torso rotations 2x12",
}

ACTIVATION_BY_FOCUS = {
    # Lower Body
    "QUAD": "Bodyweight squats 2x15, leg extensions (light) 2x20, wall sits 2x20sec",
    "GLUT": "Glute bridges 2x15, clamshells 2x12 per side, single-leg bridges 2x10",
    "FEMOR": "Glute bridges 2x15, lying leg curls (light) 2x15, good mornings 2x12",
    "POLP": "Calf raises 2x20, single-leg calf raises 2x12, tibialis raises 2x15",
    "ADDO": "Side-lying adduction 2x15, ball squeezes 2x20 (3sec hold)",
    "ADD": "Lateral band walks 2x15, clamshells 2x15, side-lying abduction 2x15",

    # Upper Body
    "PETT": "Push-ups 2x10-15, band presses 2x15, floor presses (light) 2x12",
    "LAT": "Band pull-downs 2x15, scapular pull-ups 2x8, face pulls 2x15",
    "TRAP": "Band shrugs 2x20, face pulls 2x15, scapular retractions 2x15",
    "DELT": "Lateral raises (light) 2x15, front raises (light) 2x12, band pull-aparts 2x20",
    "BICI": "Band curls 2x15, hammer curls (light) 2x12, isometric holds 2x15sec",
    "TRIC": "Overhead extensions (light) 2x15, close-grip push-ups 2x10, band pushdowns 2x15",
    "AVA": "Wrist curls (light) 2x15, reverse wrist curls 2x15, farmer walks (light) 2x30sec",

    # Core
    "CORE": "Planks 2x30sec, dead bugs 2x10, bird dogs 2x8 per side, pallof press 2x12",
}

WARMUP_SETS_BY_TYPE = {
    # Compound exercises - extensive warmup
    "compound_heavy": "Empty bar×10, 40%×8, 60%×5, 80%×3, 90%×1",
    "compound_medium": "50%×10, 70%×5, 85%×2",
    "compound_light": "40%×12, 70%×8",

    # Isolation exercises - minimal warmup
    "isolation_heavy": "50%×12, 75%×8",
    "isolation_light": "50%×15",
}

WARMUP_TIME_BY_TYPE = {
    "compound_heavy": "10-12 minutes",
    "compound_medium": "7-9 minutes",
    "compound_light": "5-7 minutes",
    "isolation_heavy": "4-5 minutes",
    "isolation_light": "3-4 minutes",
}


def determine_warmup_type(exercise):
    """Determine warmup intensity category based on exercise properties"""
    tipo = exercise.get('tipoEsercizio', '').lower()
    attrezzatura = exercise.get('attrezzatura', '').lower()

    is_compound = 'compound' in tipo

    # Heavy equipment = more warmup
    heavy_equipment = any(x in attrezzatura for x in ['bilanciere', 'barbell', 'trap bar'])

    if is_compound:
        if heavy_equipment:
            return 'compound_heavy'
        elif 'manubri' in attrezzatura or 'dumbbell' in attrezzatura:
            return 'compound_medium'
        else:
            return 'compound_light'
    else:
        if heavy_equipment or 'macchina' in attrezzatura or 'machine' in attrezzatura:
            return 'isolation_heavy'
        else:
            return 'isolation_light'


def get_primary_focus(exercise):
    """Get primary muscle focus from exercise"""
    focus = exercise.get('focus')
    if not focus:
        return None

    # Parse comma-separated focus string
    focuses = [f.strip() for f in focus.split(',')]
    return focuses[0] if focuses else None


def generate_mobility(exercise):
    """Generate mobility exercises based on primary focus"""
    primary = get_primary_focus(exercise)

    if not primary:
        return "General dynamic stretching 5-7 minutes, joint mobility work"

    return MOBILITY_BY_FOCUS.get(primary, "General dynamic stretching 5-7 minutes")


def generate_activation(exercise):
    """Generate activation exercises based on primary focus"""
    primary = get_primary_focus(exercise)

    if not primary:
        return "Target muscle light activation 2-3 sets, 12-15 reps"

    return ACTIVATION_BY_FOCUS.get(primary, "Target muscle light activation 2-3 sets, 12-15 reps")


def generate_warmup_sets(exercise):
    """Generate warmup set progression"""
    warmup_type = determine_warmup_type(exercise)
    return WARMUP_SETS_BY_TYPE.get(warmup_type, "50%×12, 75%×8")


def generate_warmup_time(exercise):
    """Generate recommended warmup time"""
    warmup_type = determine_warmup_type(exercise)
    return WARMUP_TIME_BY_TYPE.get(warmup_type, "5-7 minutes")


def enrich_exercise(exercise):
    """Add warmup information to exercise"""

    # Generate warmup info (only mobility and activation)
    # warmupSets and tempoWarmup are calculated dynamically by WarmupSuggestionCard
    exercise['mobilitaPre'] = generate_mobility(exercise)
    exercise['attivazionePre'] = generate_activation(exercise)

    # Set to null (removed - handled by dynamic widget)
    exercise['warmupSets'] = None
    exercise['tempoWarmup'] = None

    return exercise


def main():
    print("🔥 GymBro - Warmup Info Generator")
    print("=" * 60)

    # Load exercises
    print(f"\n📖 Loading exercises from: {EXERCISES_FILE}")

    if not EXERCISES_FILE.exists():
        print(f"❌ File not found: {EXERCISES_FILE}")
        return

    with open(EXERCISES_FILE, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Loaded {len(exercises)} exercises")

    # Backup original
    BACKUP_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"exercises_backup_pre_warmup_{timestamp}.json"

    print(f"\n💾 Creating backup: {backup_file.name}")
    shutil.copy(EXERCISES_FILE, backup_file)
    print("✅ Backup created")

    # Enrich exercises
    print(f"\n🔄 Generating warmup information...")
    enriched = 0

    for i, exercise in enumerate(exercises, 1):
        enrich_exercise(exercise)
        enriched += 1

        if i % 100 == 0:
            print(f"   Processed {i}/{len(exercises)} exercises...")

    print(f"✅ Enriched {enriched} exercises")

    # Save updated exercises
    print(f"\n💾 Saving updated exercises...")
    with open(EXERCISES_FILE, 'w', encoding='utf-8') as f:
        json.dump(exercises, f, indent=2, ensure_ascii=False)

    file_size_mb = EXERCISES_FILE.stat().st_size / (1024 * 1024)
    print(f"✅ Saved: {EXERCISES_FILE}")
    print(f"📦 Size: {file_size_mb:.2f} MB")

    # Statistics
    print("\n" + "=" * 60)
    print("📊 Statistics:")

    with_mobility = sum(1 for ex in exercises if ex.get('mobilitaPre'))
    with_activation = sum(1 for ex in exercises if ex.get('attivazionePre'))

    print(f"   Mobility exercises: {with_mobility}/{len(exercises)} ({with_mobility/len(exercises)*100:.1f}%)")
    print(f"   Activation exercises: {with_activation}/{len(exercises)} ({with_activation/len(exercises)*100:.1f}%)")
    print(f"\n   ℹ️  Warmup sets & time: Calculated dynamically by WarmupSuggestionCard")
    print(f"       (based on user's actual working weight)")

    print("\n✨ Done! All exercises enriched with warmup preparation info.")
    print(f"   Backup saved: {backup_file.name}")


if __name__ == "__main__":
    main()
