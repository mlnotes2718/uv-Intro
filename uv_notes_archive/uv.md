# uv — Package & Environment Management

## What It Does

`uv` is a blazing-fast Python package installer and environment manager written in Rust. It replaces `pip`, `pip-tools`, `venv`, and parts of `poetry` with a single tool that is 10–100× faster. It resolves, installs, and locks dependencies in one step and integrates cleanly with `pyproject.toml`.

This project uses `uv` as the primary environment manager, falling back to conda only when required (e.g. CUDA-dependent packages).

---

## Installation

```bash
brew install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
```

---

## Key Commands

### Environment setup

```bash
uv sync                    # Install all deps from pyproject.toml (creates .venv if needed)
uv sync --group dev        # Include dev dependencies
```

### Running code

```bash
uv run python src/main.py  # Run inside the managed venv
uv run pytest              # Run any tool managed by uv
```

`uv run` ensures the command always executes inside the correct virtual environment — no need to activate it manually.

### Adding / removing packages

```bash
uv add requests            # Add to [project.dependencies]
uv add --dev pytest        # Add to [dependency-groups] dev
uv remove requests         # Remove a package
```

### Lockfile

```bash
uv lock                    # Regenerate uv.lock from pyproject.toml
uv sync                    # Apply the lockfile to the environment
```

The `uv.lock` file pins every transitive dependency for fully reproducible installs. Commit it to source control.

### Environment health

```bash
uv pip check               # Verify no dependency conflicts
```

---

## pyproject.toml integration

```toml
[project]
requires-python = ">=3.11"
dependencies = [
    "pandas>=3.0.1",
    "requests>=2.32.5",
]

[dependency-groups]
dev = [
    "pytest>=9.0.2",
    "ruff>=0.15.2",
    # ...
]
```

`uv sync` reads this file and builds an isolated `.venv/` automatically.

---

## uv vs conda

| Concern | uv | conda |
|---|---|---|
| Speed | Very fast (Rust) | Slower |
| Python-only deps | Excellent | Good |
| C/CUDA/non-Python deps | Not supported | Native |
| Lock file | `uv.lock` | `environment.yml` |
| CI/CD simplicity | Excellent | Moderate |

**Rule of thumb:** use `uv` unless a dependency requires conda (e.g. PyTorch with CUDA, opencv with system libs).

---

## Upgrade Path to Grype

When moving to containers, replace `pip-audit` with Grype:

```bash
# Install grype
brew install anchore/grype/grype   # macOS
# or
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh

# Scan the uv environment
grype dir:.venv
# Scan a Docker image
grype my-image:latest
```

Grype scans OS packages, Python packages, and container layers — giving deeper coverage than `pip-audit` alone.
