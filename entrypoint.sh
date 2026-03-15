#!/bin/bash
# Start ssh-agent and load keys for libgit2-based tools (protofetch)
eval "$(ssh-agent -s)" > /dev/null 2>&1
ssh-add ~/.ssh/id_ed25519 2>/dev/null

# If OAuth credentials are provided, write them to the plaintext credential
# file that Claude Code uses as fallback on Linux (no keychain available).
if [ -n "$CLAUDE_OAUTH_CREDENTIALS" ]; then
  mkdir -p ~/.claude
  echo -n "$CLAUDE_OAUTH_CREDENTIALS" > ~/.claude/.credentials.json
  chmod 600 ~/.claude/.credentials.json
  unset CLAUDE_OAUTH_CREDENTIALS
fi

exec claude "$@"
