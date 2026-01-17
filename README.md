 ./claude_usage_overview.sh
═══════════════════════════════════════════════════════════════
           CLAUDE CODE USAGE ANALYSIS REPORT
═══════════════════════════════════════════════════════════════

📊 OVERALL CACHE STATISTICS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Projects Cache:      7.3M
Total File History Cache:  7.9M
Number of Projects:        6
Number of Sessions:        31

📁 PROJECT CACHE BREAKDOWN (Top 10)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SIZE       PROJECT                                            SESSIONS
───────────────────────────────────────────────────────────────
4.7M       ~/Programming/my-saas/app/web                      8
1.2M       ~/Programming/desktop/app/tool/finished            5
800K       ~/Programming/my-saas/app/backend                  13
348K       ~/Programming/game/quiz/frontend                   1
132K       ~/Programming/scripts/usage                        1
116K       ~/Desktop/ComplianceApp                            11

📊 LAST 10 SESSIONS - MESSAGE COUNT TREND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 today        ~/Programming/scripts/usage            6 msgs                                                      132K
🟢 1 day ago    ~/Programming/game/quiz/fron          15 msgs                                                      348K
🟢 1 day ago    ~/Programming/my-saas/app/web         34 msgs █                                                  1.1M
🟢 2 days ago   ~/Programming/my-saas/app/web         36 msgs █                                                  608K
🟢 2 days ago   subagents                             20 msgs █                                                  196K
🟢 2 days ago   ~/Programming/my-saas/app/web          9 msgs                                                      108K
🟢 2 days ago   subagents                             32 msgs █                                                  220K
🟢 2 days ago   ~/Programming/my-saas/app/web          2 msgs                                                      8.0K
🟢 2 days ago   ~/Programming/my-saas/app/web         13 msgs                                                      128K
🟢 2 days ago   ~/Programming/my-saas/app/web        134 msgs ██████                                   2.2M

📈 BEHAVIOR TREND ANALYSIS
───────────────────────────────────────────────────────────────
Average messages per session:    30
Range:                          2 - 134 messages
Older sessions avg:             38 messages
Recent sessions avg:            22 messages

✓ IMPROVING! Your recent sessions are significantly shorter
  You've reduced average messages by 42%

🎯 EXCELLENT: Your sessions are at a healthy length!
   → Keep up the good habits
   → This will minimize token usage

Legend: 🟢 <150 msgs (good) | 🟡 150-300 msgs (caution) | 🔴 >300 msgs (critical)

🔍 DETAILED SESSION ANALYSIS (Largest Sessions)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Project: ~/Programming/my-saas/app/web
Session File: e9042498-2682-4aa4-b83d-5137d51c5875.jsonl
Total Size: 2.2M
Total Messages: 416

Entry Type Breakdown:
─────────────────────────────────────────────────────────────
    1.63 MB ( 76.7%) -   134 entries - user
    0.45 MB ( 21.2%) -   282 entries - assistant
    0.04 MB (  1.8%) -    33 entries - file-history-snapshot
    0.00 MB (  0.2%) -    11 entries - system
    0.00 MB (  0.1%) -     8 entries - queue-operation

Project: ~/Programming/my-saas/app/web
Session File: eadbf6ee-f0bc-4198-bf68-8e1e502fb163.jsonl
Total Size: 1.1M
Total Messages: 117

Entry Type Breakdown:
─────────────────────────────────────────────────────────────
    0.94 MB ( 88.3%) -    34 entries - user
    0.12 MB ( 11.2%) -    83 entries - assistant
    0.00 MB (  0.2%) -     7 entries - file-history-snapshot
    0.00 MB (  0.2%) -     4 entries - system
    0.00 MB (  0.1%) -     5 entries - summary

Project: ~/Programming/desktop/app/tool/finished
Session File: 1cc202df-30c3-4b02-8e5d-b310567f5150.jsonl
Total Size: 652K
Total Messages: 320

Entry Type Breakdown:
─────────────────────────────────────────────────────────────
    0.32 MB ( 50.6%) -    99 entries - user
    0.29 MB ( 46.1%) -   221 entries - assistant
    0.01 MB (  2.0%) -    17 entries - file-history-snapshot
    0.01 MB (  1.0%) -    24 entries - queue-operation
    0.00 MB (  0.4%) -     6 entries - system

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💰 ESTIMATED TOKEN USAGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Cache Size:          16 MB
Estimated Monthly Tokens:  ~48M tokens

✓  LOW TOKEN USAGE - Recommended Plan: Pro (0/month)

💡 RECOMMENDATIONS & NEXT STEPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
./claude_usage_overview.sh: line 372: [: 7.3: integer expression expected

Suggested Actions:

1. Better Workflow Habits (ACTUAL TOKEN SAVINGS!)
   → Exit Claude Code at 100-200 messages
   → Use '/compact' command regularly
   → Use '/clear' between unrelated tasks
   → Start fresh sessions for different features

2. Verify Global .claudeignore (Prevents large file reads)
   cat ~/.claude/.claudeignore
   # Ensure it includes: node_modules/, dist/, build/, .venv/, etc.

3. Clear Old Caches (Optional - frees disk space only)
   rm -rf ~/.claude/projects/*
   rm -rf ~/.claude/file-history/*
   NOTE: This does NOT reduce token usage, only disk space

4. Keep Only Recent Projects (Optional - for cleanliness)
   find ~/.claude/projects/ -name '*.jsonl' -mtime +7 -delete
   find ~/.claude/file-history/ -type f -mtime +7 -delete

5. Check Token Usage
   → Visit: https://console.anthropic.com/settings/usage
   → Monitor your actual consumption

⚠️  IMPORTANT: Cache Size vs Token Usage
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NOTE: Old cached session files are NOT loaded by Claude Code.
Deleting them frees disk space but does NOT reduce token usage.

What ACTUALLY saves tokens:
  • Exit sessions at 100-200 messages (60-80% reduction)
  • Use '/compact' command regularly (40-60% reduction)
  • Use '/clear' between unrelated tasks (30-50% reduction)
  • Better .claudeignore setup (20-40% reduction)
  • Start new sessions for different features

Your token usage comes from:
  • Long active sessions with huge context windows
  • Large files being read during sessions
  • NOT from old cached .jsonl files


═══════════════════════════════════════════════════════════════
           END OF REPORT
═══════════════════════════════════════════════════════════════

Run this script anytime to check your Claude Code cache status!
