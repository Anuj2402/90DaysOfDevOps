#!/usr/bin/env bash
# generate-post.sh — Generate a LinkedIn technical post for a given day
# Usage: ./generate-post.sh <day_number>
# Example: ./generate-post.sh 1

set -euo pipefail

DAY="${1:-}"

if [[ -z "$DAY" ]]; then
  echo "Usage: $0 <day_number>"
  echo "Example: $0 1"
  exit 1
fi

# Zero-pad for matching (Day-01, Day-02, etc.)
DAY_PADDED=$(printf "%02d" "$DAY")
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find the matching day folder
DAY_DIR=$(find "$REPO_ROOT" -maxdepth 1 -type d -name "Day-${DAY_PADDED}-*" | head -1)

if [[ -z "$DAY_DIR" ]]; then
  echo "❌ No folder found for Day-${DAY_PADDED}"
  echo "Available days:"
  find "$REPO_ROOT" -maxdepth 1 -type d -name "Day-*" | sort | xargs -I{} basename {}
  exit 1
fi

TOPIC=$(basename "$DAY_DIR" | sed "s/Day-${DAY_PADDED}-//")
echo "📁 Found: $(basename "$DAY_DIR")"
echo ""

# Collect content from all markdown files in the day's folder
CONTENT=""
for md_file in "$DAY_DIR"/*.md "$DAY_DIR"/Readme.md "$DAY_DIR"/readme.md 2>/dev/null; do
  [[ -f "$md_file" ]] || continue
  CONTENT+="### $(basename "$md_file")\n"
  CONTENT+="$(cat "$md_file")\n\n"
done

if [[ -z "$CONTENT" ]]; then
  echo "❌ No markdown files found in $DAY_DIR"
  exit 1
fi

# Build the prompt
PROMPT="You are writing a LinkedIn technical post for Day ${DAY} of #90DaysOfDevOps.

Topic: ${TOPIC}

Here is the learning content from today's notes:

${CONTENT}

Write an engaging LinkedIn post following the instructions in .github/copilot-instructions.md.
Keep it under 300 words, use the template format, include real commands/snippets from the notes."

# Use copilot CLI (non-interactive mode) to generate the post
COPILOT_BIN="${HOME}/.local/share/gh/copilot/copilot"

if [[ ! -x "$COPILOT_BIN" ]]; then
  echo "❌ Copilot CLI not found at $COPILOT_BIN"
  echo "Run: gh copilot to auto-download it"
  exit 1
fi

echo "✍️  Generating LinkedIn post for Day ${DAY}: ${TOPIC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

"$COPILOT_BIN" \
  --allow-all-tools \
  --prompt "$PROMPT" \
  -C "$REPO_ROOT"
