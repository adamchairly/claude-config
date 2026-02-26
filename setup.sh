#!/usr/bin/env bash
set -e

repo="$(cd "$(dirname "$0")" && pwd)"
claude_dir="$HOME/.claude"

mkdir -p "$claude_dir"

ln -sf "$repo/CLAUDE.md" "$claude_dir/CLAUDE.md"
ln -sf "$repo/skills" "$claude_dir/skills"

echo "$claude_dir/CLAUDE.md -> $repo/CLAUDE.md"
echo "$claude_dir/skills -> $repo/skills"
echo ""
echo "Done."
