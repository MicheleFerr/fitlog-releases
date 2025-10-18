#!/usr/bin/env python3
"""
Template-based translator for exercises
Uses complete sentence templates for natural Italian translation
"""

import json
import re
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
EXERCISES_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises.json"
GLOSSARY_FILE = SCRIPT_DIR / "fitness_glossary_en_it.json"
OUTPUT_FILE = SCRIPT_DIR.parent / "assets" / "data" / "exercises_it.json"


def load_glossary():
    with open(GLOSSARY_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


# Complete sentence templates (EN -> IT)
SENTENCE_TEMPLATES = {
    # Setup instructions
    r"^Set up (?:a|an) ([\w\s]+) at ([\w\s-]+)": r"Posiziona {1} ad {2}",
    r"^Set up (?:a|an) ([\w\s]+) to ([\w\s-]+)": r"Imposta {1} per {2}",
    r"^Adjust (?:the|your) ([\w\s]+) (?:and|to) ([\w\s]+)": r"Regola {1} e {2}",
    r"^Position yourself on (?:the|a) ([\w\s]+)": r"Posizionati sulla {1}",

    # Lying/sitting/standing
    r"^Stand with (?:your )?feet ([\w\s-]+) apart": r"Posizionati in piedi con i piedi a {1}",
    r"^Sit on (?:the|a) ([\w\s]+) with ([\w\s]+)": r"Siediti sulla {1} con {2}",
    r"^Lie ([\w\s]+) on (?:the|a) ([\w\s]+)": r"Sdraiati {1} sulla {2}",

    # Gripping
    r"^Grab (?:the|a) ([\w\s]+) with (?:a|an) ([\w\s]+) grip": r"Afferra {1} con presa {2}",
    r"^Grasp (?:the|a) ([\w\s]+) with (?:a|an) ([\w\s]+) grip": r"Afferra {1} con presa {2}",
    r"^Hold (?:a|an|the) ([\w\s]+)": r"Tieni {1}",

    # Body position
    r"^Keep your ([\w\s]+) straight": r"Mantieni {1} dritti",
    r"^Keep your ([\w\s]+) engaged": r"Mantieni {1} attivi",
    r"^Keep your ([\w\s]+) and ([\w\s]+)": r"Mantieni {1} e {2}",
    r"^Maintain (?:a|an) ([\w\s]+) position": r"Mantieni una posizione {1}",

    # Movement
    r"^Pull (?:the|your) ([\w\s]+) towards (?:your )?(\w+)": r"Tira {1} verso {2}",
    r"^Push (?:the|your) ([\w\s]+)": r"Spingi {1}",
    r"^Lower (?:the|your) ([\w\s]+)": r"Abbassa {1}",
    r"^Raise (?:the|your) ([\w\s]+)": r"Solleva {1}",
    r"^Squeeze your ([\w\s]+) together": r"Contrai {1} insieme",

    # Completion
    r"^Pause for a moment at (?:the )?([\w\s]+)": r"Fermati per un momento a {1}",
    r"^Slowly ([\w\s]+) (?:back|down) to (?:the )?([\w\s]+)": r"Lentamente {1} fino a {2}",
    r"^Return to the starting position": r"Ritorna alla posizione di partenza",
    r"^Repeat for (?:the )?desired number of repetitions": r"Ripeti per il numero desiderato di ripetizioni",
    r"^Repeat (?:with|for) (?:the )?other side": r"Ripeti con l'altro lato",
    r"^Continue alternating sides": r"Continua alternando i lati",
}

# Word-level replacements (sorted by frequency in exercises)
WORD_MAP = {
    # Equipment
    "barbell": "bilanciere",
    "dumbbell": "manubrio",
    "dumbbells": "manubri",
    "bench": "panca",
    "machine": "macchina",
    "bar": "sbarra",
    "handles": "maniglie",
    "handle": "maniglia",
    "cable": "cavo",
    "rope": "corda",
    "band": "elastico",

    # Body parts
    "chest": "petto",
    "back": "schiena",
    "shoulders": "spalle",
    "shoulder": "spalla",
    "arms": "braccia",
    "arm": "braccio",
    "legs": "gambe",
    "leg": "gamba",
    "feet": "piedi",
    "foot": "piede",
    "hands": "mani",
    "hand": "mano",
    "knees": "ginocchia",
    "knee": "ginocchio",
    "elbows": "gomiti",
    "elbow": "gomito",
    "wrists": "polsi",
    "wrist": "polso",
    "hips": "fianchi",
    "hip": "fianco",
    "core": "core",
    "torso": "torso",
    "body": "corpo",
    "head": "testa",
    "neck": "collo",

    # Muscles
    "shoulder blades": "scapole",
    "blades": "scapole",

    # Positions/grips
    "overhand grip": "presa prona",
    "underhand grip": "presa supina",
    "neutral grip": "presa neutra",
    "reverse grip": "presa inversa",
    "narrow grip": "presa stretta",
    "wide grip": "presa larga",
    "close grip": "presa chiusa",

    # Positions
    "incline": "inclinata",
    "decline": "declinata",
    "flat": "piatta",
    "standing": "in piedi",
    "seated": "seduto",
    "lying": "sdraiato",

    # Common actions
    "pull": "tira",
    "push": "spingi",
    "lift": "solleva",
    "lower": "abbassa",
    "raise": "solleva",
    "hold": "tieni",
    "grab": "afferra",
    "grasp": "afferra",
    "squeeze": "contrai",
    "engage": "attiva",
    "maintain": "mantieni",
    "keep": "mantieni",
    "pause": "fermati",
    "return": "ritorna",
    "repeat": "ripeti",

    # Common words
    "the": "",  # Remove articles, we'll add correct ones
    "your": "il tuo",
    "with": "con",
    "towards": "verso",
    "against": "contro",
    "together": "insieme",
    "straight": "dritto",
    "slightly": "leggermente",
    "slowly": "lentamente",
    "facing": "rivolto",
    "down": "giù",
    "up": "su",
    "forward": "avanti",
    "backward": "indietro",
    "at": "a",
    "on": "su",
    "in": "in",
    "to": "a",
    "of": "di",
    "for": "per",
    "and": "e",
    "then": "poi",

    # Measurements
    "shoulder-width apart": "larghezza spalle",
    "hip-width apart": "larghezza fianchi",
    "wider than": "più larghe di",
    "narrower than": "più strette di",

    # Others
    "starting position": "posizione di partenza",
    "desired number": "numero desiderato",
    "moment": "momento",
    "top": "punto massimo",
    "bottom": "punto minimo",
    "movement": "movimento",
    "exercise": "esercizio",
    "repetitions": "ripetizioni",
    "side": "lato",
}


def translate_exercise_name(name):
    """Translate exercise name"""
    if not name:
        return None

    name_lower = name.lower()

    # Apply word-by-word translation
    words = name_lower.split()
    translated = []
    for word in words:
        translated.append(WORD_MAP.get(word, word))

    result = " ".join(translated)
    return result.capitalize()


def translate_step(step, glossary):
    """Translate a single step"""
    if not step:
        return step

    # Replace Step:N with Passo N:
    step = re.sub(r'Step:(\d+)', r'Passo \1:', step)

    # Apply sentence templates first
    for pattern, replacement in SENTENCE_TEMPLATES.items():
        if re.match(pattern, step, re.IGNORECASE):
            # Extract groups and translate each group
            match = re.match(pattern, step, re.IGNORECASE)
            if match:
                groups = match.groups()
                # Translate each captured group
                translated_groups = []
                for g in groups:
                    g_trans = g
                    for en, it in WORD_MAP.items():
                        g_trans = re.sub(r'\b' + re.escape(en) + r'\b', it, g_trans, flags=re.IGNORECASE)
                    translated_groups.append(g_trans)

                # Apply replacement
                try:
                    step = replacement.format(*([''] + translated_groups))
                    return step
                except:
                    pass

    # Fall back to word-by-word translation
    for en, it in WORD_MAP.items():
        if it:  # Skip empty translations
            step = re.sub(r'\b' + re.escape(en) + r'\b', it, step, flags=re.IGNORECASE)

    return step


def translate_warmup(text):
    """Translate warmup exercises"""
    if not text:
        return None

    # Translate word by word
    for en, it in WORD_MAP.items():
        if it:
            text = re.sub(r'\b' + re.escape(en) + r'\b', it, text, flags=re.IGNORECASE)

    # Additional warmup-specific translations
    replacements = {
        "circles": "cerchi",
        "rotations": "rotazioni",
        "swings": "oscillazioni",
        "raises": "sollevamenti",
        "pulls": "trazioni",
        "pull-aparts": "aperture",
        "pull-downs": "lat machine",
        "pull-ups": "trazioni",
        "bridges": "ponti",
        "squats": "squat",
        "lunges": "affondi",
        "walks": "camminate",
        "fire hydrants": "fire hydrant",
        "clamshells": "clamshell",
        "bird dogs": "bird dog",
        "dead bugs": "dead bug",
        "face pulls": "face pull",
        "scapular": "scapolari",
    }

    for en, it in replacements.items():
        text = re.sub(r'\b' + re.escape(en) + r'\b', it, text, flags=re.IGNORECASE)

    return text


def translate_exercise(exercise, glossary):
    """Translate complete exercise"""
    translated = exercise.copy()

    # Translate name
    if exercise.get('nome'):
        translated['nome'] = translate_exercise_name(exercise['nome'])

    # Translate technical notes
    if exercise.get('noteTecniche'):
        steps = exercise['noteTecniche'].split(' | ')
        translated_steps = [translate_step(s.strip(), glossary) for s in steps if s.strip()]
        translated['noteTecniche'] = ' | '.join(translated_steps)

    # Translate warmup
    if exercise.get('mobilitaPre'):
        translated['mobilitaPre'] = translate_warmup(exercise['mobilitaPre'])

    if exercise.get('attivazionePre'):
        translated['attivazionePre'] = translate_warmup(exercise['attivazionePre'])

    return translated


def main():
    print("🇮🇹 GymBro - Template-based Translator")
    print("=" * 70)

    glossary = load_glossary()

    with open(EXERCISES_FILE, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Loaded {len(exercises)} exercises")

    translated = []
    for i, ex in enumerate(exercises, 1):
        translated.append(translate_exercise(ex, glossary))
        if i % 100 == 0:
            print(f"   {i}/{len(exercises)}...")

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(translated, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Saved to {OUTPUT_FILE.name}")

    # Sample
    sample = translated[0]
    print("\n" + "=" * 70)
    print("Sample:")
    print(f"Nome: {sample['nome']}")
    print(f"Note: {sample['noteTecniche'][:200]}...")
    print(f"Mobilità: {sample['mobilitaPre']}")


if __name__ == "__main__":
    main()
