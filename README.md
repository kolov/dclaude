# Claude Code in Docker

Run [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI inside a Docker container with access to local project directories. Reuses your Claude Max subscription — no separate API billing needed.

## Prerequisites

No additional setup is needed if you are logged into Claude Code on your Mac. The script automatically extracts your OAuth credentials from the macOS Keychain, allowing you to **reuse your Claude Max subscription** inside the container without separate API billing.

Alternatively, you can set the `ANTHROPIC_API_KEY` environment variable to use API key authentication instead (billed separately from Max):

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

## Build

```bash
./build              # defaults to akolov/claude
./build my-tag       # custom image tag
```

This fetches the latest Claude Code version from npm and builds the image.

## Usage

Recommended: make the script available, e.g in `fish`:

```bash
function dclaude 
      {absolute_path}/dclaude $argv
end
  
funcsave dclaude
```
then run it from your project, giving access to needed folders with `-v`:

```bash
dclaude -v <folder> [-v <folder> ...] [-- <claude args>]
dclaude -v projects -- --dangerously-skip-permissions
```

Folders are relative to `$HOME` and mounted at `/home/claude/<folder>`.

### Examples

```bash
# Mount cx and ak directories
./dclaude -v cx -v ak

# Mount folders and pass args to claude
./dclaude -v cx -v ak -- --help

# Mount a single folder
./dclaude -v cx
```

The working directory inside the container is automatically mapped from the host's current directory. For example, running from `~/cx/project1` sets the container working directory to `/home/claude/cx/project1`.

## Mounted Volumes

| Host Path | Container Path | Purpose |
|---|---|---|
| `~/<folder>` (via `-v`) | `/home/claude/<folder>` | Project files |
| `~/.claude` | `/home/claude/.claude` | Claude config & history |
| `~/.claude-docker.json` | `/home/claude/.claude.json` | Onboarding state (persisted) |
| `~/.gitconfig` | `/home/claude/.gitconfig` | Git config (read-only) |
| `~/.ssh` | `/home/claude/.ssh` | SSH keys for git (read-only) |
| `~/.dclaude-cargo-target` | `/home/claude/.cargo-target` | Cargo build cache (persisted) |

## Authentication

The script supports two authentication methods, checked in this order:

1. **`ANTHROPIC_API_KEY` env var** — if set, passed directly to the container. Uses API billing.
2. **macOS Keychain (OAuth)** — if no API key is set, the script extracts OAuth credentials from the macOS Keychain. This reuses your existing Claude Max subscription, so no separate API credits are needed. The credentials are written to a plaintext file inside the container (`~/.claude/.credentials.json`) that Claude Code reads on Linux.

A `~/.claude-docker.json` file is created on first run to skip the onboarding/login prompt. This file persists between sessions.

## Cargo Build Cache

Cargo builds use a separate target directory at `~/.dclaude-cargo-target` on the host to persist compiled artifacts between sessions. This avoids recompiling dependencies on every run.

To clean the cache:

```bash
rm -rf ~/.dclaude-cargo-target
```
