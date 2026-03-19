project_name := "uv_Intro"

# Returns 'uv' if the command is installed, otherwise 'conda'
env_type := shell('if [ -n "${CONDA_PREFIX:-}" ]; then echo "conda"; else echo "uv"; fi')

# Default: List commands
default:
    @echo "🚀 Detecting {{ env_type }} environment"
    @if [ "{{env_type}}" = "conda" ]; then \
        @echo "This project only works on uv environment. Exiting system..."; \
        exit 1; \
    fi
    @just --list

# Setup the environment
setup:
    @echo "🚀 Detecting {{env_type}} environment..."
    @if [ "{{env_type}}" = "uv" ]; then \
        uv sync; \
        uv run pre-commit install; \
    fi

## Start of development commands

# Check environment health
health:
    @echo "🩺 Checking {{env_type}} environment health..."
    @if [ "{{env_type}}" = "uv" ]; then \
        uv pip check; \
        uv sync; \
    fi

# Pre-commit hooks - Use this to run precommit first before committing
precommit:
    @echo "🔍  ({{env_type}}) Running pre-commit..."
    @if [ "{{env_type}}" = "uv" ]; then \
        uv run pre-commit run --all-files; \
    else \
        pre-commit run --all-files; \
    fi

# Remove build, cache, and coverage artifacts
clean:
    @echo "🧹 Cleaning up project..."
    rm -rf .pytest_cache
    rm -rf .coverage
    rm -rf htmlcov
    rm -rf .mypy_cache
    rm -rf .ruff_cache
    rm -rf .hypothesis
    find . -type d -name "__pycache__" -exec rm -rf {} +
    @echo "✨ Cleaned!"


# Run all checks
run: health clean
