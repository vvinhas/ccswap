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
curl -fsSL https://raw.githubusercontent.com/yourusername/ccswap/main/scripts/install.sh | bash
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
git clone https://github.com/yourusername/ccswap.git
cd ccswap
./bin/ccswap init
```

Then add `~/.ccswap/bin` to your PATH as shown above.

## Quick Start

```bash
# Create accounts
ccswap add work
ccswap add personal

# Switch between accounts
ccswap work      # Switch to work account
ccswap personal  # Switch to personal account

# List all accounts (* marks active)
ccswap list

# Start Claude with active account
ccs
```

If you have an existing `~/.claude` directory, run `ccswap init` to import it as an account.

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `ccswap init` | Initialize ccswap (first-time setup) |
| `ccswap add <name>` | Create a new account |
| `ccswap new <name>` | Alias for add |
| `ccswap remove <name>` | Remove an account |
| `ccswap <name>` | Switch to an account |
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
├── accounts/
│   ├── work/             # Work account config
│   │   ├── settings.json
│   │   ├── projects/
│   │   ├── skills -> ../../shared/skills
│   │   └── ...
│   └── personal/         # Personal account config
│       ├── settings.json
│       ├── projects/
│       ├── skills -> ../../shared/skills
│       └── ...
└── shared/
    ├── skills/           # Shared across all accounts
    ├── commands/         # Shared across all accounts
    └── plugins/          # Shared across all accounts
```

### Shared vs Account-Specific

**Shared** (symlinked across accounts):
- `skills/` - Custom skills
- `commands/` - Custom commands
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

## Importing Existing Configuration

During `ccswap init`, if `~/.claude` exists, you'll be prompted to import it:

```
Found existing ~/.claude. Import as account? (y/n): y
Account name [default]: personal
Importing ~/.claude as 'personal'...
Imported and set 'personal' as active account.
```

This copies your existing configuration and sets up shared resource symlinks.

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
