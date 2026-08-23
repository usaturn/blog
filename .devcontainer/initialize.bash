#!/bin/bash
set -e

# Create required directories
mkdir -p \
  "${HOME}/.codex" \
  "${HOME}/.claude" \
  "${HOME}/.config/gh" \
  "${HOME}/.config/glab-cli" \
  "${HOME}/.grok"

# Create required files
touch \
  "${HOME}/.claude.json"
