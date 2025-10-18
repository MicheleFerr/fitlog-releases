#!/usr/bin/env python3
"""
Intelligent exercise translator EN->IT
Uses glossary + grammar rules + context awareness for quality translations
"""

import json
import re
from pathlib import Path
from datetime import datetime

# Paths
SCRIPT_DIR = Path(__file__).parent
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
GLOSSARY_FILE = SCRIPT_DIR / "fitness_glossary_en_it.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"


def load_glossary():
    """Load fitness glossary"""
    with open(GLOSSARY_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


# Definizioni complete per traduzioni di frasi comuni
PHRASE_TRANSLATIONS = {
    # Position phrases
    r"Stand with your feet (\w+)-width apart": r"Posizionati in piedi con i piedi alla larghezza delle \1",
    r"Sit on the (\w+)": r"Siediti sulla \1",
    r"Lie (\w+) on the (\w+)": r"Sdraiati \1 sulla \2",
    r"Set up (a|an) (\w+) at": r"Posiziona \2 a",
    r"Place your hands on your hips": r"Posiziona le mani sui fianchi",

    # Grip phrases
    r"Grab(?:.*?)with (?:a|an) ([\w\s]+) grip": r"Afferra con presa \1",
    r"Grasp(?:.*?)with (?:a|an) ([\w\s]+) grip": r"Afferra con presa \1",
    r"Hold (?:a|an|the) ([\w\s]+)": r"Mantieni \1",

    # Movement phrases
    r"Pull (?:the|your) ([\w\s]+) towards": r"Tira \1 verso",
    r"Push (?:the|your) ([\w\s]+) (?:up|down|forward)": r"Spingi \1",
    r"Lower (?:the|your) ([\w\s]+) (?:back|down)": r"Abbassa \1",
    r"Raise (?:the|your) ([\w\s]+)": r"Solleva \1",
    r"Squeeze your ([\w\s]+) together": r"Contrai \1 insieme",

    # Position maintenance
    r"Keep your (\w+) straight": r"Mantieni \1 dritto",
    r"Keep your (\w+) engaged": r"Mantieni \1 attivo",
    r"Maintain (?:a|an) ([\w\s]+) position": r"Mantieni posizione \1",

    # Common instructions
    r"Pause for a moment at the (\w+)": r"Fermati un momento al \1",
    r"Slowly (\w+) (?:back|down)": r"Lentamente \1",
    r"Return to the starting position": r"Ritorna alla posizione iniziale",
    r"Repeat for the desired number of repetitions": r"Ripeti per il numero desiderato di ripetizioni",

    # Anatomical
    r"your (\w+) blades": r"le scapole",
    r"your (\w+) (\w+)": r"il tuo \1",
    r"the (\w+)": r"il \1",
}

# Common words that need article/preposition context
CONTEXTUAL_TRANSLATIONS = {
    # Equipment with articles
    "barbell": {"il": "il bilanciere", "with": "con il bilanciere", "on": "sul bilanciere"},
    "dumbbell": {"il": "il manubrio", "with": "con il manubrio", "a": "un manubrio"},
    "bench": {"il": "la panca", "on": "sulla panca", "an": "una panca"},
    "bar": {"il": "la sbarra", "the": "la sbarra", "a": "una sbarra"},
    "machine": {"il": "la macchina", "the": "la macchina", "on": "sulla macchina"},

    # Body parts with articles
    "chest": {"your": "il petto", "the": "il petto"},
    "back": {"your": "la schiena", "the": "la schiena"},
    "shoulder": {"your": "la spalla", "shoulders": "le spalle"},
    "arm": {"your": "il braccio", "arms": "le braccia"},
    "leg": {"your": "la gamba", "legs": "le gambe"},
    "knee": {"your": "il ginocchio", "knees": "le ginocchia"},
    "foot": {"your": "il piede", "feet": "i piedi"},
    "hand": {"your": "la mano", "hands": "le mani"},
    "elbow": {"your": "il gomito", "elbows": "i gomiti"},
    "wrist": {"your": "il polso", "wrists": "i polsi"},
}


def translate_exercise_name(name, glossary):
    """
    Translate exercise name with proper Italian grammar
    """
    if not name:
        return None

    # Split into parts
    parts = name.lower().split()
    translated_parts = []

    # Translate each part using glossary
    for part in parts:
        translated = part

        # Check all glossary categories
        for category in glossary.values():
            if part in category:
                translated = category[part]
                break

        translated_parts.append(translated)

    # Join and capitalize first letter
    result = " ".join(translated_parts)
    return result[0].upper() + result[1:] if result else None


def translate_step_text(text, glossary):
    """
    Translate a single step with context and grammar
    """
    if not text:
        return text

    # Replace Step:N with Passo N:
    text = re.sub(r'Step:(\d+)', r'Passo \1:', text)

    # Apply phrase-level translations first (more context)
    for en_pattern, it_replacement in PHRASE_TRANSLATIONS.items():
        text = re.sub(en_pattern, it_replacement, text, flags=re.IGNORECASE)

    # Then apply word-level translations from glossary
    # Create flat list sorted by length (longest first)
    all_terms = []
    for category in glossary.values():
        all_terms.extend(category.items())
    all_terms.sort(key=lambda x: len(x[0]), reverse=True)

    for en_term, it_term in all_terms:
        # Use word boundary matching
        pattern = r'\b' + re.escape(en_term) + r'\b'
        text = re.sub(pattern, it_term, text, flags=re.IGNORECASE)

    return text


def translate_warmup_text(text, glossary):
    """
    Translate warmup/activation exercises
    Format: "Exercise 2x10, Exercise 2x15"
    """
    if not text:
        return None

    # Split by comma
    exercises = text.split(',')
    translated = []

    for exercise in exercises:
        exercise = exercise.strip()

        # Extract sets/reps pattern (e.g., "2x10")
        match = re.search(r'(\d+x\d+)', exercise)
        sets_reps = match.group(1) if match else ""

        # Remove sets/reps from exercise name
        ex_name = re.sub(r'\d+x\d+', '', exercise).strip()

        # Translate exercise name
        translated_name = ex_name

        # Apply glossary translations
        all_terms = []
        for category in glossary.values():
            all_terms.extend(category.items())
        all_terms.sort(key=lambda x: len(x[0]), reverse=True)

        for en_term, it_term in all_terms:
            pattern = r'\b' + re.escape(en_term) + r'\b'
            translated_name = re.sub(pattern, it_term, translated_name, flags=re.IGNORECASE)

        # Reconstruct
        if sets_reps:
            translated.append(f"{translated_name} {sets_reps}")
        else:
            translated.append(translated_name)

    return ', '.join(translated)


def translate_technical_notes(text, glossary):
    """
    Translate technical notes step by step
    """
    if not text:
        return None

    # Split by | separator
    steps = text.split(' | ')
    translated_steps = []

    for step in steps:
        step = step.strip()
        if not step:
            continue

        translated_step = translate_step_text(step, glossary)
        translated_steps.append(translated_step)

    return ' | '.join(translated_steps)


def translate_exercise(exercise, glossary):
    """
    Translate complete exercise with all fields
    """
    translated = exercise.copy()

    # Translate nome
    if exercise.get('nome'):
        translated['nome'] = translate_exercise_name(exercise['nome'], glossary)

    # Translate noteTecniche
    if exercise.get('noteTecniche'):
        translated['noteTecniche'] = translate_technical_notes(exercise['noteTecniche'], glossary)

    # Translate mobilitaPre
    if exercise.get('mobilitaPre'):
        translated['mobilitaPre'] = translate_warmup_text(exercise['mobilitaPre'], glossary)

    # Translate attivazionePre
    if exercise.get('attivazionePre'):
        translated['attivazionePre'] = translate_warmup_text(exercise['attivazionePre'], glossary)

    return translated


def main():
    print("🇮🇹 GymBro - Intelligent Exercise Translator")
    print("=" * 70)

    # Load
    print("\n📖 Loading resources...")
    glossary = load_glossary()

    with open(EXERCISES_FILE, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Loaded {len(exercises)} exercises")
    print(f"✅ Loaded glossary with {sum(len(v) for v in glossary.values())} terms")

    # Translate
    print(f"\n🔄 Translating...")
    translated_exercises = []

    for i, exercise in enumerate(exercises, 1):
        translated = translate_exercise(exercise, glossary)
        translated_exercises.append(translated)

        if i % 100 == 0:
            print(f"   {i}/{len(exercises)}...")

    # Save
    print(f"\n💾 Saving to {OUTPUT_FILE.name}...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(translated_exercises, f, indent=2, ensure_ascii=False)

    file_size = OUTPUT_FILE.stat().st_size / (1024 * 1024)
    print(f"✅ Saved: {file_size:.2f} MB")

    # Show sample
    print("\n" + "=" * 70)
    print("📋 Sample (First Exercise):")
    print("=" * 70)
    sample = translated_exercises[0]
    print(f"\nNome: {sample['nome']}")
    print(f"\nNote (prime 200 char):")
    print(f"{sample['noteTecniche'][:200]}...")
    print(f"\nMobilità: {sample['mobilitaPre']}")
    print(f"Attivazione: {sample['attivazionePre']}")

    print("\n✨ Translation complete!")


if __name__ == "__main__":
    main()
