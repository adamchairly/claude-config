# Claude config files

Repository for Claude Code skills and global configuration (`CLAUDE.md`).

Symlink this repo's contents into `~/.claude/` so Claude Code picks them up across all projects.

## Setup

1. Clone the repo
2. Run the setup script from the repo root

### Windows (PowerShell as Admin)

```powershell
.\setup.ps1
```

### macOS / Linux

```bash
./setup.sh
```

> Existing files at the target paths will be removed and replaced with symlinks.
