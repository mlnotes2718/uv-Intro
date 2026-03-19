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
uv add --dev pytest                      # Add to dev dependencies (deprecated, use --group dev)
uv add --group docs sphinx               # Add to specific group
uv add ipykernel                         # Enables VS Code Jupyter support
```

### Remove Packages
```bash
uv remove <package-name>
```

---

## 🗂️ Dependency Groups (PEP 735)

Dependency groups let you organize dependencies for different purposes (development, documentation, testing, etc.) separate from your main project dependencies.

### Key Concepts

- **`dev` group is SPECIAL** - Installed automatically by `uv sync` and `uv run`
- **Other groups** (like `docs`, `test`, etc.) - Must be explicitly installed with `--group`
- **Not published to PyPI** - These are for developers, not end users
- **Different from optional dependencies** - Groups are for development tools, optionals are for library features

### Configuration in `pyproject.toml`

```toml
[project]
name = "my-project"
dependencies = [
    "requests",      # Main project dependencies
    "pandas",
]

[dependency-groups]
dev = [
    "pytest",        # Testing tools (auto-installed)
    "ruff",          # Linting
    "mypy",          # Type checking
]

docs = [
    "sphinx",        # Documentation tools
    "mkdocs",
]

test = [
    "pytest-cov",    # Extra testing tools
    "hypothesis",
]

ci = [
    "coverage",      # CI-specific tools
    "pytest-xdist",
]
```

### Common Commands

```bash
# Add to dev group (auto-installed)
uv add --group dev pytest

# Add to docs group
uv add --group docs sphinx

# Add to custom group
uv add --group test pytest-cov

# Install everything (project deps + dev group only)
uv sync

# Install specific group
uv sync --group docs

# Install multiple groups
uv sync --group docs --group test

# Install all groups
uv sync --all-groups

# Exclude dev group (install only project deps)
uv sync --no-dev

# Exclude a specific group
uv sync --no-group docs
```

### Real-World Example

```toml
[project]
name = "web-scraper"
dependencies = [
    "requests>=2.31.0",
    "beautifulsoup4>=4.12.0",
]

[dependency-groups]
dev = [
    "pytest>=8.0.0",
    "ruff>=0.3.0",
    "mypy>=1.8.0",
]

docs = [
    "sphinx>=7.0.0",
    "sphinx-rtd-theme>=2.0.0",
]

ci = [
    "coverage>=7.4.0",
    "pytest-xdist>=3.5.0",
]
```

### Usage Patterns

```bash
# Developer working on code
uv sync                           # Gets: main deps + dev tools

# Building documentation locally
uv sync --group docs              # Gets: main deps + dev + docs tools

# Running in CI/CD
uv sync --group ci                # Gets: main deps + dev + CI tools

# Production deployment (no dev tools)
uv sync --no-dev                  # Gets: only main dependencies
```

### Dependency Groups vs Optional Dependencies

| Feature | Dependency Groups | Optional Dependencies |
|---------|-------------------|----------------------|
| **Purpose** | Development tools | Library features for end users |
| **Published to PyPI** | ❌ No | ✅ Yes |
| **Who uses** | Developers | End users of your library |
| **When to use** | Any project | Only when publishing a library |
| **Example** | `pytest`, `ruff`, `sphinx` | `async`, `database`, `viz` |

**Use Dependency Groups for:**
- Development dependencies (testing, linting, formatting)
- Documentation tools
- CI/CD specific tools
- Any project type (applications or libraries)

**Use Optional Dependencies for:**
- Publishing a library to PyPI
- Optional features users can install
- Different backends/implementations
- See "Optional Dependencies" section below for details

---

## 📚 Optional Dependencies (Extras)

Optional dependencies are for **libraries published to PyPI**. They allow end users to install additional features as needed.

### When to Use Optional Dependencies

**✅ Use when:**
- Publishing a library/package to PyPI
- Offering optional features that require extra dependencies
- Supporting multiple backends or implementations
- Platform-specific features

**❌ Don't use when:**
- Building an application (not a library)
- Just need dev tools (use dependency groups instead)

### Configuration in `pyproject.toml`

```toml
[project]
name = "my-library"
dependencies = ["requests", "pandas"]

[project.optional-dependencies]
# Feature-based extras
excel = ["openpyxl", "xlrd"]           # Excel file support
database = ["sqlalchemy", "psycopg2"]   # Database support
viz = ["matplotlib", "seaborn"]         # Visualization

# Backend options
async = ["aiohttp", "asyncio"]          # Async implementation
sync = ["requests"]                     # Sync implementation (default)

# Performance optimization
fast = ["cython", "ujson"]              # Faster implementations

# Convenience: install everything
all = [
    "openpyxl", "xlrd",
    "sqlalchemy", "psycopg2",
    "matplotlib", "seaborn",
    "aiohttp", "asyncio",
    "cython", "ujson",
]
```

### How End Users Install

```bash
# Basic installation (only main dependencies)
pip install my-library

# With Excel support
pip install my-library[excel]

# Multiple extras
pip install my-library[excel,database]

# Everything
pip install my-library[all]
```

### Real-World Examples

#### Example 1: Data Processing Library
```toml
[project]
name = "data-processor"
dependencies = ["pandas", "numpy"]

[project.optional-dependencies]
excel = ["openpyxl>=3.0.0"]
parquet = ["pyarrow>=10.0.0"]
sql = ["sqlalchemy>=2.0.0"]
all = ["openpyxl>=3.0.0", "pyarrow>=10.0.0", "sqlalchemy>=2.0.0"]
```

#### Example 2: ML Framework
```toml
[project]
name = "ml-framework"
dependencies = ["numpy", "scikit-learn"]

[project.optional-dependencies]
tensorflow = ["tensorflow>=2.13.0"]
pytorch = ["torch>=2.0.0"]
jax = ["jax>=0.4.0"]
```

#### Example 3: Web Framework
```toml
[project]
name = "web-framework"
dependencies = ["click", "jinja2"]

[project.optional-dependencies]
security = ["cryptography>=41.0.0"]
async = ["aiohttp>=3.9.0", "uvloop>=0.19.0"]
dev = ["pytest>=8.0.0", "black>=24.0.0"]  # Note: better as dependency group
```

### Complete Example: Library vs Application

#### ✅ Library (Publishing to PyPI)
```toml
[project]
name = "awesome-scraper"  # Will be published
dependencies = ["requests", "beautifulsoup4"]

# For end users to choose features
[project.optional-dependencies]
async = ["aiohttp", "asyncio"]
js = ["selenium"]
fast = ["lxml"]
all = ["aiohttp", "asyncio", "selenium", "lxml"]

# For developers working on the library
[dependency-groups]
dev = ["pytest", "ruff", "mypy"]
docs = ["sphinx", "mkdocs"]
```

**End users:**
```bash
pip install awesome-scraper[async]  # Install with async support
```

**Developers:**
```bash
uv sync --group docs  # Install dev tools + docs
```

#### ❌ Application (Not Publishing)
```toml
[project]
name = "my-web-app"  # Just for internal use
dependencies = ["flask", "sqlalchemy", "redis"]

# No optional-dependencies needed!

# Just use dependency groups
[dependency-groups]
dev = ["pytest", "ruff"]
docs = ["sphinx"]
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
