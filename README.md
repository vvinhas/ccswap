# ccswap

A CLI tool for managing multiple Claude Code accounts with shared customizations.

## Why ccswap?

Claude Code stores configuration, history, and customizations in `~/.claude`. If you use Claude Code with multiple Anthropic accounts (e.g., personal and work), you need separate configurations for each. ccswap lets you:

- **Switch accounts instantly** - No re-authentication needed
- **Share customizations** - Skills, commands, agents, and plugins work across all accounts
- **Isolate data** - Each account has its own history, projects, and settings

## Requirements

- macOS or Linux
- [jq](https://jqlang.github.io/jq/) - JSON processor
- Claude Code CLI installed (run it at least once before using ccswap)

Install jq:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq
```

## Installation

### Option 1: Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/vvinhas/ccswap/main/scripts/install.sh | bash
```

Then add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export PATH="$HOME/.ccswap/bin:$PATH"
```

Reload your shell:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

### Option 2: Clone Repository

```bash
git clone https://github.com/vvinhas/ccswap.git
cd ccswap
./bin/ccswap init
```

Then add `~/.ccswap/bin` to your PATH as shown above.

## Quick Start

```bash
# Initialize (links your existing ~/.claude as "main" account)
ccswap init

# Create additional accounts
ccswap add work

# Switch between accounts
ccswap use work    # Switch to work account
ccswap use main    # Switch back to main

# List all accounts (* marks active)
ccswap list

# Start Claude with active account
ccs
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `ccswap init` | Initialize ccswap (links ~/.claude as "main") |
| `ccswap add <name>` | Create a new account |
| `ccswap new <name>` | Alias for add |
| `ccswap use <name>` | Switch to an account |
| `ccswap remove <name>` | Remove an account (cannot remove main) |
| `ccswap list` | List all accounts |
| `ccswap --help` | Show help |
| `ccswap --version` | Show version |
| `ccs` | Launch Claude with active account |
| `ccs -fa <name>` | Launch Claude with specified account (one-time) |

### Launching Claude

Use `ccs` (Claude Code Session) instead of `claude` to launch Claude Code with your active account:

```bash
ccs                    # Start Claude Code
ccs --help             # Pass arguments to claude
ccs -p "explain this"  # Use with any claude flags
```

### One-Time Account Override

Use `--force-account` (or `-fa`) to run Claude with a specific account without switching:

```bash
ccs -fa personal              # Run with 'personal' account (once)
ccs --force-account work      # Run with 'work' account (once)
ccs -fa work --resume         # Combine with other claude flags
```

This doesn't change your active account—it's just for that session.

## How It Works

### Directory Structure

```
~/.ccswap/
├── config.json           # Active account and account list
├── bin/
│   ├── ccswap            # Account management script
│   └── ccs               # Claude launcher
└── accounts/
    ├── main -> ~/.claude # Your original config (symlink)
    └── work/             # Additional account
        ├── settings.json
        ├── projects/
        ├── skills -> ../main/skills
        ├── commands -> ../main/commands
        ├── agents -> ../main/agents
        └── plugins -> ../main/plugins
```

### Shared vs Account-Specific

**Shared** (symlinked to main account):
- `skills/` - Custom skills
- `commands/` - Custom commands
- `agents/` - Custom agents
- `plugins/` - Installed plugins

**Account-Specific** (isolated per account):
- `settings.json` - Permissions and preferences
- `projects/` - Project memory
- `todos/` - Task lists
- `cache/` - Cached data
- History and telemetry

### Environment Variable

`ccs` launches Claude with `CLAUDE_CONFIG_DIR` set to the active account's directory:

```bash
CLAUDE_CONFIG_DIR=~/.ccswap/accounts/work claude
```

## Troubleshooting

### "jq is required but not installed"

Install jq using the commands in the Requirements section above.

### "~/.claude not found"

Run Claude Code at least once before initializing ccswap:
```bash
claude --help
ccswap init
```

### "Cannot remove the main account"

The main account is your original `~/.claude` and cannot be removed. You can remove other accounts by switching away first:
```bash
ccswap use main
ccswap remove work
```

### Commands not found after installation

Ensure PATH is set correctly:
```bash
echo $PATH | grep -q ".ccswap/bin" && echo "OK" || echo "Add ~/.ccswap/bin to PATH"
```

## License

MIT
