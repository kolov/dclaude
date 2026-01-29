#!/bin/bash
# Start ssh-agent and load keys for libgit2-based tools (protofetch)
eval "$(ssh-agent -s)" > /dev/null 2>&1
ssh-add ~/.ssh/id_ed25519 2>/dev/null

exec claude "$@"
