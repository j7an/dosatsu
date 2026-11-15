#!/bin/sh
# Check the plugin manifests for Claude Code and Codex: each exists and is a
# JSON object, every one names the plugin "dosatsu" (and both marketplaces
# are themselves named "dosatsu"), and the two plugin
# manifests carry the same semver version. It also checks the skills: each
# directory under skills/ has a SKILL.md whose frontmatter name matches the
# directory and whose description is not empty, and the Codex manifest points
# at skills/. Reports every failure, not just the first. Run from anywhere: sh tests/manifests.sh
set -eu

command -v jq >/dev/null 2>&1 || { echo "error: jq is required" >&2; exit 2; }

root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

claude_plugin=.claude-plugin/plugin.json
codex_plugin=.codex-plugin/plugin.json
claude_market=.claude-plugin/marketplace.json
codex_market=.agents/plugins/marketplace.json

failed=0
fail() {
  echo "FAIL: $*" >&2
  failed=1
}

# Check 1; later checks for a file run only when this passes.
is_object() {
  if [ -f "$1" ] && jq -e 'type == "object"' "$1" >/dev/null 2>&1; then
    return 0
  fi
  fail "$1: missing or not a JSON object"
  return 1
}

semver='^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'

# Prints the version when the plugin manifest is valid; empty otherwise.
check_plugin() {
  is_object "$1" || return 0
  jq -e '.name == "dosatsu"' "$1" >/dev/null || fail "$1: name is not \"dosatsu\""
  v=$(jq -r '.version // ""' "$1")
  if printf '%s\n' "$v" | grep -Eq "$semver"; then
    printf '%s\n' "$v"
  else
    fail "$1: version \"$v\" is not semver"
  fi
}

check_market() {
  is_object "$1" || return 0
  # The marketplace name is the second half of the documented selector
  # dosatsu@dosatsu.
  jq -e '.name == "dosatsu"' "$1" >/dev/null || fail "$1: marketplace name is not \"dosatsu\""
  jq -e '.plugins | map(.name) == ["dosatsu"]' "$1" >/dev/null 2>&1 \
    || fail "$1: must list exactly the plugin \"dosatsu\""
}

# Strip one pair of surrounding single or double quotes.
unquote() {
  printf '%s\n' "$1" | sed -e "s/^\"\(.*\)\"\$/\1/" -e "s/^'\(.*\)'\$/\1/"
}

# Each directory directly under skills/ is a skill. Frontmatter is the block
# between a first line of exactly --- and the next --- line.
check_skills() {
  found=0
  for dir in skills/*/; do
    [ -d "$dir" ] || continue
    found=1
    d=${dir%/}
    n=${d#skills/}
    f=$d/SKILL.md
    if [ ! -f "$f" ]; then
      fail "$d: missing SKILL.md"
      continue
    fi
    fm=$(awk 'NR == 1 { if ($0 != "---") exit; next } $0 == "---" { ok = 1; exit } { print } END { exit !ok }' "$f") \
      || { fail "$f: no frontmatter block"; continue; }
    name=$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -n 1)
    name=$(unquote "$(printf '%s\n' "$name" | sed 's/[[:space:]]*$//')")
    [ "$name" = "$n" ] || fail "$f: name \"$name\" is not the directory name"
    desc=$(printf '%s\n' "$fm" | sed -n 's/^description:[[:space:]]*//p' | head -n 1)
    desc=$(unquote "$(printf '%s\n' "$desc" | sed 's/[[:space:]]*$//')")
    [ -n "$desc" ] || fail "$f: description is empty"
  done
  [ "$found" -eq 1 ] || fail "skills/: no skill found"
  # "./skills/" is the contract: it is the path Codex reads, so the exact
  # literal is asserted deliberately.
  jq -e '.skills == "./skills/"' "$codex_plugin" >/dev/null 2>&1 \
    || fail "$codex_plugin: skills is not \"./skills/\""
}

# Command substitution runs in a subshell, so failures inside it are
# re-detected from its stderr rather than from $failed.
errs=$(mktemp)
trap 'rm -f "$errs"' EXIT
claude_v=$(check_plugin "$claude_plugin" 2>>"$errs")
codex_v=$(check_plugin "$codex_plugin" 2>>"$errs")
if [ -s "$errs" ]; then
  cat "$errs" >&2
  failed=1
fi
check_market "$claude_market"
check_market "$codex_market"
check_skills

if [ -n "$claude_v" ] && [ -n "$codex_v" ] && [ "$claude_v" != "$codex_v" ]; then
  fail "versions differ: claude=$claude_v codex=$codex_v"
fi

[ "$failed" -eq 0 ] || exit 1
echo "ok: manifests"
