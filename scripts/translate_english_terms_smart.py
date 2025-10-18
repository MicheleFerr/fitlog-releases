#!/usr/bin/env python3
"""
Traduce termini inglesi rimanenti in modo intelligente
Mantiene termini standard verificati online
"""

import json
from pathlib import Path
from datetime import datetime
import shutil
import re

# Percorsi
SCRIPT_DIR = Path(__file__).parent
ASSETS_DIR = SCRIPT_DIR.parent / "assets" / "data"
EXERCISES_IT = ASSETS_DIR / "exercises_it.json"
BACKUP_DIR = SCRIPT_DIR / "backups"


# TERMINI DA MANTENERE (verificati online su Wikipedia IT, My-personaltrainer.it, Project inVictus)
KEEP_AS_IS = [
    'Pull-Up', 'Pull Up', 'Pullup',
    'Push-Up', 'Push Up', 'Pushup',
    'Chin-Up', 'Chin Up', 'Chinup',
    'Sit-Up', 'Sit Up', 'Situp',
    'Bench Press',
    'Military Press',
    'Pullover',
    'Calf Raise',
    'Hip Thrust',
    'Plank',
    'Crunch',
    'Squat',
    'Lunge',
    'Curl',
    'Dip',
    'Lat Machine',
    'Pulldown',
    'Pushdown',
    'Step',
    'Box Jump',
    'Jumping Jack',
    'Burpee',
    'Deadlift',
    'Shrug',
]


def should_keep(text):
    """Verifica se il testo contiene termini da mantenere"""
    for term in KEEP_AS_IS:
        if term in text:
            return True
    return False


def translate_terms(text):
    """
    Traduce termini inglesi intelligentemente
    Solo se non sono nella lista KEEP_AS_IS
    """

    if should_keep(text):
        return text

    # Traduzioni (applicate solo se termine NON in KEEP_AS_IS)

    # Press → Spinta (ma non se è Bench Press, Military Press, ecc.)
    if ' Press' in text or text.endswith('Press'):
        text = re.sub(r'\bPress\b', 'Spinta', text)

    # Pull → Trazione (ma non Pull-Up, Pullover, Pulldown)
    if 'Pull' in text and 'Pullover' not in text and 'Pull-Up' not in text and 'Pulldown' not in text:
        text = re.sub(r'\bPull\b', 'Trazione', text)

    # Raise → Alzate (ma non Calf Raise)
    if 'Raise' in text and 'Calf Raise' not in text:
        text = re.sub(r'\bRaise\b', 'Alzate', text)

    # Fly → Croci
    if ' Fly' in text or text.endswith('Fly'):
        text = re.sub(r'\bFly\b', 'Croci', text)

    # Row → Rematore
    if 'Row' in text:
        text = re.sub(r'\bRow\b', 'Rematore', text)

    return text


def main():
    print("🌐 Traduzione Intelligente Termini Inglesi")
    print("=" * 70)

    # Backup
    BACKUP_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"exercises_it_before_translation_{timestamp}.json"
    shutil.copy2(EXERCISES_IT, backup_file)
    print(f"\n💾 Backup: {backup_file.name}")

    # Carica
    print("\n📖 Caricamento exercises_it.json...")
    with open(EXERCISES_IT, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Caricati {len(exercises)} esercizi")

    # Traduci
    print("\n🔄 Traduzione termini...")
    changes = []
    kept = []

    for ex in exercises:
        nome_old = ex['nome']

        # Check se va mantenuto
        if should_keep(nome_old):
            kept.append(ex['id'])
            continue

        # Traduci
        nome_new = translate_terms(nome_old)

        if nome_old != nome_new:
            ex['nome'] = nome_new
            changes.append({
                'id': ex['id'],
                'old': nome_old,
                'new': nome_new
            })

    print(f"✅ Tradotti: {len(changes)} termini")
    print(f"✅ Mantenuti: {len(kept)} termini standard")

    # Salva
    print(f"\n💾 Salvataggio...")
    with open(EXERCISES_IT, 'w', encoding='utf-8') as f:
        json.dump(exercises, f, indent=2, ensure_ascii=False)

    # Log
    if changes:
        log_file = SCRIPT_DIR / "data" / f"translations_{timestamp}.json"
        log_file.parent.mkdir(exist_ok=True)

        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump({
                'changes': changes,
                'kept_count': len(kept)
            }, f, indent=2, ensure_ascii=False)

        print(f"📋 Log: {log_file.name}")

    # Sample
    print(f"\n📋 Sample traduzioni (prime 30):")
    for i, c in enumerate(changes[:30], 1):
        print(f"\n{i}. {c['id']}")
        print(f"   ❌ {c['old']}")
        print(f"   ✅ {c['new']}")

    if len(changes) > 30:
        print(f"\n... e altre {len(changes) - 30} traduzioni")

    print("\n" + "=" * 70)
    print("✅ Traduzione completata!")
    print(f"\n📊 Risultato:")
    print(f"   Tradotti: {len(changes)} esercizi")
    print(f"   Mantenuti (standard): {len(kept)} esercizi")
    print(f"   File: {EXERCISES_IT}")


if __name__ == "__main__":
    main()
