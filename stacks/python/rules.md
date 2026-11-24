---
paths: ["**/*.py"]
---
- Windows 11: use `pathlib`, never hard-coded `/` paths; open text files with `encoding="utf-8"` explicitly (default is the ANSI code page).
- Default data/config locations: `%APPDATA%\<app>` or `%LOCALAPPDATA%\<app>` via `os.environ`, with an env-var override so tests use temp dirs.
- Tests never touch real user folders; use `tempfile.TemporaryDirectory()`.
- Write files atomically (write temp file, then `os.replace`). `os.rename` fails if the target exists on Windows; `os.replace` overwrites.
- Console output: avoid non-ASCII symbols in CLI output unless `sys.stdout.reconfigure(encoding="utf-8")` is set.
- Stdlib first; any third-party dependency needs a reason in the plan.
