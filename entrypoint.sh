#!/bin/bash
# Start ssh-agent and load keys for libgit2-based tools (protofetch)
eval "$(ssh-agent -s)" > /dev/null 2>&1
ssh-add ~/.ssh/id_ed25519 2>/dev/null

# If OAuth credentials are provided, inject them into the GNOME Keyring
# so Claude Code can find them via its normal keytar/libsecret lookup.
if [ -n "$CLAUDE_OAUTH_CREDENTIALS" ]; then
  eval "$(dbus-launch --sh-syntax)" > /dev/null 2>&1
  echo "" | gnome-keyring-daemon --unlock --components=secrets > /dev/null 2>&1

  echo -n "$CLAUDE_OAUTH_CREDENTIALS" | secret-tool store \
    --label="Claude Code Credentials" \
    service "Claude Code-credentials" \
    account "${CLAUDE_OAUTH_ACCOUNT:-default}"

  # Don't leak credentials into the process environment
  unset CLAUDE_OAUTH_CREDENTIALS CLAUDE_OAUTH_ACCOUNT
fi

exec claude "$@"
