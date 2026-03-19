# ⚡ uv Cheatsheet

All uv projects contain the following files or folders:
- `pyproject.toml`: this is the most important file (project configuration and dependencies).
- `uv.lock`: this file contains the specific version number for each package and its dependency.
- `.python-version`: this file only appears when we want to lock in to a specific python version.
- `.venv`: this folder contains the virtual environment. This folder is usually not synced to Github repository and can be recreated using `uv sync`.
- `src/`: this folder contains your project's source code (created by default with `uv init`).
- `README.md`: project documentation file (created by default with `uv init`).
- `.git`: this is git folder and it comes along when we initialized project (unless `--no-git` is used).

**Important Notes**:
- All executables files and folders are contained within the repository folder.
- Each repository contains its own requirements and dependencies.
- The `src/` folder and `README.md` are NOT created when using `uv init --bare`.

---

## 🔥 Installation & Maintenance

### Install uv
```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### Update uv
```bash
uv self update
```

---

## 🐍 Python Management

### List & Install Versions
```bash
uv python list                    # List installed versions
uv python list --all-versions     # Show all available versions
uv python install 3.12            # Install Python 3.12 (latest patch)
uv python install 3.12.1          # Install specific patch version
```

### Pin Python Version
```bash
uv python pin 3.11                # Creates `.python-version` file
```

---

## 🚀 Project Setup

### Initialize New Project
```bash
uv init <folder-name>                    # New project with git
uv init <folder-name> --python 3.11      # New project with specific Python version
uv init                                  # Initialize in current folder
```

### Git Initialization Options
```bash
uv init my-project                       # Default: Creates project WITH git repository
uv init my-project --no-git              # Creates project WITHOUT initializing git
uv init my-project --bare                # Minimal setup: no src/ directory, no git, no README
```

**Key Differences:**
- **Default (`uv init`)**: Full project structure with `src/` directory, git initialized, README.md created
- **`--no-git`**: Same as default but skips git initialization (useful if you'll add to existing repo)
- **`--bare`**: Minimal setup - only creates `pyproject.toml` and `.python-version`, no `src/` folder, no git, no README

### Sync Environment
```bash
uv sync                                  # Ensures `.venv` matches `uv.lock`
uv sync --group docs                     # Install specific dependency group
```

---

## 📦 Package Management

### Add Packages
```bash
uv add <package-name>                    # Add to dependencies
uv add --dev pytest                      # Add to dev dependencies
uv add --group docs sphinx               # Add to specific group
uv add ipykernel                         # Enables VS Code Jupyter support
```

### Remove Packages
```bash
uv remove <package-name>
```

---

## 🔄 Upgrading

### Upgrade Packages
```bash
uv sync --upgrade                        # Upgrade all packages
uv lock --upgrade-package <package-name> # Upgrade specific package
```

---

## 🏃 Execution

### Run Scripts
```bash
uv run main.py                           # Auto-syncs dependencies before running
uv run --with pandas script.py           # Run with temporary package (no install)
uv run --with pandas --with numpy script.py  # Multiple temporary packages
```

### Run Tools (without installing)
```bash
uvx ruff check .                         # Run tool directly (like npx)
uv tool run pytest                       # Alternative syntax
```

### Install Global Tools
```bash
uv tool install ruff                     # Install CLI tool globally
uv tool install pytest                   # Makes tool available system-wide
uv tool list                             # List installed tools
```

---

## 📂 Sharing & Deployment

### Files to Share (Recreate Environment)
Share these files to recreate the environment in a new project:
1. `pyproject.toml` *(Recipient: change the `name` field for new projects)*
2. `uv.lock`
3. `.python-version`

**Recovery Notes:**
- The file `.python-version` can be recreated using `uv python pin <version>` if you know which Python version the project requires.
- If we lost the file `uv.lock` we can recreate it using `uv lock` from `pyproject.toml`. The resolved versions might differ as we get the latest compatible versions.
- The file `pyproject.toml` cannot be lost - it's the source of truth.

### Installing from Shared Files
```bash
# Recipient runs this after getting the files
uv sync                                  # Installs everything from uv.lock
```

### Export Requirements
```bash
uv export -o requirements.txt            # Export all dependencies
uv export --no-dev -o requirements.txt   # Export without dev dependencies (for deployment)
```

---

## 🗂️ Cache Management

```bash
uv cache clean                           # Clear cache
uv cache dir                             # Show cache location
```

---

## 🎯 Advanced: Platform-Specific Requirements

### Conditional Dependencies
Add platform-specific dependencies using markers:
```bash
uv init my-project
cd my-project
uv add "torch; sys_platform == 'darwin' and platform_machine == 'arm64'"
```

### Limiting Resolution Environments (REDUCE support)
Use `environments` to **limit** which platforms uv will solve for (reduces the set):
```toml
[tool.uv]
environments = [
    "sys_platform == 'darwin'",    # Only solve for macOS
    "sys_platform == 'linux'",     # and Linux (ignore Windows)
]
```

**Use case:** Your project only runs on specific platforms, so you don't need to solve for others.

### Required Environments (EXPAND requirements)
Use `required-environments` to **require** specific platform support (expands requirements):
```toml
[tool.uv]
required-environments = [
    "sys_platform == 'darwin' and platform_machine == 'x86_64'",  # Require Intel macOS support
    "sys_platform == 'darwin' and platform_machine == 'arm64'",   # Require Apple Silicon support
]
```

**Use case:** For packages without source distributions (like PyTorch), ensure they have wheels for specific platforms. Resolution will fail if required wheels are not available.

**Key Difference:**
- `environments` = **LIMITS** → "Only solve for these platforms"
- `required-environments` = **EXPANDS** → "Must have wheels for these platforms"

---

## 📋 Quick Reference

| Task | Command |
|------|---------|
| Install uv | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Update uv | `uv self update` |
| New project | `uv init <folder>` |
| Add package | `uv add <package>` |
| Add dev package | `uv add --dev <package>` |
| Remove package | `uv remove <package>` |
| Sync environment | `uv sync` |
| Run script | `uv run script.py` |
| Run tool | `uvx <tool>` |
| Install tool globally | `uv tool install <tool>` |
| Upgrade all | `uv sync --upgrade` |
| Export requirements | `uv export -o requirements.txt` |
| Clean cache | `uv cache clean` |

---

## 💡 Common Workflows

### Starting a New Project
```bash
uv init my-project --python 3.12
cd my-project
uv add pandas numpy
uv add --dev pytest ruff
uv run main.py
```

### Sharing Project with Team
```bash
# Developer 1: Share these files
# - pyproject.toml
# - uv.lock
# - .python-version

# Developer 2: Clone and setup
git clone <repo>
cd <repo>
uv sync                              # Creates .venv and installs everything
```

### Quick Script with Dependencies
```bash
uv run --with requests --with beautifulsoup4 scraper.py
```

### Installing Global Development Tools
```bash
uv tool install ruff                 # Linter/formatter
uv tool install pytest               # Testing
uv tool install black                # Code formatter
uv tool install mypy                 # Type checker
```

---

**Last Updated:** February 2025
