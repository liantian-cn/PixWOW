"""Build every root-level Pix*/pix/__main__.py application for Windows x64.

Run: uv run --no-project --python 3.13 build.py
Requires uv and Visual Studio C++ build tools with a Windows SDK.
Distribute each entire dist/<project name>/ directory, not just its executable.
"""

from __future__ import annotations

import os
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import xml.etree.ElementTree as ET


NUITKA_VERSION = "4.2.2"
ROOT = Path(__file__).resolve().parent
BUILD_ERRORS = (OSError, RuntimeError, ValueError, subprocess.CalledProcessError, ET.ParseError)


def run(*arguments: str | Path, cwd: Path = ROOT, env: dict[str, str] | None = None) -> None:
    command = [str(argument) for argument in arguments]
    print(f"\n> {subprocess.list2cmdline(command)}", flush=True)
    subprocess.run(command, cwd=cwd, env=env, check=True)


def checked_path(path: Path, parent: Path) -> Path:
    """Never replace or remove a directory outside its intended parent."""
    resolved = path.resolve()
    if path.is_symlink() or path.is_junction() or not resolved.is_relative_to(parent.resolve()):
        raise RuntimeError(f"Unsafe build path: {path}")
    if resolved == parent.resolve():
        raise RuntimeError(f"Refusing to replace the parent directory: {path}")
    return path


def remove_directory(path: Path, parent: Path) -> None:
    checked_path(path, parent)
    if path.exists():
        shutil.rmtree(path)


def discover_projects(root: Path) -> list[Path]:
    return sorted(
        (path for path in root.iterdir()
         if path.is_dir() and path.name.startswith("Pix")
         and (path / "pix/__main__.py").is_file()),
        key=lambda path: path.name,
    )


def prepare_environment(uv: str, build: Path) -> Path:
    # Export once without changing the lock file or the development environment.
    environment = checked_path(build / ".venv", build)
    requirements = build / "requirements.txt"
    run(uv, "export", "--locked", "--no-dev", "--no-emit-project", "--no-header", "--quiet",
        "--output-file", requirements)
    python = environment / "Scripts/python.exe"
    if not python.is_file():
        run(uv, "venv", "--python", sys.executable, environment)
    run(python, "-c",
        "import struct, sys; assert sys.version_info[:2] == (3, 13) and struct.calcsize('P') == 8")
    run(uv, "pip", "install", "--python", python, "-r", requirements,
        f"Nuitka=={NUITKA_VERSION}")
    return python


def build_project(project: Path, python: Path, build: Path, dist: Path) -> None:
    name = project.name
    work_root = checked_path(build / "nuitka", build)
    work = checked_path(work_root / name, work_root)
    work.mkdir(parents=True, exist_ok=True)

    report = work / "compilation-report.xml"
    candidate = checked_path(work / f"{name}.dist", work)
    remove_directory(candidate, work)
    compile_env = os.environ.copy()
    compile_env.pop("PYTHONHOME", None)
    compile_env["PYTHONPATH"] = str(project)

    resource_dirs = [
        relative for relative in (Path("pix/assets"), Path("pix/lua"))
        if (project / relative).is_dir()
    ]
    resource_options = [
        f"--include-data-dir={project / relative}={relative.as_posix()}"
        for relative in resource_dirs
    ]
    icon = project / "pix/assets/app.ico"
    if icon.is_file():
        resource_options.append(f"--windows-icon-from-ico={icon}")

    run(
        python, "-m", "nuitka",
        "--mode=standalone", "--msvc=latest", "--enable-plugin=pyside6",
        # Native package entry mode preserves __package__ and pix-relative __file__.
        "--python-flag=-m",
        "--windows-console-mode=disable", "--windows-uac-admin",
        f"--output-dir={work}", f"--output-folder-name={name}.dist", f"--output-filename={name}.exe",
        *resource_options,
        f"--force-stdout-spec={{CACHE_DIR}}/{name}.stdout.log",
        f"--force-stderr-spec={{CACHE_DIR}}/{name}.stderr.log",
        "--assume-yes-for-downloads",
        f"--report={report}", project / "pix",
        cwd=project, env=compile_env,
    )

    if not (candidate / f"{name}.exe").is_file():
        raise RuntimeError("Nuitka did not produce the expected executable.")
    if not any(
        module.attrib.get("name") == "pix.__main__"
        and module.attrib.get("kind") == "PythonMainModule"
        for module in ET.parse(report).iter("module")
    ):
        raise RuntimeError("The entry module pix.__main__ was not compiled.")
    for relative in resource_dirs:
        for source in (project / relative).rglob("*"):
            if source.is_file():
                target = candidate / source.relative_to(project)
                if not target.is_file() or source.read_bytes() != target.read_bytes():
                    raise RuntimeError(f"Missing or altered resource: {source.relative_to(project)}")

    # Keep the last release until compilation and resource validation both succeed.
    release = checked_path(dist / name, dist)
    previous = checked_path(build / f"{name}.previous", build)
    # Recover an interrupted replacement before touching the only previous release.
    if previous.exists() and not release.exists():
        previous.rename(release)
    remove_directory(previous, build)
    had_release = release.exists()
    if had_release:
        release.rename(previous)
    try:
        candidate.rename(release)
    except OSError:
        if had_release:
            previous.rename(release)
        raise
    remove_directory(previous, build)
    print(f"\nBuilt: {release / (name + '.exe')}", flush=True)
    print(f"Distribute the entire directory: {release}")
    print(f"Compilation report: {report}")
    print(f"Runtime logs: %LOCALAPPDATA%/{name}.stdout.log and {name}.stderr.log")


def main() -> int:
    if sys.platform != "win32" or sys.version_info[:2] != (3, 13) or struct.calcsize("P") != 8:
        raise RuntimeError("Run with Windows x64 CPython 3.13: uv run --no-project --python 3.13 build.py")
    uv = shutil.which("uv")
    if uv is None:
        raise RuntimeError("uv must be installed and available on PATH.")
    for relative in ("pyproject.toml", "uv.lock"):
        if not (ROOT / relative).is_file():
            raise RuntimeError(f"Required root file is missing: {relative}")
    projects = discover_projects(ROOT)
    if not projects:
        raise RuntimeError("No root-level Pix*/pix/__main__.py applications found.")
    print("Projects: " + ", ".join(project.name for project in projects), flush=True)

    build = checked_path(ROOT / "build", ROOT)
    dist = checked_path(ROOT / "dist", ROOT)
    for directory in (build, dist):
        directory.mkdir(parents=True, exist_ok=True)
    python = prepare_environment(uv, build)

    results: list[tuple[str, str | None]] = []
    for project in projects:
        print(f"\n=== Building {project.name} ===", flush=True)
        try:
            build_project(project, python, build, dist)
        except BUILD_ERRORS as error:
            results.append((project.name, str(error)))
            print(f"\nBuild failed: {project.name}: {error}", file=sys.stderr, flush=True)
        else:
            results.append((project.name, None))

    print("\nBuild summary:", flush=True)
    for name, error in results:
        print(f"  FAILED {name}: {error}" if error is not None else f"  OK     {name}")
    return int(any(error is not None for _, error in results))


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except BUILD_ERRORS as error:
        print(f"\nBuild failed: {error}", file=sys.stderr)
        raise SystemExit(1)
