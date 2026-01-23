# ccswap

A CLI tool for managing multiple Claude Code accounts with shared customizations.

## Why ccswap?

Claude Code stores configuration, history, and customizations in `~/.claude`. If you use Claude Code with multiple Anthropic accounts (e.g., personal and work), you need separate configurations for each. ccswap lets you:

- **Switch accounts instantly** - No re-authentication needed
- **Share customizations** - Skills, commands, and plugins work across all accounts
- **Isolate data** - Each account has its own history, projects, and settings

## Requirements

- macOS or Linux
- [jq](https://jqlang.github.io/jq/) - JSON processor
- Claude Code CLI installed

Install jq on macOS:
```bash
brew install jq
```

## Installation

### Quick Install (Recommended)

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

### Alternative: Clone Repository

```bash
git clone https://github.com/vvinhas/ccswap.git
cd ccswap
./bin/ccswap init
```

Then add `~/.ccswap/bin` to your PATH as shown above.

## Quick Start

```bash
# Initialize (requires ~/.claude to exist)
ccswap init

# Create accounts
ccswap add work
ccswap add personal

# Switch between accounts
ccswap use work      # Switch to work account
ccswap use personal  # Switch to personal account

# List all accounts (* marks active)
ccswap list

# Start Claude with active account
ccs
```

When you first run `ccs` with a new account, Claude will prompt you to authenticate. This creates the account's `.claude.json` with your OAuth credentials.

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `ccswap init` | Initialize ccswap (first-time setup) |
| `ccswap add <name>` | Create a new account |
| `ccswap new <name>` | Alias for add |
| `ccswap remove <name>` | Remove an account |
| `ccswap use <name>` | Switch to an account |
| `ccswap list` | List all accounts |
| `ccswap --help` | Show help |
| `ccswap --version` | Show version |

### Launching Claude

Use `ccs` instead of `claude` to launch Claude Code with your active account:

```bash
ccs                    # Start Claude Code
ccs --help             # Pass arguments to claude
ccs -p "explain this"  # Use with any claude flags
```

### Optional: Replace `claude` with `ccs`

If you want to use `claude` directly with ccswap, add this alias to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
alias claude="ccs"
```

After reloading your shell (`source ~/.zshrc`), running `claude` will automatically use your active ccswap account.

## How It Works

### Directory Structure

```
~/.ccswap/
├── config.json           # Active account and account list
├── bin/
│   ├── ccswap            # Account management script
│   └── ccs               # Claude launcher
└── accounts/
    ├── main -> ~/.claude # Main account (symlink to original config)
    ├── work/             # Work account config
    │   ├── .claude.json  # OAuth credentials (created on first login)
    │   ├── settings.json
    │   ├── projects/
    │   ├── skills -> ../main/skills
    │   └── ...
    └── personal/         # Personal account config
        ├── .claude.json  # OAuth credentials (created on first login)
        ├── settings.json
        ├── projects/
        ├── skills -> ../main/skills
        └── ...
```

### Shared vs Account-Specific

**Shared** (symlinked to main account):
- `skills/` - Custom skills
- `commands/` - Custom commands
- `plugins/` - Installed plugins
- `agents/` - Custom agents

**Account-Specific** (isolated per account):
- `.claude.json` - OAuth credentials (created fresh on first login)
- `settings.json` - Permissions and preferences (optionally linked to main)
- `projects/` - Project memory
- `todos/` - Task lists
- `cache/` - Cached data
- History and telemetry

### Environment Variable

`ccs` launches Claude with `CLAUDE_CONFIG_DIR` set to the active account's directory:

```bash
CLAUDE_CONFIG_DIR=~/.ccswap/accounts/work claude
```

## How Main Account Works

When you run `ccswap init`, your existing `~/.claude` directory becomes the "main" account via symlink. This preserves your current configuration and makes shared resources (skills, commands, plugins) available to all accounts.

New accounts created with `ccswap add <name>` get:
- Symlinks to main's shared directories (skills, commands, plugins, agents)
- Their own `.claude.json` (created by Claude on first login - you'll need to authenticate)
- Optionally, a symlink to main's settings.json

## Troubleshooting

### "jq is required but not installed"

Install jq:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq

# Fedora
sudo dnf install jq
```

### "ccswap not initialized"

Run the init command:
```bash
ccswap init
```

### "Cannot remove active account"

Switch to another account first:
```bash
ccswap other-account
ccswap remove account-to-delete
```

### Commands not found after installation

Ensure PATH is set correctly:
```bash
echo $PATH | grep -q ".ccswap/bin" && echo "OK" || echo "Add ~/.ccswap/bin to PATH"
```

## License

MIT
