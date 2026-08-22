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
    # Exit status checked: a killed/failed install must not be reported as
    # success (a prior version of this script did exactly that).
    if timeout 30 graphify hook install >/dev/null 2>&1; then
      echo "[session-start] graphify git hooks installed"
    else
      echo "[session-start] graphify hook install failed or timed out (non-blocking)"
    fi
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
# frontmatter pre-authorizes `Bash(agent-browser:*)`, so this script itself
# only ever installs this exact pinned version -- never an unpinned
# `npm install -g agent-browser` that could silently pull a future
# compromised or hijacked release. Bump this pin by hand when there's a
# reason to (a real new feature/fix needed), not automatically.
#
# Honest limit: this pin governs what THIS SCRIPT sets up and points
# AGENT_BROWSER_EXECUTABLE_PATH at, not what's technically callable. If a
# non-pinned binary ends up on PATH some other way (a stale one from
# before this pin existed, manual install, etc.), skipping it here stops
# this hook from configuring/relying on it, but doesn't itself stop a
# direct `Bash(agent-browser ...)` call the same session -- there's no
# PreToolUse gate on this tool the way there is on merge_pull_request
# (.claude/hooks/check-pr-review.sh). Closing that would need an
# equivalent technical gate, which is out of scope for what this section
# does today.
AGENT_BROWSER_VERSION="0.27.0"

if [ -d ".claude/skills/agent-browser" ]; then
  # Compare the installed version against the pin, not just presence -- a
  # cached container from a session before the pin was bumped could already
  # have a different version on PATH, and `command -v` alone would then
  # skip reinstalling forever, leaving the pin and the real binary silently
  # out of sync. Capped like every other external call in this file -- a
  # hanging binary here would otherwise block session start indefinitely.
  CURRENT_AGENT_BROWSER_VERSION="$(timeout 10 agent-browser --version 2>/dev/null | awk '{print $2}')"
  if [ "$CURRENT_AGENT_BROWSER_VERSION" != "$AGENT_BROWSER_VERSION" ]; then
    # Capped for the same reason as the graphify install above.
    timeout 120 npm install -g "agent-browser@${AGENT_BROWSER_VERSION}" >/dev/null 2>&1
    # Re-check after attempting the reinstall -- don't assume it worked.
    # A failed/timed-out install here (this container's own network policy
    # already blocks one npm-adjacent download below, for the same kind of
    # reason) would otherwise leave the stale binary on PATH while the
    # script still claims the pin is enforced.
    CURRENT_AGENT_BROWSER_VERSION="$(timeout 10 agent-browser --version 2>/dev/null | awk '{print $2}')"
  fi

  if command -v agent-browser >/dev/null 2>&1 && [ "$CURRENT_AGENT_BROWSER_VERSION" = "$AGENT_BROWSER_VERSION" ]; then
    # This session's egress policy blocks googlechromelabs.github.io (403,
    # confirmed live), so `agent-browser install`'s own Chrome download
    # cannot complete here -- not a transient failure, a policy denial (see
    # /root/.ccr/README.md: report blocked hosts, don't route around them).
    # Prefer the Chromium this remote environment already ships for
    # Playwright instead of fighting that block: same browser, already
    # present, already inside the environment's own network allowances.
    PLAYWRIGHT_CHROMIUM="/opt/pw-browsers/chromium"

    if [ -x "$PLAYWRIGHT_CHROMIUM" ]; then
      # $CLAUDE_ENV_FILE (not /etc/profile.d/) is the documented mechanism
      # to persist an env var into the shells later Bash tool calls start --
      # confirmed live that those calls run as `bash -c` (non-login), which
      # never sources /etc/profile.d/; an earlier version of this script
      # used profile.d and silently didn't work. Exit status checked here
      # too: if the write fails (e.g. $CLAUDE_ENV_FILE isn't set for
      # whatever reason -- observed live even with CLAUDE_CODE_REMOTE=true,
      # so don't assume it's tied to that flag), that must not be reported
      # as ready.
      if [ -n "${CLAUDE_ENV_FILE:-}" ] && \
         echo "export AGENT_BROWSER_EXECUTABLE_PATH=\"$PLAYWRIGHT_CHROMIUM\"" >> "$CLAUDE_ENV_FILE" 2>/dev/null; then
        echo "[session-start] agent-browser CLI ready (using pre-installed Playwright Chromium)"
      else
        echo "[session-start] agent-browser CLI present but could not persist AGENT_BROWSER_EXECUTABLE_PATH (non-blocking)"
      fi
    else
      # Fallback for an environment without Playwright's Chromium -- best
      # effort, may fail here for the same policy reason.
      if timeout 60 agent-browser install >/dev/null 2>&1; then
        echo "[session-start] agent-browser CLI ready"
      else
        echo "[session-start] agent-browser on PATH but no browser available (no Playwright Chromium, and its own download is blocked here) - may not be usable (non-blocking)"
      fi
    fi
  elif command -v agent-browser >/dev/null 2>&1; then
    # Don't fall through and use it anyway: the pin exists specifically so
    # a future compromised/hijacked npm release can't run under this
    # skill's pre-authorized blanket `Bash(agent-browser:*)` with no
    # re-review (see comment above AGENT_BROWSER_VERSION). A binary that
    # isn't the pinned version hasn't had that review either way, whatever
    # its actual origin -- so it's simply not used this session rather than
    # used-with-a-warning.
    echo "[session-start] agent-browser present but not at pinned version ${AGENT_BROWSER_VERSION} (still on ${CURRENT_AGENT_BROWSER_VERSION:-unknown}) after reinstall attempt - skipping this session rather than running an unverified version (non-blocking)"
  else
    echo "[session-start] agent-browser not available - skipping (non-blocking)"
  fi
fi

# --- mcp-server-dev plugin: reinstall each session, kept disabled ----------
# Installed at user scope (~/.claude/), not project-local like the skill
# stubs above, so it doesn't survive a fresh container either.
#
# Activated "for a future need" (Angel's request), not for active use today
# -- it adds ~502 tokens to every session just by being enabled (`claude
# plugin details mcp-server-dev`), which isn't worth paying session after
# session for a capability with no concrete task yet. skillOverrides
# (name-only) does NOT apply here -- Claude Code's own docs say plugin
# skills aren't affected by it, unlike the project-local skills managed
# that way elsewhere in this repo. So it stays installed but disabled;
# re-enable in one command when an actual MCP server is needed:
# `claude plugin enable mcp-server-dev`.
#
# `install` is NOT a no-op on an already-disabled plugin -- verified live
# it force-re-enables it every time it actually runs. So this only calls
# `install`/`disable` when the anchored check below shows they're actually
# needed, instead of running both unconditionally every session: that
# both avoids the churn and avoids re-triggering the re-enable on every
# firing. `disable`'s own result is checked and re-verified too (it can
# genuinely fail -- verified live against a bogus plugin name, exit 1),
# so a failed disable is reported honestly instead of assumed to have
# worked. All matches below are anchored to the exact `> name` line
# `claude plugin`/`marketplace list` print, not a bare substring grep,
# so an unrelated entry that happens to contain the same text can't
# false-positive.
#
# Read-only `list` calls are NOT free or local -- verified live with
# strace that they make a real outbound network connection, and with a
# blocked route that they can take several seconds instead of failing
# fast. So every one is capped with `timeout` too (not just the
# mutating add/install/disable calls), and the output is cached in a
# variable and only re-fetched right after something that could have
# changed it (add/install/disable), instead of re-running the same
# read-only command repeatedly for the same snapshot of state.
if command -v claude >/dev/null 2>&1; then
  MARKETPLACE_LIST="$(timeout 15 claude plugin marketplace list 2>/dev/null)"
  if ! printf '%s\n' "$MARKETPLACE_LIST" | grep -qE '^\s*>\s*claude-plugins-official\s*$'; then
    timeout 90 claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1
    MARKETPLACE_LIST="$(timeout 15 claude plugin marketplace list 2>/dev/null)"
  fi

  PLUGIN_LIST="$(timeout 15 claude plugin list 2>/dev/null)"
  if printf '%s\n' "$MARKETPLACE_LIST" | grep -qE '^\s*>\s*claude-plugins-official\s*$' && \
     ! printf '%s\n' "$PLUGIN_LIST" | grep -qE '^\s*>\s*mcp-server-dev@claude-plugins-official\s*$'; then
    timeout 90 claude plugin install mcp-server-dev@claude-plugins-official >/dev/null 2>&1
    PLUGIN_LIST="$(timeout 15 claude plugin list 2>/dev/null)"
  fi

  if printf '%s\n' "$PLUGIN_LIST" | grep -qE '^\s*>\s*mcp-server-dev@claude-plugins-official\s*$'; then
    if printf '%s\n' "$PLUGIN_LIST" | grep -A3 -E '^\s*>\s*mcp-server-dev@claude-plugins-official\s*$' | grep -q 'Status:.*enabled'; then
      timeout 90 claude plugin disable mcp-server-dev >/dev/null 2>&1
      PLUGIN_LIST="$(timeout 15 claude plugin list 2>/dev/null)"
    fi

    if printf '%s\n' "$PLUGIN_LIST" | grep -A3 -E '^\s*>\s*mcp-server-dev@claude-plugins-official\s*$' | grep -q 'Status:.*disabled'; then
      echo "[session-start] mcp-server-dev plugin installed, disabled by default (claude plugin enable mcp-server-dev when needed)"
    else
      echo "[session-start] mcp-server-dev plugin installed but could not confirm disabled state (non-blocking)"
    fi
  else
    echo "[session-start] mcp-server-dev plugin not available (non-blocking)"
  fi
else
  echo "[session-start] claude CLI not available - skipping mcp-server-dev plugin (non-blocking)"
fi

# --- ponytail plugin: reinstall each session, kept enabled ------------------
# Unlike mcp-server-dev/agent-browser, installed at PROJECT scope
# (`--scope project`): the marketplace/plugin declaration itself
# (`extraKnownMarketplaces`/`enabledPlugins` in .claude/settings.json) is
# committed to the repo, so it's known from the moment the project loads --
# no user-scope re-declaration needed. But the actual cloned marketplace
# content still lives under ~/.claude/plugins/marketplaces/, which is
# per-container cache, not part of the repo, so it still needs
# repopulating every fresh session (verified live: deleting just that
# cache dir while the repo's settings.json stays intact produces
# `Status: x failed to load / Error: ... cache-miss`).
#
# Wanted enabled for every session (Angel's request), unlike
# mcp-server-dev's "for a future need" -- no disable step here.
#
# `marketplace add` alone is not a reliable fix for a stale cache: verified
# live that if the global known-marketplaces manifest still has a record
# for "ponytail" but its clone directory is missing, `add` reports
# "already on disk" and skips re-cloning, leaving the plugin broken.
# `marketplace update` is what actually forces a real re-clone in that
# case (verified live) -- `add` is only needed once, to register the name
# at all in a container that has genuinely never seen it (verified live:
# `update` alone fails with "marketplace not found" if it was never
# added even once). So: add only if not yet known at all, then update only
# if the plugin isn't already showing enabled -- re-verifying state at
# each step rather than assuming either command worked.
if command -v claude >/dev/null 2>&1; then
  if ! claude plugin marketplace list 2>/dev/null | grep -qE '^\s*>\s*ponytail\s*$'; then
    timeout 90 claude plugin marketplace add DietrichGebert/ponytail --scope project >/dev/null 2>&1
  fi

  PONYTAIL_LIST="$(timeout 15 claude plugin list 2>/dev/null)"
  if ! printf '%s\n' "$PONYTAIL_LIST" | grep -A3 -E '^\s*>\s*ponytail@ponytail\s*$' | grep -q 'Status:.*enabled'; then
    timeout 90 claude plugin marketplace update ponytail >/dev/null 2>&1
    PONYTAIL_LIST="$(timeout 15 claude plugin list 2>/dev/null)"
  fi

  if printf '%s\n' "$PONYTAIL_LIST" | grep -A3 -E '^\s*>\s*ponytail@ponytail\s*$' | grep -q 'Status:.*enabled'; then
    echo "[session-start] ponytail plugin ready"
  else
    echo "[session-start] ponytail plugin not ready this session (non-blocking)"
  fi
else
  echo "[session-start] claude CLI not available - skipping ponytail plugin (non-blocking)"
fi

exit 0
