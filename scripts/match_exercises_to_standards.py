#!/usr/bin/env python3
"""
Script per matching semantico tra esercizi GymBro e strength standards.

Usage:
    python3 scripts/match_exercises_to_standards.py

Requirements:
    pip install sentence-transformers scikit-learn pandas

Output:
    data/exercise_mappings.json - Mappings con confidence scores
"""

import json
import os
from typing import List, Dict, Tuple
from pathlib import Path

try:
    from sentence_transformers import SentenceTransformer
    from sklearn.metrics.pairwise import cosine_similarity
    import numpy as np
except ImportError:
    print("❌ Missing dependencies. Install with:")
    print("   pip install sentence-transformers scikit-learn")
    exit(1)


def normalize_text(text: str) -> str:
    """Normalizza testo per matching migliore."""
    return text.lower().strip()


def load_gymbro_exercises(path: str) -> List[Dict]:
    """Carica esercizi GymBro dal JSON."""
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def load_strength_standards(path: str) -> Dict:
    """Carica strength standards dal JSON."""
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def create_search_texts(standards: List[Dict]) -> List[str]:
    """Crea testi di ricerca per gli standards (nome + keywords)."""
    search_texts = []
    for std in standards:
        # Combina nome + tutte le keywords per matching migliore
        text_parts = [std['name']] + std.get('keywords', [])
        combined_text = ' '.join(text_parts)
        search_texts.append(normalize_text(combined_text))
    return search_texts


def find_best_matches(
    gymbro_exercises: List[Dict],
    standards: List[Dict],
    model: SentenceTransformer,
    threshold_auto: float = 0.80,
    threshold_review: float = 0.60
) -> List[Dict]:
    """
    Trova i migliori match tra esercizi GymBro e standards.

    Returns:
        Lista di mappings con confidence scores
    """

    # Prepara testi per semantic search
    gymbro_names = [normalize_text(ex['nome']) for ex in gymbro_exercises]
    standard_texts = create_search_texts(standards)

    print(f"🔄 Encoding {len(gymbro_names)} GymBro exercises...")
    gymbro_embeddings = model.encode(gymbro_names, show_progress_bar=True)

    print(f"🔄 Encoding {len(standard_texts)} strength standards...")
    standard_embeddings = model.encode(standard_texts, show_progress_bar=True)

    # Calcola similarità
    print(f"📊 Calculating cosine similarities...")
    similarities = cosine_similarity(gymbro_embeddings, standard_embeddings)

    # Crea mappings
    mappings = []
    stats = {
        'auto': 0,
        'review': 0,
        'fallback': 0,
        'total': len(gymbro_exercises)
    }

    for i, gymbro_ex in enumerate(gymbro_exercises):
        # Trova best match
        best_idx = np.argmax(similarities[i])
        best_score = float(similarities[i][best_idx])

        # Determina status
        if best_score >= threshold_auto:
            status = 'auto'
            stats['auto'] += 1
        elif best_score >= threshold_review:
            status = 'review'
            stats['review'] += 1
        else:
            status = 'fallback'
            stats['fallback'] += 1

        # Crea mapping
        mapping = {
            'gymbroId': gymbro_ex['id'],
            'gymbroName': gymbro_ex['nome'],
            'gymbroEquipment': gymbro_ex.get('attrezzatura', 'Unknown'),
            'gymbroFocus': gymbro_ex.get('focus', ''),
            'confidence': round(best_score, 4),
            'status': status
        }

        # Aggiungi dati standard solo se confidence accettabile
        if best_score >= threshold_review:
            matching_standard = standards[best_idx]
            mapping.update({
                'standardId': matching_standard['id'],
                'standardName': matching_standard['name'],
                'standardEquipment': matching_standard['equipment'],
                'dataSource': matching_standard['dataSource']
            })
        else:
            mapping['fallbackReason'] = 'low_confidence'

        mappings.append(mapping)

    print(f"\n✅ Matching completed:")
    print(f"   Auto matches (≥{threshold_auto*100}%): {stats['auto']} ({stats['auto']/stats['total']*100:.1f}%)")
    print(f"   Review needed ({threshold_review*100}-{threshold_auto*100}%): {stats['review']} ({stats['review']/stats['total']*100:.1f}%)")
    print(f"   Fallback (<{threshold_review*100}%): {stats['fallback']} ({stats['fallback']/stats['total']*100:.1f}%)")

    return mappings, stats


def analyze_matches(mappings: List[Dict]):
    """Analizza e stampa statistiche sui match."""

    # Top 10 best matches
    print(f"\n🏆 Top 10 Best Matches:")
    sorted_by_conf = sorted(mappings, key=lambda x: x['confidence'], reverse=True)
    for i, match in enumerate(sorted_by_conf[:10], 1):
        if match['status'] != 'fallback':
            print(f"   {i}. {match['gymbroName'][:30]:30} → {match['standardName'][:30]:30} ({match['confidence']:.2%})")

    # Esercizi che richiedono review
    review_matches = [m for m in mappings if m['status'] == 'review']
    if review_matches:
        print(f"\n⚠️  Esercizi che richiedono review ({len(review_matches)}):")
        for match in review_matches[:5]:
            print(f"   - {match['gymbroName'][:35]:35} → {match.get('standardName', 'N/A')[:35]:35} ({match['confidence']:.2%})")
        if len(review_matches) > 5:
            print(f"   ... and {len(review_matches) - 5} more")

    # Equipment distribution
    print(f"\n📊 Distribution by Equipment:")
    equipment_stats = {}
    for match in mappings:
        eq = match['gymbroEquipment']
        if eq not in equipment_stats:
            equipment_stats[eq] = {'auto': 0, 'review': 0, 'fallback': 0}
        equipment_stats[eq][match['status']] += 1

    for eq, counts in sorted(equipment_stats.items(), key=lambda x: sum(x[1].values()), reverse=True)[:8]:
        total = sum(counts.values())
        print(f"   {eq:15} - Total: {total:4}, Auto: {counts['auto']:3}, Review: {counts['review']:3}, Fallback: {counts['fallback']:3}")


def save_mappings(mappings: List[Dict], stats: Dict, output_path: str):
    """Salva mappings in JSON."""
    output_data = {
        'version': '1.0.0',
        'generated': '2025-01-15',
        'model': 'sentence-transformers/all-MiniLM-L6-v2',
        'statistics': stats,
        'mappings': mappings
    }

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)

    print(f"\n💾 Mappings saved to: {output_path}")


def main():
    """Main execution."""
    print("🏋️ GymBro Exercise Matching Script\n")

    # Paths
    project_root = Path(__file__).parent.parent
    gymbro_exercises_path = project_root / 'assets' / 'data' / 'exercises.json'
    strength_standards_path = project_root / 'assets' / 'data' / 'strength_standards.json'
    output_path = project_root / 'data' / 'exercise_mappings.json'

    # Crea directory data se non esiste
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Verifica file esistono
    if not gymbro_exercises_path.exists():
        print(f"❌ File not found: {gymbro_exercises_path}")
        return

    if not strength_standards_path.exists():
        print(f"❌ File not found: {strength_standards_path}")
        return

    # Carica dati
    print(f"📂 Loading GymBro exercises from: {gymbro_exercises_path}")
    gymbro_exercises = load_gymbro_exercises(gymbro_exercises_path)
    print(f"   Loaded {len(gymbro_exercises)} exercises")

    print(f"📂 Loading strength standards from: {strength_standards_path}")
    standards_data = load_strength_standards(strength_standards_path)
    standards = standards_data['standards']
    print(f"   Loaded {len(standards)} strength standards")

    # Carica modello
    print(f"\n🤖 Loading sentence transformer model (first run may download ~90MB)...")
    model = SentenceTransformer('all-MiniLM-L6-v2')
    print(f"   Model loaded successfully")

    # Esegui matching
    print(f"\n🔍 Starting semantic matching...")
    mappings, stats = find_best_matches(
        gymbro_exercises,
        standards,
        model,
        threshold_auto=0.80,  # 80% confidence per auto-match
        threshold_review=0.60  # 60% per review umana
    )

    # Analizza risultati
    analyze_matches(mappings)

    # Salva output
    save_mappings(mappings, stats, output_path)

    print(f"\n✅ Done! Next steps:")
    print(f"   1. Review matches in: {output_path}")
    print(f"   2. Manually validate 'review' status exercises")
    print(f"   3. Import mappings into Flutter app")


if __name__ == '__main__':
    main()
