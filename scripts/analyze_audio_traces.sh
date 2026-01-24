#!/bin/bash

# 🔬 Audio Trace Log Analyzer
# Analyzes Xcode Console logs to detect timer audio bugs
# Usage: ./analyze_audio_traces.sh <log_file.txt>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -ne 1 ]; then
    echo -e "${RED}Usage: $0 <xcode_console_log.txt>${NC}"
    echo ""
    echo "Example:"
    echo "  $0 ~/Desktop/fitlog_debug/timer_audio_logs_2026-01-22.txt"
    exit 1
fi

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}❌ Error: Log file not found: $LOG_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🔬 AUDIO TRACE LOG ANALYZER${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Analyzing: ${YELLOW}$LOG_FILE${NC}"
echo ""

# Create output directory
OUTPUT_DIR="$(dirname "$LOG_FILE")/analysis_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}Output directory: ${OUTPUT_DIR}${NC}"
echo ""

# ============================================================================
# STEP 1: Extract all trace IDs
# ============================================================================

echo -e "${BLUE}[1/7] Extracting trace IDs...${NC}"

TRACE_IDS=$(grep -o "Trace ID: [a-zA-Z0-9-]*" "$LOG_FILE" | awk '{print $3}' | sort -u)
TRACE_COUNT=$(echo "$TRACE_IDS" | wc -l | tr -d ' ')

if [ "$TRACE_COUNT" -eq 0 ]; then
    echo -e "${RED}❌ No trace IDs found in log file${NC}"
    echo -e "${YELLOW}⚠️  Make sure you're analyzing Xcode Console logs with AudioTraceLogger enabled${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found ${TRACE_COUNT} trace(s)${NC}"
echo "$TRACE_IDS" > "$OUTPUT_DIR/trace_ids.txt"
echo ""

# ============================================================================
# STEP 2: Extract trace summaries
# ============================================================================

echo -e "${BLUE}[2/7] Extracting trace summaries...${NC}"

# Extract all trace summaries
grep -A 20 "TRACE SUMMARY" "$LOG_FILE" > "$OUTPUT_DIR/trace_summaries.txt" || true

SUMMARY_COUNT=$(grep -c "TRACE SUMMARY" "$OUTPUT_DIR/trace_summaries.txt" || echo "0")
echo -e "${GREEN}✅ Extracted ${SUMMARY_COUNT} trace summaries${NC}"
echo ""

# ============================================================================
# STEP 3: Detect bugs
# ============================================================================

echo -e "${BLUE}[3/7] Detecting bugs...${NC}"
echo ""

BUG_REPORT="$OUTPUT_DIR/bug_report.md"

cat > "$BUG_REPORT" <<EOF
# 🐛 Audio Trace Bug Report

**Generated:** $(date)
**Log file:** $LOG_FILE
**Total traces:** $TRACE_COUNT

---

## Bug Detection Summary

EOF

# Bug 1: Double play (audio played 2+ times)
echo -e "${YELLOW}Checking for double play bug...${NC}"
DOUBLE_PLAY=$(grep "Audio played: [2-9] time" "$LOG_FILE" || true)
DOUBLE_PLAY_COUNT=$(echo "$DOUBLE_PLAY" | grep -c "Audio played" || echo "0")

if [ "$DOUBLE_PLAY_COUNT" -gt 0 ]; then
    echo -e "${RED}❌ DOUBLE PLAY BUG DETECTED: ${DOUBLE_PLAY_COUNT} case(s)${NC}"
    cat >> "$BUG_REPORT" <<EOF
### ❌ BUG 1: Double Play (Audio Played 2+ Times)

**Severity:** HIGH
**Occurrences:** $DOUBLE_PLAY_COUNT

**Evidence:**
\`\`\`
$DOUBLE_PLAY
\`\`\`

**Root Cause:** Race condition - notification fired before cancellation

---

EOF
else
    echo -e "${GREEN}✅ No double play bugs detected${NC}"
    echo "### ✅ No Double Play Bugs" >> "$BUG_REPORT"
    echo "" >> "$BUG_REPORT"
fi

# Bug 2: No sound (audio played 0 times)
echo -e "${YELLOW}Checking for no sound bug...${NC}"
NO_SOUND=$(grep "Audio played: 0 time" "$LOG_FILE" || true)
NO_SOUND_COUNT=$(echo "$NO_SOUND" | grep -c "Audio played" || echo "0")

if [ "$NO_SOUND_COUNT" -gt 0 ]; then
    echo -e "${RED}❌ NO SOUND BUG DETECTED: ${NO_SOUND_COUNT} case(s)${NC}"
    cat >> "$BUG_REPORT" <<EOF
### ❌ BUG 2: No Sound (Audio Played 0 Times)

**Severity:** HIGH
**Occurrences:** $NO_SOUND_COUNT

**Evidence:**
\`\`\`
$NO_SOUND
\`\`\`

**Root Cause:** Timer cancelled early OR deduplication false positive

---

EOF
else
    echo -e "${GREEN}✅ No 'no sound' bugs detected${NC}"
    echo "### ✅ No Silent Failures" >> "$BUG_REPORT"
    echo "" >> "$BUG_REPORT"
fi

# Bug 3: Race conditions (3+ concurrent audio paths)
echo -e "${YELLOW}Checking for race conditions...${NC}"
RACE_CONDITIONS=$(grep "concurrent audio paths" "$LOG_FILE" | grep -v "1-2" || true)
RACE_COUNT=$(echo "$RACE_CONDITIONS" | grep -c "paths" || echo "0")

if [ "$RACE_COUNT" -gt 0 ]; then
    echo -e "${RED}❌ RACE CONDITION DETECTED: ${RACE_COUNT} case(s)${NC}"
    cat >> "$BUG_REPORT" <<EOF
### ⚠️ WARNING: Race Conditions

**Severity:** MEDIUM
**Occurrences:** $RACE_COUNT

**Evidence:**
\`\`\`
$RACE_CONDITIONS
\`\`\`

**Root Cause:** Multiple audio paths competing simultaneously

---

EOF
else
    echo -e "${GREEN}✅ No race conditions detected${NC}"
    echo "### ✅ No Race Conditions" >> "$BUG_REPORT"
    echo "" >> "$BUG_REPORT"
fi

echo ""

# ============================================================================
# STEP 4: Pattern analysis
# ============================================================================

echo -e "${BLUE}[4/7] Analyzing patterns...${NC}"

# Count by audio path
echo -e "${YELLOW}Audio path usage:${NC}"
echo "  SILENT-LOOP: $(grep -c "SILENT-LOOP.*STARTED" "$LOG_FILE" || echo "0")"
echo "  DISPATCH-TIMER: $(grep -c "DISPATCH-TIMER.*SCHEDULED" "$LOG_FILE" || echo "0")"
echo "  NOTIFICATION: $(grep -c "NOTIFICATION.*SCHEDULED" "$LOG_FILE" || echo "0")"
echo "  LIVE-ACTIVITY: $(grep -c "LIVE-ACTIVITY.*SCHEDULED" "$LOG_FILE" || echo "0")"
echo "  AUDIO-PLAYER: $(grep -c "AUDIO-PLAYER.*PLAYED" "$LOG_FILE" || echo "0")"
echo ""

# Deduplication stats
DEDUP_ALLOW=$(grep -c "DEDUPLICATION.*allow" "$LOG_FILE" || echo "0")
DEDUP_BLOCK=$(grep -c "DEDUPLICATION.*BLOCKED" "$LOG_FILE" || echo "0")

echo -e "${YELLOW}Deduplication:${NC}"
echo "  Allowed: $DEDUP_ALLOW"
echo "  Blocked: $DEDUP_BLOCK"

if [ "$DEDUP_BLOCK" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠️  Some legitimate timers might have been blocked${NC}"
fi

echo ""

# ============================================================================
# STEP 5: Per-trace analysis
# ============================================================================

echo -e "${BLUE}[5/7] Generating per-trace reports...${NC}"

mkdir -p "$OUTPUT_DIR/traces"
TRACE_COUNT_PROCESSED=0

# Process each trace
for trace_id in $TRACE_IDS; do
    SHORT_ID=$(echo "$trace_id" | cut -c1-8)
    TRACE_FILE="$OUTPUT_DIR/traces/${SHORT_ID}.txt"

    # Extract all logs for this trace
    grep "\[$SHORT_ID\]" "$LOG_FILE" > "$TRACE_FILE" || true

    # Count events
    EVENT_COUNT=$(wc -l < "$TRACE_FILE" | tr -d ' ')

    if [ "$EVENT_COUNT" -gt 0 ]; then
        TRACE_COUNT_PROCESSED=$((TRACE_COUNT_PROCESSED + 1))
        echo "  Trace $SHORT_ID: $EVENT_COUNT events"
    fi
done

echo -e "${GREEN}✅ Processed ${TRACE_COUNT_PROCESSED} traces${NC}"
echo ""

# ============================================================================
# STEP 6: Generate timeline visualization
# ============================================================================

echo -e "${BLUE}[6/7] Generating timeline...${NC}"

TIMELINE_FILE="$OUTPUT_DIR/timeline.txt"

cat > "$TIMELINE_FILE" <<EOF
# Audio Trace Timeline

Generated: $(date)
Log file: $LOG_FILE

═══════════════════════════════════════════════════════════

EOF

# Extract timeline events
grep -E "🔬.*\[(.*)\].*→" "$LOG_FILE" | head -100 >> "$TIMELINE_FILE" || true

echo -e "${GREEN}✅ Timeline saved to timeline.txt${NC}"
echo ""

# ============================================================================
# STEP 7: Generate summary
# ============================================================================

echo -e "${BLUE}[7/7] Generating summary...${NC}"

SUMMARY_FILE="$OUTPUT_DIR/SUMMARY.md"

# Calculate success rate
TOTAL_SUMMARIES=$SUMMARY_COUNT
if [ "$TOTAL_SUMMARIES" -eq 0 ]; then
    SUCCESS_RATE="N/A"
else
    BUGS_FOUND=$((DOUBLE_PLAY_COUNT + NO_SOUND_COUNT))
    SUCCESS_COUNT=$((TOTAL_SUMMARIES - BUGS_FOUND))
    SUCCESS_RATE=$((SUCCESS_COUNT * 100 / TOTAL_SUMMARIES))
fi

cat > "$SUMMARY_FILE" <<EOF
# 📊 Audio Trace Analysis Summary

**Date:** $(date)
**Log file:** \`$(basename "$LOG_FILE")\`

---

## Results Overview

| Metric | Value |
|--------|-------|
| Total traces | $TRACE_COUNT |
| Trace summaries found | $SUMMARY_COUNT |
| Double play bugs | $DOUBLE_PLAY_COUNT |
| No sound bugs | $NO_SOUND_COUNT |
| Race conditions | $RACE_COUNT |
| **Success rate** | **${SUCCESS_RATE}%** |

---

## Bug Severity

$(if [ "$DOUBLE_PLAY_COUNT" -gt 0 ] || [ "$NO_SOUND_COUNT" -gt 0 ]; then
    echo "🔴 **CRITICAL** - Audio playback bugs detected"
elif [ "$RACE_COUNT" -gt 0 ]; then
    echo "🟡 **WARNING** - Race conditions detected"
else
    echo "🟢 **HEALTHY** - No bugs detected"
fi)

---

## Recommendations

$(if [ "$SUCCESS_RATE" != "N/A" ] && [ "$SUCCESS_RATE" -lt 50 ]; then
    echo "### 🚨 URGENT - Structural Fix Required"
    echo ""
    echo "Success rate < 50% indicates systematic issues."
    echo ""
    echo "**Actions:**"
    echo "1. Implement centralized AudioCoordinator"
    echo "2. Add state machine for audio paths"
    echo "3. Synchronize Live Activity with BackgroundAudioManager"
elif [ "$SUCCESS_RATE" != "N/A" ] && [ "$SUCCESS_RATE" -lt 90 ]; then
    echo "### ⚠️ Hotfix Recommended"
    echo ""
    echo "Success rate 50-90% suggests fixable race conditions."
    echo ""
    echo "**Actions:**"
    echo "1. Add mutex to deduplication check"
    echo "2. Cancel notifications BEFORE audio play"
    echo "3. Add emergency logging"
else
    echo "### ✅ Good Health"
    echo ""
    echo "Success rate > 90% - bugs might be environmental."
    echo ""
    echo "**Actions:**"
    echo "1. Test on different devices"
    echo "2. Collect more device context"
    echo "3. Monitor production logs"
fi)

---

## Files Generated

- \`bug_report.md\` - Detailed bug evidence
- \`trace_summaries.txt\` - All trace summaries
- \`timeline.txt\` - Event timeline
- \`traces/\` - Per-trace logs (${TRACE_COUNT_PROCESSED} files)

---

## Next Steps

1. **Review bug report:** \`cat "$OUTPUT_DIR/bug_report.md"\`
2. **Check specific traces:** \`ls "$OUTPUT_DIR/traces/"\`
3. **Share findings:** Attach this summary + bug_report.md

EOF

echo -e "${GREEN}✅ Summary generated${NC}"
echo ""

# ============================================================================
# Final output
# ============================================================================

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Analysis Complete!${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Results saved to:${NC} $OUTPUT_DIR"
echo ""
echo -e "${YELLOW}Quick view:${NC}"
cat "$SUMMARY_FILE"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Files generated:${NC}"
ls -lh "$OUTPUT_DIR" | tail -n +2
echo ""

# Open summary in default editor (optional)
if command -v open &> /dev/null; then
    echo -e "${BLUE}Opening summary in default viewer...${NC}"
    open "$SUMMARY_FILE"
fi

echo ""
echo -e "${GREEN}Done! 🎉${NC}"

