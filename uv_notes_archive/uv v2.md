# ⚡ uv Cheatsheet

All uv projects contain the following files or folders:
- `pyproject.toml`: this is the most important file.
- `uv.lock`: this file contains the specific version number for each package and its dependency.
- `.python-version`: this file only appears when we want to lock in to a specific python version.
- `.venv`: this folder contains the execution library. This folder is usually not sync to Github repository and it can be recreated using `uv sync`
- `.git`: this is git folder and it comes along when we initialized project.

**Important Notes**:
- All executables files and folders contained with the repository folder.
- Each repository contained its own requirements and dependency.


### 📥 Installation & Maintenance
- **Install uv:** `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **Update uv:** `uv self update`

### 🐍 Python Management
- **List versions:** `uv python list`
- **Install version:** `uv python install 3.12`
- **Pin version:** `uv python pin 3.11` *(Creates `.python-version` file)*

### 🚀 Project Setup
- **New project:** `uv init <folder-name>`
- **New with version:** `uv init <folder-name> --python 3.11`
- **Current folder:** `uv init`
- **Sync environment:** `uv sync` *(Ensures `.venv` matches `uv.lock`)*
- When project is initialized, git is also initialized if there is not git folder inside.
- To initialized project without git use `uv init --bare`

### 📦 Package Management
- **Add package:** `uv add <package-name>`
- **Remove package:** `uv remove <package-name>`
- **Notebook support:** `uv add ipykernel` *(Enables VS Code Jupyter support)*

### 🔄 Upgrading
- **Upgrade everything:** `uv sync --upgrade`
- **Upgrade specific pkg:** `uv lock --upgrade-package <package-name>`

### 🏃 Execution
- **Run script:** `uv run main.py` *(Auto-syncs dependencies before running)*
- **Run without project:** `uv run --with pandas script.py`

### 📂 Sharing (The "Lock-Only" Base)
Share these files to recreate the environment in a new project:
1. `pyproject.toml` *(Recipient: change the `name` field for new projects)*
2. `uv.lock`
3. `.python-version`

- The file `.python-version` can be recreated using `uv python pin <version>` if you know which Python version the project requires.
- If we lost the file `uv.lock` we can recreate the lock file using the command `uv lock` from `pyproject.toml`. The resolved versions might differ as we get the latest compatible versions based on the constraints in the `pyproject.toml` file.
- This file `pyproject.toml` cannot be lost.


### Setting Different Platform Requirement
```bash
uv init my-project
cd my-project
uv add "<package-name>; sys_platform == 'darwin' and platform_machine == 'x86_64'"
```


We can also add the following section in the toml file
```toml
[tool.uv]
required-environments = [
    "sys_platform == 'darwin' and platform_machine == 'x86_64'",
    "sys_platform == 'darwin' and platform_machine == 'arm64'",
    "sys_platform == 'linux' and platform_machine == 'x86_64'",
]
```
