# Stack adapter: python
Verified: 2026-11-24 on Windows 11 - Python 3.14.6 (python.org installer, on PATH as `python`), uv 0.13.5, ruff 0.17.6 via `uvx`. Also used live in devsys Phase 2 sample apps.

## Defaults (zero install)
- Tests: stdlib `unittest`, files `tests/test_*.py`. Switch to pytest only if the project needs fixtures/plugins (`uv add --dev pytest`, then `uv run pytest -q`).
- Layout: small tools = one module + `tests/`; packages = `src/<pkg>/` (tests add `src` to `sys.path`, or use `uv` project with `uv run`).
- Dependencies: stdlib first. If third-party is needed: `uv init` + `uv add <pkg>`; run everything through `uv run`.

## Commands (devsys.json)
| key | command |
|-----|---------|
| test | `python -m unittest discover -s tests -q` |
| check | `python -m unittest discover -s tests -q` (add `; uvx ruff check .` once the code is lint-clean) |
| format | `uvx ruff format "{file}"` (first run downloads ruff into the uv cache) |
| run | `python <entry>.py` or `python -m <pkg>`; ship a `<name>.cmd` launcher: `@echo off` + `python "%~dp0<entry>.py" %*` |
| one test | `python -m unittest tests.test_x.TestCase.test_name` |

Exit codes: unittest returns 1 on failure, and propagates through `powershell -Command` (the Stop hook) correctly.
