#!/bin/bash

# Fix remaining HTML in doc comments (nested angle brackets)

set -e

echo "Fixing remaining HTML in doc comments..."

# Fix specific files with nested generics
files=(
  "lib/core/auth/admin_status_provider.dart"
  "lib/features/ai_coach/data/datasources/hive_chat_local_datasource.dart"
  "lib/features/ai_coach/domain/usecases/get_conversation_history.dart"
  "lib/features/analytics/data/datasources/achievement_local_datasource.dart"
  "lib/features/analytics/domain/repositories/analytics_repository.dart"
  "lib/features/analytics/presentation/providers/landscape_metrics_provider.dart"
  "lib/features/analytics/presentation/widgets/floating_search_fab.dart"
  "lib/features/workout/domain/usecases/get_exercise_chart_data.dart"
  "lib/shared/presentation/widgets/expanding_strip_container.dart"
)

count=0
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "Processing: $file"

    # Fix double-backticked generics back to single backticks wrapping the whole type
    # Pattern: Type`<Inner`<...>``> -> `Type<Inner<...>>`
    sed -i '' \
      -e 's/AsyncValue`<Map`<\([^>]*\)>``?>/`AsyncValue<Map<\1>?>`/g' \
      -e 's/AsyncValue`<List`<\([^>]*\)>``>/`AsyncValue<List<\1>>`/g' \
      -e 's/Future`<List`<\([^>]*\)>``>/`Future<List<\1>>`/g' \
      -e 's/Future`<Map`<\([^>]*\)>``>/`Future<Map<\1>>`/g' \
      -e 's/Stream`<List`<\([^>]*\)>``>/`Stream<List<\1>>`/g' \
      -e 's/Either`<\([^,]*\), List`<\([^>]*\)>``>/`Either<\1, List<\2>>`/g' \
      -e 's/StateController`<Map`<\([^>]*\)>``>/`StateController<Map<\1>>`/g' \
      -e 's/List`<Map`<\([^>]*\)>``>/`List<Map<\1>>`/g' \
      "$file"

    ((count++))
  fi
done

echo "✅ Fixed remaining HTML in doc comments in $count files"
