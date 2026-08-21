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
    # Capped like the install above -- a hang here previously had no timeout
    # and could block the agent-browser section below from ever running.
    timeout 30 graphify hook install >/dev/null 2>&1
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
#
# Version pinned deliberately (supply-chain hardening): the skill's own
# frontmatter pre-authorizes `Bash(agent-browser:*)`, so an unpinned install
# would let a future compromised or hijacked npm release run under that
# blanket approval with no re-review. Bump this pin by hand when there's a
# reason to (a real new feature/fix needed), not automatically.
AGENT_BROWSER_VERSION="0.27.0"

if [ -d ".claude/skills/agent-browser" ]; then
  if ! command -v agent-browser >/dev/null 2>&1; then
    # Capped for the same reason as the graphify install above.
    timeout 120 npm install -g "agent-browser@${AGENT_BROWSER_VERSION}" >/dev/null 2>&1
  fi

  if command -v agent-browser >/dev/null 2>&1; then
    # This session's egress policy blocks googlechromelabs.github.io (403,
    # confirmed live), so `agent-browser install`'s own Chrome download
    # cannot complete here -- not a transient failure, a policy denial (see
    # /root/.ccr/README.md: report blocked hosts, don't route around them).
    # Prefer the Chromium this remote environment already ships for
    # Playwright instead of fighting that block: same browser, already
    # present, already inside the environment's own network allowances.
    PLAYWRIGHT_CHROMIUM="/opt/pw-browsers/chromium"

    if [ -x "$PLAYWRIGHT_CHROMIUM" ]; then
      # Written to /etc/profile.d/ (not exported here) because this hook's
      # own process exits before any later Bash tool call starts a new shell
      # -- an `export` in this script would not reach that shell. profile.d
      # is the mechanism this same container already uses for durable
      # session-wide env (see /etc/profile.d/ccr-agent-proxy-ca.sh for
      # HTTPS_PROXY). Rewritten every session since /etc/ doesn't survive a
      # fresh container either.
      cat > /etc/profile.d/agent-browser-executable.sh <<EOF
export AGENT_BROWSER_EXECUTABLE_PATH="$PLAYWRIGHT_CHROMIUM"
EOF
      echo "[session-start] agent-browser CLI ready (using pre-installed Playwright Chromium)"
    else
      # Fallback for an environment without Playwright's Chromium -- best
      # effort, may fail here for the same policy reason.
      if timeout 60 agent-browser install >/dev/null 2>&1; then
        echo "[session-start] agent-browser CLI ready"
      else
        echo "[session-start] agent-browser on PATH but no browser available (no Playwright Chromium, and its own download is blocked here) - may not be usable (non-blocking)"
      fi
    fi
  else
    echo "[session-start] agent-browser not available - skipping (non-blocking)"
  fi
fi

exit 0
