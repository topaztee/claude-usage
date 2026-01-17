#!/bin/bash

# Claude Code Usage Overview Script
# Shows cache usage, project breakdown, and optimization suggestions

set -e

CLAUDE_DIR="$HOME/.claude"
PROJECTS_DIR="$CLAUDE_DIR/projects"
FILE_HISTORY_DIR="$CLAUDE_DIR/file-history"

# Colors for better readability
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}           CLAUDE CODE USAGE ANALYSIS REPORT${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Overall Statistics
echo -e "${BOLD}📊 OVERALL CACHE STATISTICS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_PROJECTS_SIZE=$(du -sh "$PROJECTS_DIR" 2>/dev/null | cut -f1 || echo "0B")
TOTAL_FILE_HISTORY_SIZE=$(du -sh "$FILE_HISTORY_DIR" 2>/dev/null | cut -f1 || echo "0B")
NUM_PROJECTS=$(find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | xargs)
NUM_FILE_HISTORY=$(find "$FILE_HISTORY_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | xargs)

echo -e "Total Projects Cache:      ${YELLOW}$TOTAL_PROJECTS_SIZE${NC}"
echo -e "Total File History Cache:  ${YELLOW}$TOTAL_FILE_HISTORY_SIZE${NC}"
echo -e "Number of Projects:        ${YELLOW}$NUM_PROJECTS${NC}"
echo -e "Number of Sessions:        ${YELLOW}$NUM_FILE_HISTORY${NC}"
echo ""

# Project Breakdown
echo -e "${BOLD}📁 PROJECT CACHE BREAKDOWN (Top 10)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-10s %-50s %s\n" "SIZE" "PROJECT" "SESSIONS"
echo "───────────────────────────────────────────────────────────────"

if [ -d "$PROJECTS_DIR" ]; then
    du -sh "$PROJECTS_DIR"/*/ 2>/dev/null | sort -rh | head -10 | while read -r size dir; do
        project_name=$(basename "$dir" | sed 's/-Users-topaz-/~\//' | sed 's/-/\//g')
        session_count=$(find "$dir" -name "*.jsonl" 2>/dev/null | wc -l | xargs)
        
        # Color code by size - extract numeric value and unit
        size_num=$(echo "$size" | sed 's/[^0-9.]//g')
        size_unit=$(echo "$size" | sed 's/[0-9.]//g')
        color=$GREEN
        
        # Use awk for decimal comparison (works on all systems)
        if [ "$size_unit" = "G" ]; then
            # Size is in GB - always red
            color=$RED
        elif [ "$size_unit" = "M" ]; then
            # Size is in MB - check if > 10
            if [ -n "$size_num" ] && awk -v num="$size_num" 'BEGIN {exit !(num > 10)}'; then
                color=$RED
            else
                color=$YELLOW
            fi
        fi
        
        printf "${color}%-10s${NC} %-50s %s\n" "$size" "$project_name" "$session_count"
    done
else
    echo "No projects cache found"
fi
echo ""

# Session Message Count Bar Graph
echo -e "${BOLD}📊 LAST 10 SESSIONS - MESSAGE COUNT TREND${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Collect session data with timestamps
session_data=$(find "$PROJECTS_DIR" -name "*.jsonl" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | \
    sort -rn | head -10)

if [ -z "$session_data" ]; then
    echo "No sessions found"
    echo ""
else
    # First pass: collect data for trend analysis
    declare -a msg_counts
    declare -a timestamps
    total_msgs=0
    count=0
    
    echo "$session_data" | cut -d' ' -f2- | while read -r session_file; do
        if [ ! -f "$session_file" ]; then
            continue
        fi
        
        user_count=$(grep -c '"type":"user"' "$session_file" 2>/dev/null || echo 0)
        file_size=$(du -h "$session_file" | cut -f1)
        session_name=$(basename "$session_file" .jsonl | cut -c1-12)
        project_name=$(basename "$(dirname "$session_file")" | sed 's/-Users-topaz-/~\//' | sed 's/-/\//g' | cut -c1-35)
        
        # Get modification time for age calculation
        mod_time=$(stat -f "%m" "$session_file" 2>/dev/null || echo 0)
        now=$(date +%s)
        age_days=$(( (now - mod_time) / 86400 ))
        
        if [ $age_days -eq 0 ]; then
            age_str="today"
        elif [ $age_days -eq 1 ]; then
            age_str="1 day ago"
        else
            age_str="$age_days days ago"
        fi
        
        # Create bar graph (each # = 20 messages)
        bar_length=$((user_count / 20))
        if [ $bar_length -gt 50 ]; then
            bar_length=50
        fi
        
        # Color code based on message count
        if [ $user_count -gt 300 ]; then
            color=$RED
            status="🔴"
        elif [ $user_count -gt 150 ]; then
            color=$YELLOW
            status="🟡"
        else
            color=$GREEN
            status="🟢"
        fi
        
        # Generate bar
        bar=$(printf "%${bar_length}s" | tr ' ' '█')
        
        printf "${color}%-2s${NC} " "$status"
        printf "%-12s " "$age_str"
        printf "%-35s " "$project_name"
        printf "%4d msgs " "$user_count"
        printf "${color}%-50s${NC} " "$bar"
        printf "%6s\n" "$file_size"
    done
    
    echo ""
    
    # Calculate statistics for trend
    echo -e "${BOLD}📈 BEHAVIOR TREND ANALYSIS${NC}"
    echo "───────────────────────────────────────────────────────────────"
    
    # Use Python for better stats calculation
    python3 << 'PYEOF'
import sys
import os
import json
import subprocess
from pathlib import Path
from datetime import datetime

sessions = []
projects_dir = os.path.expanduser("~/.claude/projects")

# Get all session files with timestamps
result = subprocess.run(
    f'find "{projects_dir}" -name "*.jsonl" -type f -exec stat -f "%m %N" {{}} \\; 2>/dev/null | sort -rn | head -10',
    shell=True, capture_output=True, text=True
)

for line in result.stdout.strip().split('\n'):
    if not line:
        continue
    parts = line.split(' ', 1)
    if len(parts) < 2:
        continue
    
    timestamp = int(parts[0])
    filepath = parts[1]
    
    if not os.path.exists(filepath):
        continue
    
    # Count user messages
    try:
        with open(filepath, 'r') as f:
            user_count = sum(1 for line in f if '"type":"user"' in line)
        sessions.append({'timestamp': timestamp, 'messages': user_count, 'file': filepath})
    except:
        pass

if not sessions:
    print("No sessions found for analysis")
    sys.exit(0)

# Sort by timestamp (oldest to newest for trend)
sessions_by_time = sorted(sessions, key=lambda x: x['timestamp'])

# Calculate trend
if len(sessions_by_time) >= 2:
    older_half = sessions_by_time[:len(sessions_by_time)//2]
    newer_half = sessions_by_time[len(sessions_by_time)//2:]
    
    avg_older = sum(s['messages'] for s in older_half) / len(older_half)
    avg_newer = sum(s['messages'] for s in newer_half) / len(newer_half)
    
    total_avg = sum(s['messages'] for s in sessions_by_time) / len(sessions_by_time)
    max_msgs = max(s['messages'] for s in sessions_by_time)
    min_msgs = min(s['messages'] for s in sessions_by_time)
    
    print(f"Average messages per session:    {total_avg:.0f}")
    print(f"Range:                          {min_msgs} - {max_msgs} messages")
    print(f"Older sessions avg:             {avg_older:.0f} messages")
    print(f"Recent sessions avg:            {avg_newer:.0f} messages")
    print()
    
    # Trend analysis
    if avg_newer < avg_older * 0.7:
        print("\033[0;32m✓ IMPROVING!\033[0m Your recent sessions are significantly shorter")
        print(f"  You've reduced average messages by {((avg_older - avg_newer) / avg_older * 100):.0f}%")
    elif avg_newer < avg_older:
        print("\033[1;33m↗ SLIGHT IMPROVEMENT\033[0m Recent sessions are a bit shorter")
        print(f"  You've reduced average messages by {((avg_older - avg_newer) / avg_older * 100):.0f}%")
    elif avg_newer > avg_older * 1.3:
        print("\033[0;31m⚠ GETTING WORSE!\033[0m Recent sessions are getting longer")
        print(f"  Average messages increased by {((avg_newer - avg_older) / avg_older * 100):.0f}%")
    else:
        print("\033[1;33m→ STABLE\033[0m Session lengths are consistent")
    
    print()
    
    # Recommendations based on current behavior
    if avg_newer > 200:
        print("\033[0;31m🎯 GOAL: Get recent session average below 150 messages\033[0m")
        print("   → Use '/compact' every 100 messages")
        print("   → Exit and restart for different features/tasks")
    elif avg_newer > 100:
        print("\033[1;33m🎯 GOAL: Get recent session average below 100 messages\033[0m")
        print("   → You're doing better, keep it up!")
        print("   → Use '/clear' between unrelated work")
    else:
        print("\033[0;32m🎯 EXCELLENT: Your sessions are at a healthy length!\033[0m")
        print("   → Keep up the good habits")
        print("   → This will minimize token usage")

PYEOF
    
    echo ""
    echo "Legend: 🟢 <150 msgs (good) | 🟡 150-300 msgs (caution) | 🔴 >300 msgs (critical)"
fi

echo ""

# Detailed Session Analysis
echo -e "${BOLD}🔍 DETAILED SESSION ANALYSIS (Largest Sessions)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

analyze_session() {
    local file=$1
    local project_name=$2
    
    if [ ! -f "$file" ]; then
        return
    fi
    
    local file_size=$(du -h "$file" | cut -f1)
    
    # Use Python to analyze the JSONL file
    python3 << EOF
import json
import sys

entry_types = {}
total_size = 0
message_count = 0

try:
    with open('$file', 'r') as f:
        for line in f:
            line_size = len(line)
            total_size += line_size
            try:
                data = json.loads(line)
                entry_type = data.get('type', 'unknown')
                if entry_type not in entry_types:
                    entry_types[entry_type] = {'count': 0, 'size': 0}
                entry_types[entry_type]['count'] += 1
                entry_types[entry_type]['size'] += line_size
                
                if entry_type in ['user', 'assistant']:
                    message_count += 1
            except:
                pass
    
    # Print analysis
    print(f"\n${BOLD}Project:${NC} $project_name")
    print(f"${BOLD}Session File:${NC} $(basename $file)")
    print(f"${BOLD}Total Size:${NC} $file_size")
    print(f"${BOLD}Total Messages:${NC} {message_count}")
    print("")
    print("Entry Type Breakdown:")
    print("─────────────────────────────────────────────────────────")
    
    for entry_type, stats in sorted(entry_types.items(), key=lambda x: x[1]['size'], reverse=True):
        size_mb = stats['size'] / (1024 * 1024)
        pct = (stats['size'] / total_size * 100) if total_size > 0 else 0
        
        # Color code
        if pct > 50:
            color = '\033[0;31m'  # Red
        elif pct > 20:
            color = '\033[1;33m'  # Yellow
        else:
            color = '\033[0;32m'  # Green
        
        print(f"{color}{size_mb:>8.2f} MB ({pct:>5.1f}%) - {stats['count']:>5} entries - {entry_type}${NC}")
except Exception as e:
    print(f"Error analyzing session: {e}", file=sys.stderr)
EOF
}

# Find and analyze the 3 largest session files
echo ""
find "$PROJECTS_DIR" -name "*.jsonl" -type f -exec du -h {} + 2>/dev/null | \
    sort -rh | head -3 | while read -r size file; do
    project_dir=$(dirname "$file")
    project_name=$(basename "$project_dir" | sed 's/-Users-topaz-/~\//' | sed 's/-/\//g')
    analyze_session "$file" "$project_name"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Token Usage Estimation
echo -e "${BOLD}💰 ESTIMATED TOKEN USAGE${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_CACHE_MB=$(du -sm "$PROJECTS_DIR" "$FILE_HISTORY_DIR" 2>/dev/null | awk '{sum+=$1} END {print sum}')

# Rough estimation: 1MB of cache = ~3M tokens when loaded repeatedly
ESTIMATED_MONTHLY_TOKENS=$((TOTAL_CACHE_MB * 3))

echo -e "Total Cache Size:          ${YELLOW}${TOTAL_CACHE_MB} MB${NC}"
echo -e "Estimated Monthly Tokens:  ${YELLOW}~${ESTIMATED_MONTHLY_TOKENS}M tokens${NC}"
echo ""

if [ $ESTIMATED_MONTHLY_TOKENS -gt 500 ]; then
    echo -e "${RED}⚠️  HIGH TOKEN USAGE - Recommended Plan: Professional ($200/month)${NC}"
elif [ $ESTIMATED_MONTHLY_TOKENS -gt 100 ]; then
    echo -e "${YELLOW}⚠️  MODERATE TOKEN USAGE - Recommended Plan: Professional ($200/month)${NC}"
else
    echo -e "${GREEN}✓  LOW TOKEN USAGE - Recommended Plan: Pro ($20/month)${NC}"
fi

echo ""

# Recommendations
echo -e "${BOLD}💡 RECOMMENDATIONS & NEXT STEPS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check for sessions with >500 messages
LARGE_SESSIONS=$(find "$PROJECTS_DIR" -name "*.jsonl" -type f -exec sh -c '
    count=$(grep -c "\"type\":\"user\"" "$1" 2>/dev/null || echo 0)
    if [ "$count" -gt 500 ]; then
        echo "$1:$count"
    fi
' _ {} \; 2>/dev/null | wc -l | xargs)

# Check cache size
CACHE_SIZE_WARNING=0
if [[ "$TOTAL_PROJECTS_SIZE" =~ M$ ]] && [ "${TOTAL_PROJECTS_SIZE%M}" -gt 50 ]; then
    CACHE_SIZE_WARNING=1
fi

echo ""
if [ $LARGE_SESSIONS -gt 0 ]; then
    echo -e "${RED}🚨 CRITICAL: Found $LARGE_SESSIONS sessions with 500+ messages${NC}"
    echo "   → These sessions are extremely bloated and causing high token usage"
    echo "   → Recommendation: Clear these immediately"
    echo ""
fi

if [ $CACHE_SIZE_WARNING -eq 1 ]; then
    echo -e "${YELLOW}⚠️  WARNING: Projects cache is over 50MB${NC}"
    echo "   → This will significantly increase token consumption"
    echo "   → Recommendation: Clean up old project caches"
    echo ""
fi

printf "${BOLD}Suggested Actions:${NC}\n"
printf "\n"

printf "1. ${BOLD}Better Workflow Habits${NC} ${RED}(ACTUAL TOKEN SAVINGS!)${NC}\n"
printf "   → Exit Claude Code at 100-200 messages\n"
printf "   → Use '/compact' command regularly\n"
printf "   → Use '/clear' between unrelated tasks\n"
printf "   → Start fresh sessions for different features\n"
printf "\n"

printf "2. ${BOLD}Verify Global .claudeignore${NC} ${YELLOW}(Prevents large file reads)${NC}\n"
printf "   cat ~/.claude/.claudeignore\n"
printf "   # Ensure it includes: node_modules/, dist/, build/, .venv/, etc.\n"
printf "\n"

printf "3. ${BOLD}Clear Old Caches${NC} ${GREEN}(Optional - frees disk space only)${NC}\n"
printf "   rm -rf ~/.claude/projects/*\n"
printf "   rm -rf ~/.claude/file-history/*\n"
printf "   ${YELLOW}NOTE: This does NOT reduce token usage, only disk space${NC}\n"
printf "\n"

printf "4. ${BOLD}Keep Only Recent Projects${NC} ${GREEN}(Optional - for cleanliness)${NC}\n"
printf "   find ~/.claude/projects/ -name '*.jsonl' -mtime +7 -delete\n"
printf "   find ~/.claude/file-history/ -type f -mtime +7 -delete\n"
printf "\n"

printf "5. ${BOLD}Check Token Usage${NC}\n"
printf "   → Visit: https://console.anthropic.com/settings/usage\n"
printf "   → Monitor your actual consumption\n"
printf "\n"

# Expected savings calculation
if [ $TOTAL_CACHE_MB -gt 0 ]; then
    printf "${BOLD}⚠️  IMPORTANT: Cache Size vs Token Usage${NC}\n"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "\n"
    printf "${YELLOW}NOTE: Old cached session files are NOT loaded by Claude Code.${NC}\n"
    printf "${YELLOW}Deleting them frees disk space but does NOT reduce token usage.${NC}\n"
    printf "\n"
    printf "${BOLD}What ACTUALLY saves tokens:${NC}\n"
    printf "  • Exit sessions at 100-200 messages (60-80%% reduction)\n"
    printf "  • Use '/compact' command regularly (40-60%% reduction)\n"
    printf "  • Use '/clear' between unrelated tasks (30-50%% reduction)\n"
    printf "  • Better .claudeignore setup (20-40%% reduction)\n"
    printf "  • Start new sessions for different features\n"
    printf "\n"
    printf "${BOLD}Your token usage comes from:${NC}\n"
    printf "  • Long active sessions with huge context windows\n"
    printf "  • Large files being read during sessions\n"
    printf "  • NOT from old cached .jsonl files\n"
    printf "\n"
fi

printf "\n"
printf "${BOLD}═══════════════════════════════════════════════════════════════${NC}\n"
printf "${BOLD}           END OF REPORT${NC}\n"
printf "${BOLD}═══════════════════════════════════════════════════════════════${NC}\n"
printf "\n"
printf "Run this script anytime to check your Claude Code cache status!\n"
printf "\n"