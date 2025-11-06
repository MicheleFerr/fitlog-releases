#!/bin/bash

# Fix Icons.* → AppIcons.* violations
# Usage: ./scripts/fix_icon_violations.sh

echo "🔧 Fixing icon violations..."

# Top icon mappings (ordered by frequency)
declare -A icon_map=(
  ["Icons.fitness_center"]="AppIcons.workout"
  ["Icons.check_circle"]="AppIcons.complete"
  ["Icons.trending_up"]="AppIcons.trendUp"
  ["Icons.close"]="AppIcons.close"
  ["Icons.info_outline"]="AppIcons.info"
  ["Icons.timer"]="AppIcons.timer"
  ["Icons.star"]="AppIcons.star"
  ["Icons.repeat"]="AppIcons.repeat"
  ["Icons.error_outline"]="AppIcons.error"
  ["Icons.trending_down"]="AppIcons.trendDown"
  ["Icons.edit"]="AppIcons.edit"
  ["Icons.add"]="AppIcons.add"
  ["Icons.calendar_today"]="AppIcons.calendar"
  ["Icons.arrow_forward_ios"]="AppIcons.forwardIos"
  ["Icons.refresh"]="AppIcons.refresh"
  ["Icons.check"]="AppIcons.check"
  ["Icons.local_fire_department"]="AppIcons.streak"
  ["Icons.emoji_events"]="AppIcons.achievement"
  ["Icons.play_arrow"]="AppIcons.play"
  ["Icons.history"]="AppIcons.history"
  ["Icons.search"]="AppIcons.search"
  ["Icons.lightbulb_outline"]="AppIcons.tip"
  ["Icons.person"]="AppIcons.person"
  ["Icons.error"]="AppIcons.error"
  ["Icons.schedule"]="AppIcons.schedule"
  ["Icons.psychology"]="AppIcons.ai"
  ["Icons.expand_more"]="AppIcons.expandMore"
  ["Icons.delete"]="AppIcons.delete"
  ["Icons.clear"]="AppIcons.clear"
  ["Icons.analytics"]="AppIcons.analytics"
)

# Find all dart files and apply replacements
find lib -name "*.dart" -type f | while read file; do
  for old_icon in "${!icon_map[@]}"; do
    new_icon="${icon_map[$old_icon]}"
    # Use perl for in-place replacement (works on macOS)
    perl -i -pe "s/\Q$old_icon\E/$new_icon/g" "$file"
  done
done

echo "✅ Icon replacements complete!"
echo "📝 Verifying with flutter analyze..."

flutter analyze
