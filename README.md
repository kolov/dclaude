# Claude Code in Docker

Run [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI inside a Docker container with access to local project directories.

## Prerequisites

Set the `ANTHROPIC_API_KEY` environment variable before running:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

## Build

```bash
docker build -t akolov/claude .
```

## Usage

```bash
./dclaude -v <folder> [-v <folder> ...] [-- <claude args>]
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

## Authentication

Claude Code stores auth credentials in the macOS Keychain, which is not available inside Docker. Instead, the `ANTHROPIC_API_KEY` environment variable is used. The script will fail if it is not set.

A `~/.claude-docker.json` file is created on first run to skip the onboarding/login prompt. This file persists between sessions, so any settings Claude Code writes to it (e.g. plugins) are retained.
