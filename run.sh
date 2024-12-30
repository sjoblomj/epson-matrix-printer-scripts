#!/bin/bash

dir="$1"
char_converting="${2:-0}" # Flag to convert characters or not

# If dir is not specified, read last
if [ -z "$dir" ]; then
  dir=$(ls -1d */ | sed 's/\///g' | tail -n 1)
else
  dir=$(printf "%03d" "$dir")
fi

declare -A strings=(
  ["weather_english"]="Weather forecast"
  ["weather_swedish"]="Väderrapport"
  ["by_english"]="By"
  ["by_swedish"]="Av"
  ["published_english"]="Published"
  ["published_swedish"]="Publicerad"
  ["updated_english"]="Updated"
  ["updated_swedish"]="Uppdaterad"
  ["url_english"]="Article URL"
  ["url_swedish"]="Artikel-URL"
  ["archive_english"]="Archive URL"
  ["archive_swedish"]="Arkiv-URL"
)

if [[ "$char_converting" == 1 ]]; then
  printf "\n\r"
fi
title=$(printf "                        ╔═════════════════════════════╗
╔═══════════════════════╣   The Cyber Space Tribune   ╠═══════════════════════╗
║ %-9s %s ╚═════════════════════════════╝                  #%03d ║
╚═════════════════════════════════════════════════════════════════════════════╝
" $(date +%A) $(date -u +1%Y-%m-%d) "$dir")
if [[ "$char_converting" == 1 ]]; then
  title=$(echo "$title" | ./epson_code_converter.sh)
fi
printf "%s\n\n" "$title"

function get_string() {
  local key="$1"
  local lang="$2"
  value="${strings[${key}_${lang}]}"
  if [ -z "$value" ]; then value="${strings[${key}_english]}"; fi
  printf "%s" "$value"
}

function make_title() {
  local title="$1"
  local dashes=""
  title=$(echo $title | tr '[:lower:]' '[:upper:]' | sed 's/å/Å/g ; s/ä/Ä/g ; s/ö/Ö/g')
  dashes=$(printf '━%.0s' {1..75})
  title=$(printf "━━━ %s %s\n" "$title" "${dashes:${#title}}")
  if [[ "$char_converting" == 1 ]]; then
    title=$(echo "$title" | ./epson_code_converter.sh)
  fi
  printf "%s\n" "$title"
}

function print_weather() {
  make_title "$(get_string weather english)"
  weather=""
  if [ -f "$dir"/weather.md ]; then
    weather=$(cat "$dir"/weather.md)
  else
    ./download_weather_report.sh
  fi
  if [[ "$char_converting" == 1 ]]; then
    weather=$(echo "$weather" | ./epson_code_converter.sh | sed 's/\.\.\./\\x7E/g')
  fi
  printf "%s\n\n\n" "$weather"
}
print_weather


jq -c '.[]' $dir/toc.json | while read d; do
  make_title        "$(echo "$d" | jq -r '.publisher')"
  lang="$(             echo "$d" | jq -r '.language')"
  printf "\n# %s\n" "$(echo "$d" | jq -r '.title')"

  by_str=$(       get_string by        "$lang")
  published_str=$(get_string published "$lang")
  updated_str=$(  get_string updated   "$lang")
  url_str=$(      get_string url       "$lang")
  archive_str=$(  get_string archive   "$lang")

  printf "\n%s: %s. %s: %s" "$by_str" "$(echo "$d" | jq -r '.author')" "$published_str" "$(echo "$d" | jq -r '.published')"
  updated=$(echo "$d" | jq -r '.updated // ""')
  if [ -n "$updated" ]; then
    printf ". %s: %s\n" "$updated_str" "$updated"
  else
    printf "\n"
  fi

  printf "[%s](%s)\n" "$url_str" "$(echo "$d" | jq -r '.url')"
  if [ -n "$(echo "$d" | jq -r '.archivedurl // ""')" ]; then
    printf "[%s](%s)\n" "$archive_str" "$(echo "$d" | jq -r '.archivedurl')"
  fi

  printf "\n"
  printf "_%.0s" {1..80}
  printf "\n\n"

  content=$(cat "$dir"/"$(echo "$d" | jq -r '.file')")
  if [[ "$char_converting" == 1 ]]; then
    content=$(echo "$content" | ./epson_code_converter.sh)
  fi
  printf "%s\n" "$content"

  printf "\n\n\n"
done
