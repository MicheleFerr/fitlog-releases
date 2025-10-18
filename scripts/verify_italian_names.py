#!/usr/bin/env python3
"""
Verifica la correttezza dei nomi italiani in exercises_it_nomi.json
Analizza TUTTI i 1506 esercizi cercando errori di traduzione, termini inglesi, ecc.
"""

import json
import re
from pathlib import Path
from collections import defaultdict

# Percorsi
SCRIPT_DIR = Path(__file__).parent
ASSETS_DIR = SCRIPT_DIR.parent / "assets" / "data"
NAMES_FILE = ASSETS_DIR / "exercises_it_nomi.json"

# Pattern problematici da cercare
ENGLISH_TERMS = [
    'cable', 'dumbbell', 'barbell', 'band', 'smith', 'machine',
    'bodyweight', 'weighted', 'assisted', 'suspended', 'lever',
    'sled', 'kettlebell', 'resistance', 'olympic', 'powerlifter',
    'push', 'pull', 'squat', 'deadlift', 'bench', 'row',
    'curl', 'extension', 'press', 'raise', 'fly', 'crunch',
    'plank', 'lunge', 'step', 'jump', 'hop', 'twist',
    'swing', 'clean', 'snatch', 'jerk', 'thruster',
    'burpee', 'pullup', 'pushup', 'situp', 'chinup',
    'dropdown', 'overhead', 'underhand', 'overhand', 'grip',
    'wide', 'narrow', 'close', 'neutral', 'pronated', 'supinated',
    'incline', 'decline', 'flat', 'standing', 'seated', 'lying',
    'kneeling', 'hanging', 'single', 'double', 'alternating',
    'reverse', 'lateral', 'front', 'rear', 'side', 'cross',
    'up', 'down', 'in', 'out', 'over', 'under', 'around',
    'through', 'behind', 'forward', 'backward', 'diagonal',
    'stretch', 'hold', 'pike', 'tuck', 'straddle', 'split',
    'bridge', 'walk', 'run', 'sprint', 'jog', 'march',
    'slide', 'glide', 'shuffle', 'skip', 'bound',
    'slam', 'throw', 'toss', 'catch', 'roll', 'crawl',
    'bear', 'crab', 'inch', 'worm', 'spiderman', 'superman',
]

# Traduzioni sbagliate comuni
BAD_TRANSLATIONS = {
    'bicicletta in aria': 'air bike',  # Non è una "bicicletta in aria"
    'arm slingers': 'arm slingers',  # Non tradotto
    'squadra a quattro zampe': 'squad',  # "Squad" tradotto male come "squadra"
    'stile attivo': 'active style',  # Traduzione troppo letterale
    'verso il basso': 'throw down',  # Traduzione confusa
    'spinta sollevamento': 'push raise',  # Confuso
    'advanced': 'advanced',  # Non tradotto
    'stiff': 'stiff',  # Non tradotto in contesto tecnico
}

# Termini fitness corretti in italiano
CORRECT_FITNESS_TERMS = {
    'cable': 'ai cavi',
    'dumbbell': 'con manubri',
    'barbell': 'con bilanciere',
    'bodyweight': 'a corpo libero',
    'smith machine': 'alla smith machine',
    'assisted': 'assistito',
    'suspended': 'in sospensione',
    'overhead': 'sopra la testa',
    'incline': 'inclinata',
    'decline': 'declinata',
    'flat': 'piana',
    'seated': 'seduto',
    'standing': 'in piedi',
    'lying': 'sdraiato',
    'kneeling': 'in ginocchio',
    'hanging': 'appeso',
    'reverse': 'inverso',
    'lateral': 'laterale',
    'wide grip': 'presa larga',
    'narrow grip': 'presa stretta',
    'close grip': 'presa chiusa',
}


def analyze_names():
    """Analizza tutti i nomi cercando problemi"""

    print("🔍 GymBro - Verifica Nomi Italiani")
    print("=" * 80)

    # Carica nomi
    print(f"\n📖 Caricamento {NAMES_FILE.name}...")
    with open(NAMES_FILE, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Caricati {len(exercises)} esercizi\n")

    # Dizionari per categorizzare problemi
    problems = {
        'termini_inglesi': [],
        'traduzioni_letterali': [],
        'nomi_sospetti': [],
        'formattazione': [],
        'termini_non_tradotti': [],
        'possibili_miglioramenti': [],
    }

    # Analizza ogni esercizio
    for ex in exercises:
        ex_id = ex['id']
        nome = ex['nome']
        nome_lower = nome.lower()

        # 1. Cerca termini inglesi completi (non tradotti)
        for term in ENGLISH_TERMS:
            # Cerca il termine come parola intera (con boundaries)
            pattern = r'\b' + re.escape(term) + r'\b'
            if re.search(pattern, nome_lower):
                problems['termini_inglesi'].append({
                    'id': ex_id,
                    'nome': nome,
                    'termine': term,
                    'problema': f"Termine inglese '{term}' non tradotto"
                })

        # 2. Cerca traduzioni letterali sbagliate
        for bad_it, bad_en in BAD_TRANSLATIONS.items():
            if bad_it in nome_lower:
                problems['traduzioni_letterali'].append({
                    'id': ex_id,
                    'nome': nome,
                    'problema': f"Traduzione letterale sbagliata: '{bad_it}' (da '{bad_en}')"
                })

        # 3. Nomi troppo lunghi (>80 caratteri)
        if len(nome) > 80:
            problems['nomi_sospetti'].append({
                'id': ex_id,
                'nome': nome,
                'problema': f"Nome troppo lungo ({len(nome)} caratteri)"
            })

        # 4. Problemi di formattazione
        # - Doppi spazi
        if '  ' in nome:
            problems['formattazione'].append({
                'id': ex_id,
                'nome': nome,
                'problema': "Doppi spazi"
            })

        # - Spazi prima della punteggiatura
        if re.search(r' [,;.]', nome):
            problems['formattazione'].append({
                'id': ex_id,
                'nome': nome,
                'problema': "Spazio prima della punteggiatura"
            })

        # - Capitalizzazione inconsistente di preposizioni
        # "Con Le" invece di "con le", "In Piedi" invece di "in piedi"
        if re.search(r' (Con|A|Da|In|Su|Per|Di|Del|Della|Dello|Dei|Degli|Delle) [A-Z]', nome):
            # Questo è accettabile solo se la prossima parola è un nome proprio
            # Ma in molti casi è eccessivo
            problems['formattazione'].append({
                'id': ex_id,
                'nome': nome,
                'problema': "Capitalizzazione eccessiva delle preposizioni"
            })

        # 5. Pattern sospetti
        # - Parentesi vuote o strani
        if re.search(r'\(\s*\)', nome):
            problems['nomi_sospetti'].append({
                'id': ex_id,
                'nome': nome,
                'problema': "Parentesi vuote"
            })

        # - Trattini strani
        if '--' in nome or ' - -' in nome:
            problems['formattazione'].append({
                'id': ex_id,
                'nome': nome,
                'problema': "Trattini doppi o mal formattati"
            })

    # Genera report
    print("\n" + "=" * 80)
    print("📊 REPORT ANALISI")
    print("=" * 80)

    total_problems = sum(len(v) for v in problems.values())
    print(f"\n🔍 Totale problemi trovati: {total_problems}")
    print(f"📋 Esercizi analizzati: {len(exercises)}")
    print(f"✅ Esercizi senza problemi: {len(exercises) - len(set(p['id'] for cat in problems.values() for p in cat))}")

    # Mostra problemi per categoria
    for category, issues in problems.items():
        if issues:
            print(f"\n{'='*80}")
            print(f"⚠️  {category.upper().replace('_', ' ')}: {len(issues)} problemi")
            print(f"{'='*80}")

            # Mostra primi 20 di ogni categoria
            for issue in issues[:20]:
                print(f"\n📌 ID: {issue['id']}")
                print(f"   Nome: {issue['nome']}")
                print(f"   ❌ Problema: {issue['problema']}")

            if len(issues) > 20:
                print(f"\n   ... e altri {len(issues) - 20} problemi simili")

    # Salva report completo
    report_file = SCRIPT_DIR / "data" / "italian_names_verification_report.json"
    report_file.parent.mkdir(exist_ok=True)

    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump({
            'total_exercises': len(exercises),
            'total_problems': total_problems,
            'problems_by_category': {k: len(v) for k, v in problems.items()},
            'detailed_problems': problems
        }, f, indent=2, ensure_ascii=False)

    print(f"\n{'='*80}")
    print(f"💾 Report completo salvato: {report_file}")
    print(f"{'='*80}")

    # Suggerimenti
    print("\n💡 SUGGERIMENTI:")
    print("   1. I termini inglesi vanno tradotti con nomenclatura fitness italiana")
    print("   2. Evitare traduzioni troppo letterali")
    print("   3. Usare capitalizzazione consistente (solo iniziali maiuscole)")
    print("   4. Controllare formattazione (spazi, trattini, parentesi)")
    print("   5. Verificare che i nomi siano chiari e non troppo lunghi")
    print("\n" + "=" * 80)


if __name__ == "__main__":
    analyze_names()
