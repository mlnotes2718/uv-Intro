# ⚡ uv — Comprehensive Guide

`uv` is a blazing-fast Python package installer and environment manager written in Rust. It replaces `pip`, `pip-tools`, `venv`, and parts of `poetry` with a single tool that is 10–100× faster. It resolves, installs, and locks dependencies in one step and integrates cleanly with `pyproject.toml`.

---

## 📁 Project Structure

All uv projects contain the following files or folders:

| Path | Description |
|------|-------------|
| `pyproject.toml` | **The most important file.** Project configuration and dependencies. Cannot be lost. |
| `uv.lock` | Pins every transitive dependency for fully reproducible installs. Commit to source control. Created on first `uv sync` or `uv add`. |
| `.python-version` | Created by `uv init` (or manually via `uv python pin`) to lock the Python version. |
| `.venv/` | The virtual environment. Excluded from source control; created on first `uv sync` or `uv add`. |
| `.git/` | Git folder, created automatically unless `--bare` is used. |
| `.gitignore` | Created automatically by `uv init` (not created with `--bare`). |
| `README.md` | Created by default with `uv init` (not created with `--bare`). |

> **Note:** The `src/` folder layout is **not** created by the default `uv init`. It is only generated when using `--lib` or `--package` flags (see Project Setup below).

---

## 🔥 Installation & Maintenance

### Install uv

```bash
# macOS
brew install uv
```

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh
```

```bash
# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### Shell Autocompletion

```bash
echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc
```

### Update uv

```bash
# Check if uv was installed via brew
brew list

# For uv installed via brew
brew update && brew upgrade uv
```

```bash
# For uv installed via curl
uv self update
```

---

## 🐍 Python Management

### List & Install Versions

```bash
uv python list                    # List installed Python versions
uv python list --all-versions     # Show all available versions
uv python install 3.12            # Install Python 3.12 (latest patch)
uv python install 3.12.1          # Install a specific patch version
```

### Pin Python Version

```bash
uv python pin 3.11                # Creates a `.python-version` file in the project
```

---

## 🚀 Project Setup

### Initialize New Project

```bash
uv init <folder-name>                    # New application project (flat layout, creates main.py)
uv init <folder-name> --python 3.11      # New project with a specific Python version
uv init                                  # Initialize in the current folder
```

### Project Types

`uv init` supports different project types with distinct layouts:

| Command | Layout | Use Case |
|---------|--------|----------|
| `uv init` (default) | Flat — creates `main.py` in root | Scripts, applications, internal tools |
| `uv init --lib` | `src/<package>/` layout | Libraries intended for distribution |
| `uv init --package` | `src/<package>/` layout + build system | Packageable CLI tools / installable apps |
| `uv init --bare` | Only `pyproject.toml` | Minimal setup, no extras |

**Default (`uv init`) project structure** — 6 files/folders created immediately:
```
my-project/
├── .git/
├── .gitignore
├── .python-version
├── README.md
├── pyproject.toml
└── main.py
```
> `.venv/` and `uv.lock` are **not** created at init — they are generated the first time you run `uv sync` or `uv add`.

**Library / Package (`--lib` or `--package`) project structure:**
```
my-project/
├── .git/
├── .gitignore
├── .python-version
├── README.md
├── pyproject.toml
└── src/
    └── my_project/
        └── __init__.py
```
> Same rule applies: `.venv/` and `uv.lock` are created on first `uv sync` or `uv add`.

**Bare (`--bare`) project structure:**
```
my-project/
├── pyproject.toml
```
> `--bare` skips the Python version pin, README, source directories, and git initialization.

### Sync Environment

```bash
uv sync                                  # Ensures `.venv` matches `uv.lock`
uv sync --group docs                     # Also install a specific dependency group
uv sync --all-groups                     # Install all dependency groups
uv sync --no-dev                         # Install only main dependencies (no dev group)
```

---

## 📦 Package Management

### Add Packages

```bash
uv add <package-name>                    # Add to main [project.dependencies]
uv add --group dev pytest                # Add to the dev dependency group
uv add --group docs sphinx               # Add to a custom group
uv add ipykernel                         # Enables VS Code Jupyter notebook support
```

> **Note:** `uv add --dev` is a deprecated shorthand for `uv add --group dev`. Prefer `--group dev` explicitly.

### Remove Packages

```bash
uv remove <package-name>
```

---

## 🗂️ Dependency Groups (PEP 735)

Dependency groups let you organize dependencies by purpose (development, documentation, CI, etc.), separate from your main project dependencies.

### Key Concepts

- **`dev` group is special** — installed automatically by `uv sync` and `uv run`
- **Other groups** (`docs`, `test`, `ci`, etc.) — must be explicitly requested with `--group`
- **Not published to PyPI** — these are developer tools, not end-user features
- **Different from optional dependencies** — groups are for development tooling; optional dependencies are library features for end users

### Configuration in `pyproject.toml`

```toml
[project]
name = "my-project"
dependencies = [
    "requests",
    "pandas",
]

[dependency-groups]
dev = [
    "pytest",        # Auto-installed by uv sync
    "ruff",
    "mypy",
]
docs = [
    "sphinx",
    "mkdocs",
]
ci = [
    "coverage",
    "pytest-xdist",
]
```

### Common Commands

```bash
uv sync                           # Installs main deps + dev group
uv sync --group docs              # Installs main deps + dev + docs
uv sync --group ci                # Installs main deps + dev + CI tools
uv sync --all-groups              # Installs everything
uv sync --no-dev                  # Installs only main dependencies
uv sync --no-group docs           # Excludes a specific group
```

### Dependency Groups vs. Optional Dependencies

| Feature | Dependency Groups | Optional Dependencies |
|---------|-------------------|-----------------------|
| Purpose | Development tools | Library features for end users |
| Published to PyPI | ❌ No | ✅ Yes |
| Who uses them | Developers | End users of your library |
| When to use | Any project | Only when publishing a library |
| Examples | `pytest`, `ruff`, `sphinx` | `async`, `database`, `viz` |

---

## 📚 Optional Dependencies (Extras)

Optional dependencies are for **libraries published to PyPI**, allowing end users to install additional features as needed.

### Configuration in `pyproject.toml`

```toml
[project]
name = "my-library"
dependencies = ["requests", "pandas"]

[project.optional-dependencies]
excel    = ["openpyxl", "xlrd"]
database = ["sqlalchemy", "psycopg2"]
viz      = ["matplotlib", "seaborn"]
all      = ["openpyxl", "xlrd", "sqlalchemy", "psycopg2", "matplotlib", "seaborn"]
```

### How End Users Install

```bash
pip install my-library              # Basic (main deps only)
pip install my-library[excel]       # With Excel support
pip install my-library[excel,viz]   # Multiple extras
pip install my-library[all]         # Everything
```

---

## 🔄 Upgrading Packages

```bash
uv sync --upgrade                        # Upgrade all packages to latest compatible versions
uv lock --upgrade-package <package-name> # Upgrade a specific package
```

---

## 🏃 Execution

### Run Scripts

```bash
uv run main.py                               # Runs inside the managed venv (no activation needed)
uv run pytest                                # Run any tool managed by uv
uv run --no-dev main.py                      # Run without dev dependencies
uv run --with pandas script.py               # Run with a temporary package (not installed permanently)
uv run --with pandas --with numpy script.py  # Multiple temporary packages
```

`uv run` always executes inside the correct virtual environment — no need to activate it manually.

### Run Tools Without Installing

```bash
uvx ruff check .                         # Run a tool directly (like npx for Node)
uv tool run pytest                       # Alternative syntax
```

### Install Global Tools

```bash
uv tool install ruff                     # Install a CLI tool globally
uv tool install pytest                   # Makes the tool available system-wide
uv tool list                             # List all installed global tools
```

---

## 📂 Sharing & Deployment

### Files to Commit to Source Control

Share these three files to allow others to recreate your environment exactly:

1. `pyproject.toml` *(Recipients: change the `name` field for new projects)*
2. `uv.lock`
3. `.python-version`

**Recovery notes:**
- `.python-version` can be recreated with `uv python pin <version>` if you know the required version.
- `uv.lock` can be regenerated from `pyproject.toml` using `uv lock`, but resolved versions may differ (you'll get the latest compatible versions).
- `pyproject.toml` is the source of truth — never lose it.

### Installing from Shared Files

```bash
git clone <repo>
cd <repo>
uv sync                                  # Creates .venv and installs everything from uv.lock
```

### Export Requirements

```bash
uv export -o requirements.txt            # Export all dependencies (for pip compatibility)
uv export --no-dev -o requirements.txt   # Exclude dev dependencies (for production deployment)
```

---

## 🗂️ Cache Management

```bash
uv cache clean                           # Clear the uv package cache
uv cache dir                             # Show the cache directory location
```

---

## 🎯 Advanced: Platform-Specific Requirements

### Conditional Dependencies

Add platform-specific dependencies using environment markers:

```bash
uv add "torch; sys_platform == 'darwin' and platform_machine == 'arm64'"
```

### Limiting Resolution Environments

Use `environments` to **limit** which platforms uv resolves for (reduces scope):

```toml
[tool.uv]
environments = [
    "sys_platform == 'darwin'",
    "sys_platform == 'linux'",
]
```

Use case: your project only runs on specific platforms — no need to resolve for others.

### Required Environments

Use `required-environments` to **require** specific platform support (expands scope):

```toml
[tool.uv]
required-environments = [
    "sys_platform == 'darwin' and platform_machine == 'x86_64'",
    "sys_platform == 'darwin' and platform_machine == 'arm64'",
    "sys_platform == 'linux' and platform_machine == 'x86_64'",
]
```

Use case: ensure wheels exist for specific platforms (e.g., PyTorch). Resolution fails if required wheels are unavailable.

**Key Difference:**
- `environments` → **LIMITS** — "Only resolve for these platforms"
- `required-environments` → **EXPANDS** — "Must have wheels for these platforms"

---

## 🆚 uv vs. conda

| Concern | uv | conda |
|---------|----|-------|
| Speed | Very fast (Rust) | Slower |
| Python-only deps | Excellent | Good |
| C / CUDA / non-Python deps | Not supported | Native |
| Lock file | `uv.lock` | `environment.yml` |
| CI/CD simplicity | Excellent | Moderate |

**Rule of thumb:** Use `uv` unless a dependency requires conda (e.g. PyTorch with CUDA, OpenCV with system libs).

---

## 📋 Quick Reference

| Task | Command |
|------|---------|
| Install uv | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Update uv | `uv self update` |
| New project | `uv init <folder>` |
| New library project | `uv init <folder> --lib` |
| Add package | `uv add <package>` |
| Add dev package | `uv add --group dev <package>` |
| Remove package | `uv remove <package>` |
| Sync environment | `uv sync` |
| Upgrade all packages | `uv sync --upgrade` |
| Run script | `uv run script.py` |
| Run tool (no install) | `uvx <tool>` |
| Install tool globally | `uv tool install <tool>` |
| Export requirements | `uv export -o requirements.txt` |
| Clean cache | `uv cache clean` |

---

## 💡 Common Workflows

### Starting a New Application Project

```bash
uv init my-project --python 3.12
cd my-project
uv add pandas numpy
uv add --group dev pytest ruff
uv run main.py
```

### Starting a Library Project

```bash
uv init my-library --lib --python 3.12
cd my-library
uv add requests
uv add --group dev pytest ruff mypy
```

### Sharing a Project with Your Team

```bash
# Commit to source control:
#   pyproject.toml
#   uv.lock
#   .python-version

# Teammate onboarding:
git clone <repo>
cd <repo>
uv sync                              # Creates .venv and installs everything
```

### Quick Script with Temporary Dependencies

```bash
uv run --with requests --with beautifulsoup4 scraper.py
```

### Installing Global Development Tools

```bash
uv tool install ruff       # Linter / formatter
uv tool install pytest     # Test runner
uv tool install mypy       # Type checker
```

### Production Deployment (no dev tools)

```bash
uv sync --no-dev
uv export --no-dev -o requirements.txt
```

---

*Last updated: March 2026*
