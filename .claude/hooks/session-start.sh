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

# --- graphify: reinstall git hooks (post-commit/post-checkout) -------------
# Only meaningful once a graph has been built at least once. This section
# must not exit the whole script — later sections (agent-browser) still need
# to run even when there's no graph yet.
if [ -d "graphify-out" ]; then
  if ! command -v graphify >/dev/null 2>&1; then
    if command -v uv >/dev/null 2>&1; then
      # Capped so a slow/unreachable package index can't stall session start —
      # "non-blocking" must also cover a hung network call, not just a failed
      # one.
      timeout 60 uv tool install --upgrade graphifyy -q >/dev/null 2>&1
    fi
  fi

  if command -v graphify >/dev/null 2>&1; then
    graphify hook install >/dev/null 2>&1
    echo "[session-start] graphify git hooks installed"
  else
    echo "[session-start] graphify not available - skipping hook install (non-blocking)"
  fi
fi

# --- agent-browser: reinstall the CLI binary --------------------------------
# The skill stub (.agents/skills/agent-browser/SKILL.md, symlinked from
# .claude/skills/agent-browser) is committed to the repo, so it's always
# discoverable. But it only points at CLI commands (`agent-browser skills
# get ...`) -- the actual Rust binary is a global npm install, which (like
# graphify's git hooks) doesn't survive a fresh container and has to be
# redone every session.
if [ -d ".claude/skills/agent-browser" ] && ! command -v agent-browser >/dev/null 2>&1; then
  if command -v npm >/dev/null 2>&1; then
    # Capped for the same reason as the graphify install above.
    if timeout 120 npm install -g agent-browser >/dev/null 2>&1; then
      timeout 60 agent-browser install >/dev/null 2>&1
      echo "[session-start] agent-browser CLI installed"
    else
      echo "[session-start] agent-browser install failed - skipping (non-blocking)"
    fi
  fi
fi

exit 0
