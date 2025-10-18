#!/usr/bin/env python3
"""
Corregge automaticamente i problemi trovati in exercises_it_nomi.json:
1. Capitalizzazione eccessiva (le preposizioni in italiano vanno minuscole)
2. Traduzioni letterali sbagliate
3. Termini inglesi comuni
4. Errori vari (parentesi vuote, typo, ecc.)
"""

import json
import re
from pathlib import Path
from datetime import datetime

# Percorsi
SCRIPT_DIR = Path(__file__).parent
ASSETS_DIR = SCRIPT_DIR.parent / "assets" / "data"
NAMES_FILE = ASSETS_DIR / "exercises_it_nomi.json"
BACKUP_DIR = SCRIPT_DIR / "backups"

# Correzioni specifiche per traduzioni sbagliate
SPECIFIC_FIXES = {
    # Traduzioni letterali sbagliate
    'bicicletta in aria': 'air bike',
    'squadra a quattro zampe': 'a quattro zampe',
    'arm slingers': 'slanci delle braccia',
    'stile attivo': 'attivo',
    'verso il basso': 'con lancio',
    'spinta sollevamento': 'sollevamento',

    # Termini tecnici da correggere
    'advanced': 'avanzato',
    'stiff': 'gambe tese',
    'stiff leg': 'gambe tese',
    'assisted': 'assistito',
    'alternate': 'alternato',
    'alternato': 'alternato',  # Mantieni

    # Correzioni specifiche
    'gambes': 'gambe',  # Typo
    ' ()': '',  # Rimuovi parentesi vuote
    '()': '',
}

# Traduzioni termini fitness inglesi → italiano
ENGLISH_TO_ITALIAN = {
    # Esercizi comuni (mantieni nome tecnico se molto diffuso)
    r'\bpull-up\b': 'pull-up',  # Mantieni (termine universale)
    r'\bpush-up\b': 'push-up',  # Mantieni
    r'\bsit-up\b': 'sit-up',  # Mantieni
    r'\bchin-up\b': 'chin-up',  # Mantieni
    r'\bplank\b': 'plank',  # Mantieni

    # Attrezzatura
    r'\bcable\b': 'ai cavi',
    r'\bdumbbell\b': 'con manubri',
    r'\bbarbell\b': 'con bilanciere',
    r'\bkettlebell\b': 'con kettlebell',
    r'\bband\b': 'con elastico',
    r'\bmachine\b': 'alla macchina',
    r'\bsmith machine\b': 'alla smith machine',

    # Posizioni
    r'\bstanding\b': 'in piedi',
    r'\bseated\b': 'seduto',
    r'\blying\b': 'sdraiato',
    r'\bkneeling\b': 'in ginocchio',
    r'\bhanging\b': 'in sospensione',

    # Varianti
    r'\bincline\b': 'inclinata',
    r'\bdecline\b': 'declinata',
    r'\bflat\b': 'piana',
    r'\breverse\b': 'inverso',
    r'\blateral\b': 'laterale',
    r'\bwide\b': 'larga',
    r'\bnarrow\b': 'stretta',
    r'\bclose\b': 'chiusa',

    # Azioni
    r'\bstretch\b': 'allungamento',
    r'\bcrawl\b': 'gattonata',
    r'\bwalk\b': 'camminata',
}


def fix_capitalization(text):
    """
    Corregge la capitalizzazione in italiano:
    - Solo prima lettera maiuscola
    - Preposizioni, articoli e congiunzioni minuscole
    - Nomi propri e sigle maiuscole
    """

    # Parole che devono rimanere minuscole (preposizioni, articoli, congiunzioni)
    lowercase_words = {
        'a', 'con', 'di', 'da', 'in', 'su', 'per', 'tra', 'fra',
        'il', 'lo', 'la', 'i', 'gli', 'le',
        'del', 'dello', 'della', 'dei', 'degli', 'delle',
        'al', 'allo', 'alla', 'ai', 'agli', 'alle',
        'nel', 'nello', 'nella', 'nei', 'negli', 'nelle',
        'sul', 'sullo', 'sulla', 'sui', 'sugli', 'sulle',
        'dal', 'dallo', 'dalla', 'dai', 'dagli', 'dalle',
        'e', 'o', 'ma', 'però', 'quindi',
    }

    # Parole che devono rimanere maiuscole (termini tecnici, sigle)
    keep_uppercase = {
        'smith', 'machine', 'ball', 'pull-up', 'push-up', 'sit-up',
        'chin-up', 'v-up', 'l-sit', 't-bar', 'ez-bar',
        'air', 'bike', 'box', 'plank', 'crunch',
    }

    # Dividi il testo preservando parentesi e trattini
    # Pattern per separare ma mantenere delimitatori
    parts = re.split(r'(\([^)]*\)|\s+-\s+)', text)

    result_parts = []
    for part in parts:
        if not part or part.strip() in ('', '-'):
            result_parts.append(part)
            continue

        # Se è tra parentesi o un separatore, processa il contenuto
        if part.startswith('(') and part.endswith(')'):
            inner = part[1:-1]
            words = inner.split()
            fixed_words = []
            for i, word in enumerate(words):
                word_lower = word.lower()
                # Prima parola sempre maiuscola
                if i == 0:
                    fixed_words.append(word.capitalize())
                elif word_lower in lowercase_words:
                    fixed_words.append(word_lower)
                elif word_lower in keep_uppercase:
                    fixed_words.append(word_lower)
                else:
                    fixed_words.append(word.capitalize())
            result_parts.append(f"({' '.join(fixed_words)})")
        elif part.strip().startswith('-'):
            result_parts.append(part)
        else:
            # Normale testo
            words = part.split()
            fixed_words = []
            for i, word in enumerate(words):
                word_lower = word.lower()
                # Prima parola sempre maiuscola
                if i == 0 and len(result_parts) == 0:
                    fixed_words.append(word.capitalize())
                elif word_lower in lowercase_words:
                    fixed_words.append(word_lower)
                elif word_lower in keep_uppercase:
                    fixed_words.append(word_lower)
                else:
                    fixed_words.append(word.capitalize())
            result_parts.append(' '.join(fixed_words))

    result = ''.join(result_parts)

    # Assicurati che la prima lettera sia maiuscola
    if result and result[0].islower():
        result = result[0].upper() + result[1:]

    return result


def apply_specific_fixes(text):
    """Applica correzioni specifiche per termini sbagliati"""
    result = text

    for wrong, correct in SPECIFIC_FIXES.items():
        # Case-insensitive replace
        pattern = re.compile(re.escape(wrong), re.IGNORECASE)
        result = pattern.sub(correct, result)

    return result


def translate_english_terms(text):
    """Traduce termini tecnici inglesi in italiano dove appropriato"""
    result = text

    for eng_pattern, ita_term in ENGLISH_TO_ITALIAN.items():
        result = re.sub(eng_pattern, ita_term, result, flags=re.IGNORECASE)

    return result


def clean_formatting(text):
    """Pulisce formattazione (doppi spazi, spazi strani, ecc.)"""
    # Rimuovi doppi spazi
    text = re.sub(r'\s+', ' ', text)

    # Rimuovi spazi prima della punteggiatura
    text = re.sub(r'\s+([,;.])', r'\1', text)

    # Rimuovi spazi extra intorno a parentesi
    text = re.sub(r'\(\s+', '(', text)
    text = re.sub(r'\s+\)', ')', text)

    # Rimuovi trattini doppi
    text = re.sub(r'--+', '-', text)
    text = re.sub(r'\s+-\s+-\s+', ' - ', text)

    # Rimuovi parentesi vuote
    text = re.sub(r'\(\s*\)', '', text)

    # Trim
    text = text.strip()

    return text


def fix_name(name):
    """Applica tutte le correzioni a un nome"""
    # 1. Applica correzioni specifiche
    result = apply_specific_fixes(name)

    # 2. Pulisci formattazione
    result = clean_formatting(result)

    # 3. Correggi capitalizzazione
    result = fix_capitalization(result)

    # 4. Pulisci di nuovo (la capitalizzazione potrebbe aver introdotto spazi)
    result = clean_formatting(result)

    return result


def main():
    """Corregge tutti i nomi"""

    print("🔧 GymBro - Fix Italian Names")
    print("=" * 80)

    # Backup
    BACKUP_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"exercises_it_nomi_before_fix_{timestamp}.json"

    import shutil
    shutil.copy2(NAMES_FILE, backup_file)
    print(f"💾 Backup creato: {backup_file.name}")

    # Carica
    print(f"\n📖 Caricamento {NAMES_FILE.name}...")
    with open(NAMES_FILE, 'r', encoding='utf-8') as f:
        exercises = json.load(f)

    print(f"✅ Caricati {len(exercises)} esercizi\n")

    # Correggi
    print("🔄 Correzione nomi in corso...")
    changes = []
    fixed_count = 0

    for ex in exercises:
        old_name = ex['nome']
        new_name = fix_name(old_name)

        if old_name != new_name:
            ex['nome'] = new_name
            changes.append({
                'id': ex['id'],
                'old': old_name,
                'new': new_name
            })
            fixed_count += 1

    print(f"✅ Corretti {fixed_count} nomi su {len(exercises)}")

    # Mostra sample
    if changes:
        print(f"\n📋 Sample modifiche (prime 20):\n")
        for change in changes[:20]:
            print(f"📌 ID: {change['id']}")
            print(f"   ❌ Vecchio: {change['old']}")
            print(f"   ✅ Nuovo:   {change['new']}")
            print()

        if len(changes) > 20:
            print(f"   ... e altre {len(changes) - 20} modifiche\n")

    # Salva
    print(f"💾 Salvataggio {NAMES_FILE.name}...")
    with open(NAMES_FILE, 'w', encoding='utf-8') as f:
        json.dump(exercises, f, indent=2, ensure_ascii=False)

    # Salva log modifiche
    log_file = SCRIPT_DIR / "data" / f"italian_names_fixes_{timestamp}.json"
    log_file.parent.mkdir(exist_ok=True)

    with open(log_file, 'w', encoding='utf-8') as f:
        json.dump({
            'timestamp': timestamp,
            'total_exercises': len(exercises),
            'fixed_count': fixed_count,
            'changes': changes
        }, f, indent=2, ensure_ascii=False)

    print(f"📋 Log modifiche salvato: {log_file}")

    print("\n" + "=" * 80)
    print("✅ CORREZIONE COMPLETATA!")
    print("=" * 80)
    print(f"\n📊 Riepilogo:")
    print(f"   Esercizi totali: {len(exercises)}")
    print(f"   Nomi corretti: {fixed_count}")
    print(f"   Nomi invariati: {len(exercises) - fixed_count}")
    print(f"\n📁 File aggiornato: {NAMES_FILE}")
    print(f"💾 Backup: {backup_file}")
    print(f"\n📝 Prossimo step:")
    print(f"   python3 scripts/apply_names_from_review.py")
    print(f"   → Applica le correzioni a exercises_it.json")
    print("\n" + "=" * 80)


if __name__ == "__main__":
    main()
