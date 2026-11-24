# Windows notes: python
- Install: `winget install Python.Python.3.14` (python.org build; tick "add to PATH"), `winget install astral-sh.uv`.
- The `python` alias may point to the Microsoft Store stub on fresh machines: check `Get-Command python` resolves to `...\Programs\Python\...`; disable the alias in Settings > Apps > Advanced app settings > App execution aliases.
- `py` launcher may be absent; use `python`.
- `uvx <tool>` runs CLI tools (ruff, etc.) without installing them globally.
