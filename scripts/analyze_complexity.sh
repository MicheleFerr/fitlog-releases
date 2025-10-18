#!/bin/bash

# Script per analizzare file complessi e suggerire refactoring

echo "📊 Analisi Complessità Codebase"
echo "================================"
echo ""

echo "🔍 File più grandi (top 10):"
find lib -name "*.dart" -type f -exec wc -l {} + | sort -rn | head -11

echo ""
echo "🎯 File che necessitano refactoring (>1000 righe):"
find lib -name "*.dart" -type f -exec wc -l {} + | awk '$1 > 1000' | sort -rn

echo ""
echo "📦 Suggerimenti refactoring:"
echo "1. exercise_list_item.dart (6030 righe)"
echo "   → Split in: exercise_card.dart, set_list.dart, quick_actions.dart"
echo ""
echo "2. workout_provider.dart (1107 righe)"
echo "   → Estrai: APRECalculationService, RoutineCompletionService, WorkoutSaveService"
echo ""
echo "3. enhanced_volume_progress_chart.dart (2673 righe)"
echo "   → Split in: chart_widget.dart, chart_data_processor.dart, chart_painter.dart"
