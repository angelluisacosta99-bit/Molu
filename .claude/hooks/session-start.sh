#!/bin/bash
# Reinstalls graphify's git hooks (post-commit/post-checkout) at the start of
# every session. Git hooks live in .git/hooks/, which Git never versions, so
# they vanish on every fresh container — this makes "the graph stays current"
# durable across sessions instead of a one-off manual step.
#
# Best-effort and non-blocking: any failure here must not stop the session
# from starting, so nothing below uses `set -e`.

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

# Only meaningful once a graph has been built at least once.
if [ ! -d "graphify-out" ]; then
  exit 0
fi

if ! command -v graphify >/dev/null 2>&1; then
  if command -v uv >/dev/null 2>&1; then
    uv tool install --upgrade graphifyy -q >/dev/null 2>&1
  fi
fi

if command -v graphify >/dev/null 2>&1; then
  graphify hook install >/dev/null 2>&1
  echo "[session-start] graphify git hooks installed"
else
  echo "[session-start] graphify not available - skipping hook install (non-blocking)"
fi

exit 0
