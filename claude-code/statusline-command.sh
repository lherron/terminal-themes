#!/usr/bin/env bash
# Warm Graphite statusline for Claude Code
# Uses the lsd-theme color palette

set -euo pipefail

# ANSI formatting
RESET=$'\033[0m'
DIM=$'\033[2m'
BOLD=$'\033[1m'

# Warm Graphite color palette (ANSI 256)
MAUVE=$'\033[38;5;140m'      # user, symlinks, model name
GRAY=$'\033[38;5;243m'       # separators, unmodified
LIGHT_GRAY=$'\033[38;5;245m' # permissions, older dates
DARK_GRAY=$'\033[38;5;240m'  # empty bar segments
PEACH=$'\033[38;5;223m'      # highlights, medium usage
ROSE=$'\033[38;5;174m'       # higher usage
TAN=$'\033[38;5;186m'        # large files, markup
SAGE=$'\033[38;5;107m'       # low usage, healthy
GOLD=$'\033[38;5;178m'       # modified, config, bolt icon
CORAL=$'\033[38;5;173m'      # errors, critical usage
TEAL=$'\033[38;5;73m'        # directories, brackets

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size')
current_usage=$(echo "$input" | jq '.context_window.current_usage')

# Calculate current context usage (not cumulative session totals)
# Uses: input_tokens + cache_creation_input_tokens + cache_read_input_tokens
if [ "$current_usage" != "null" ]; then
  current_tokens=$(echo "$current_usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
  percentage=$((current_tokens * 100 / context_size))
else
  percentage=0
fi

# Choose color based on usage level (warm graphite progression)
if [ "$percentage" -lt 30 ]; then
  bar_color="$SAGE"
elif [ "$percentage" -lt 50 ]; then
  bar_color="$TEAL"
elif [ "$percentage" -lt 70 ]; then
  bar_color="$PEACH"
elif [ "$percentage" -lt 85 ]; then
  bar_color="$ROSE"
else
  bar_color="$CORAL"
fi

# Create progress bar (15 characters wide)
bar_width=15
filled=$((percentage * bar_width / 100))
empty=$((bar_width - filled))

# Build the progress bar string with color
progress_bar="${bar_color}"
for ((i=0; i<filled; i++)); do
  progress_bar+="▰"
done
progress_bar+="${DARK_GRAY}"
for ((i=0; i<empty; i++)); do
  progress_bar+="▱"
done
progress_bar+="${RESET}"

# Get directory name with smart path shortening
home_dir="$HOME"
projects_dir="$HOME/projects"

if [[ "$cwd" == "$projects_dir"/* ]]; then
  dir="${cwd#$projects_dir/}"
elif [[ "$cwd" == "$home_dir"/* ]]; then
  dir="~/${cwd#$home_dir/}"
else
  dir="$cwd"
fi

# Model glyphs with warm styling
short_model="$model"
case "$model" in
  *"Opus"*) short_model="◈ Opus" ;;
  *"Sonnet"*) short_model="◇ Sonnet" ;;
  *"Haiku"*) short_model="○ Haiku" ;;
esac

# Format output with warm graphite styling
# Layout: ⟨dir⟩ │ ◈ Model │ ⚡ ▰▰▰▰▰▱▱▱▱▱ 45%
echo -n "${TEAL}⟨${RESET}${BOLD}${dir}${RESET}${TEAL}⟩${RESET} ${GRAY}│${RESET} ${MAUVE}${short_model}${RESET} ${GRAY}│${RESET} ${GOLD}⚡${RESET} ${progress_bar} ${bar_color}${percentage}%${RESET}"
