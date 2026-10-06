# Repository Guidelines

## Role

Interview the user relentlessly until you reach a shared understanding. Map this as a design tree: every decision branches into the decisions that hang off it.

Work the tree in rounds. The frontier is every decision whose prerequisites are already settled: the questions you can ask now without guessing at answers you haven't heard yet. Ask the whole frontier in one round, then wait for the user's answers before the next round.

For each round, ask every question on the current frontier by actually calling the appropriate Codex question tool:
- In Plan mode, you MUST call `functions.request_user_input`.
- In other modes, you MUST call `functions.request_user_input_async` when available.
- Do not substitute questions or option lists in ordinary response text for a tool call. Merely naming the tool does not count as calling it.
- Respect the tool's question-count limit by splitting the current frontier into batches as needed. For each question, provide the available choices and always place your recommended answer as the first option.
- Wait for answers to all questions in the current round before asking dependent questions in the next round. An asynchronous tool returning immediately does not mean the user has answered.
- Only when neither question tool is available may you explain that limitation and ask the questions in ordinary response text.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a later round, not this one.

Finding facts is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), look it up yourself rather than asking the user. Prefer direct tools for simple searches and reads; use an explore sub-agent only when the investigation is complex, spans multiple files, or can usefully run in parallel. Don't block on a running exploration: it is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now.

The decisions are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.

## Implementation

After confirmation, make the smallest change that meets the requirement. Reuse the project's existing patterns and dependencies; avoid unrelated refactors, speculative abstractions, and unnecessary new dependencies.

Do not add tests for ordinary feature work. Validate with the most relevant existing tests, static checks, or build checks for the changed area; avoid unrelated full-suite runs unless needed.

When debugging, identify the failure and its cause before adding tests. Prefer reusing or adjusting existing tests; if new regression tests are needed, add only one or two focused cases tied to the failure. For non-bug changes with high impact or severe failure consequences, use judgment to add a few targeted tests when warranted, and briefly state why.

In a Git repository, before editing a file, make a backup commit of that file's existing uncommitted state (staged, unstaged, or untracked), if any. After editing, commit the resulting changes to that file if it changed. Keep both commits limited to the files being edited; do not include unrelated changes or staged files.

## Architecture & Project Structure

PixWOW contains five independent applications: `PixBlood`, `PixBeastMastery`, `PixHoly`, `PixProtection`, and `PixRetribution`. Each has its own `pix` Python package and WoW addon. Keep one rotation and one configuration per application; do not merge their code or introduce multiple rotation/configuration profiles within an application.

Paths below are relative to the selected application directory:

- `pix/capture.py`: screenshot algorithms and capture worker.
- `pix/matrix.py`: pixel decoding algorithms.
- `pix/context.py`: decoded state objects.
- `pix/keyboard.py`: keyboard driver.
- `pix/rotation.py`: user-authored rotation.
- `pix/action.py`: action objects and the sequential Action worker.
- `pix/ui.py`: complete PySide6 UI implementation.
- `pix/__main__.py`: application entry point; `pix/test_captura.py`: one-shot capture diagnostic.
- `pix/lua/`: WoW addon, including core initialization, UI, numbered cells, fonts, and textures.
- `.context/layout.md`: that application's pixel positions and meanings.

Preserve these module boundaries. Shared experience lives in the repository-root `.context`; specialization-specific documentation lives in each application's `.context`. This root AGENTS.md is the sole agent instruction entry point.

All applications' `.context/layout.md` files follow the shared [pixel layout document format](.context/development-principles.md#像素布局文档格式), using PixProtection as the format reference while preserving specialization-specific content.

Before changing an application, read its `README.md` and the relevant documents: `.context/layout.md` for pixels and decoding, `.context/keymap.md` for bindings and macro targets, and `.context/rotation.md` before analyzing, comparing, or modifying a rotation. Update those documents alongside behavior changes. Do not recreate child AGENTS.md files or a parallel docs directory.

Each application keeps `README.md`, `CHANGELOG.md`, and `banner.png` at its root. Its `.context` contains `layout.md`, `keymap.md`, `rotation.md`, and `banner.prompt.md`. Keep current rules and explanations there; do not add historical acceptance reports or migration logs. Historical shared experiments are not evidence of current validation.

## Specialization Rules

| Application | Specialization | Documentation |
| --- | --- | --- |
| PixBlood | Deathbringer Blood Death Knight | [Layout](PixBlood/.context/layout.md), [keymap](PixBlood/.context/keymap.md), [rotation](PixBlood/.context/rotation.md) |
| PixBeastMastery | Pack Leader Beast Mastery Hunter | [Layout](PixBeastMastery/.context/layout.md), [keymap](PixBeastMastery/.context/keymap.md), [rotation](PixBeastMastery/.context/rotation.md) |
| PixHoly | Herald of the Sun Holy Paladin | [Layout](PixHoly/.context/layout.md), [keymap](PixHoly/.context/keymap.md), [rotation](PixHoly/.context/rotation.md) |
| PixProtection | Lightsmith Protection Paladin | [Layout](PixProtection/.context/layout.md), [keymap](PixProtection/.context/keymap.md), [rotation](PixProtection/.context/rotation.md) |
| PixRetribution | Herald of the Sun Retribution Paladin | [Layout](PixRetribution/.context/layout.md), [keymap](PixRetribution/.context/keymap.md), [rotation](PixRetribution/.context/rotation.md) |

Install each application's `pix/lua/` into `Interface/AddOns/<application name>/`; preserve its matching `<application name>.toc` initialization order and independent saved configuration.

- PixBlood: retain the F12 reservation in its keymap and target/focus selection rules.
- PixBeastMastery: read its rotation document before every core DPS analysis, comparison, or change. Preserve user-confirmed Wild Thrash/Bestial Wrath rules; discuss core DPS separately from interrupts, defensive actions, and other non-DPS behavior.
- PixHoly: maintain the five-unit healing model (`player`, `party1`–`party4`), health scoring, and explicit target macros; do not derive current behavior from removed migration proposals.

## Development & Validation Commands

Use Windows, Python 3.13, PySide6, and uv. The root `pyproject.toml`, `uv.lock`, `.python-version`, and `.venv` are shared. Maintain dependencies at the repository root; do not add child project manifests or virtual environments.

From the repository root, replacing `PixBlood` with the selected application:

```powershell
uv sync --locked
uv run --locked --directory PixBlood pythonw -m pix
uv run --locked --directory PixBlood python -m pix.test_captura
uv run --locked pyright PixBlood/pix
uv run --locked --directory PixBlood python -m compileall -q pix
git diff --check
```

Run the GUI or capture diagnostic only when the task calls for it. For static validation, use Pyright and syntax checks without starting the application. Each application's working directory selects its own `pix`; never combine the five packages on one import path. Pyright's root configuration defines a separate execution environment for each application. In an application directory, `uv run pyright pix` and `uv run python -m compileall pix` use the shared environment.

No automated test framework, formatter, or linter is configured. Build all applications with root `build.ps1` or `uv run --no-project --python 3.13 build.py`. The root scripts discover direct child directories whose names start with case-sensitive `Pix` and contain `pix/__main__.py`; do not add child build scripts or a hardcoded project list. Builds use root locked runtime dependencies and Nuitka 4.2.2 in `build/.venv`, with isolated work and reports under `build/nuitka/<application name>/`. Distribute entire `dist/<application name>/` directories. Icons, assets, and Lua resources are optional; executable versions are not explicitly set. Failed projects retain their previous release while other builds continue; any failure produces a nonzero exit code. Building requires Windows x64 CPython 3.13 and Visual Studio C++ tools with a Windows SDK.

## Coding Style & Addon Validation

Use four-space indentation and LF line endings. Python uses `snake_case` functions/modules and `PascalCase` classes. Follow neighboring Lua conventions, share addon state through `addonTable`, preserve each TOC's initialization order, and retain numbered cell/icon filenames. Coordinate pixel changes across Lua, Python, and the selected application's `.context/layout.md`.

For addon validation, install the selected application's `pix/lua/` contents into its matching WoW `Interface/AddOns/<project name>/` directory and use `/reload` in game. Validate cell colors, layout, and state transitions when affected. No coverage threshold is configured.

## Project Skills

Use the repository skills for the matching task; each skill defines its scope and required references:

- [pixwow-docs-audit](.agents/skills/pixwow-docs-audit/SKILL.md): compare layout, keymap, and rotation documentation with current code.
- [pixwow-pixel-audit](.agents/skills/pixwow-pixel-audit/SKILL.md): compare each application's Lua layout/encoding with its own Python decoding and refresh behavior.
- [pixwow-rotation-develop](.agents/skills/pixwow-rotation-develop/SKILL.md): develop rotation rules and their supporting changes, then run independent review.
- [pixwow-rotation-review](.agents/skills/pixwow-rotation-review/SKILL.md): delegate a read-only rotation review to an independent subagent.
- [pixwow-debug](.agents/skills/pixwow-debug/SKILL.md): trace failures from Lua output through capture, decoding, rotation, and action execution.

Shared design rules live in the root `.context`: read [development principles](.context/development-principles.md), [code quality](.context/code-quality.md), and [WoW API and decoding notes](.context/wow-api-notes.md) as relevant before development or review. Keep their full rules there; skills link to them instead of maintaining duplicate copies. Respect confirmed fallback behavior and supported gameplay assumptions when classifying findings.

These skills share [project development and review rules](.agents/skills/pixwow-rotation-develop/references/project-rules.md), including business-branch comments and periodic refresh requirements. Existing code is not proof of compliance. Reviews report findings by default; fixes require a request that includes them. Rotation development includes independent subagent review, with historical issues reported separately from the current change.

## Commits & Pull Requests

Always work on the `develop` branch and commit changes there. The user will merge `develop` into `main` through the web interface when appropriate; do not merge into `main` yourself.

Use concise imperative commit subjects, optionally prefixed with `docs:` or `chore:`. Follow the file-scoped backup and result-commit rules above. PRs describe behavior changes, relevant issues, and validation performed; include screenshots for visible UI changes.
