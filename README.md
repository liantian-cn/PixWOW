# PixWOW

五个独立的魔兽世界像素项目，共用 Python 3.13 开发环境与仓库规范。各项目的 Python、Lua、配图和使用说明保留在自己的目录内。

| 项目 | 专精 | 像素布局 |
| --- | --- | --- |
| [PixBlood](PixBlood/README.md) | 鲜血死亡骑士 | [layout](PixBlood/.context/layout.md) |
| [PixBeastMastery](PixBeastMastery/README.md) | 兽王猎人 · 群兽领袖 | [layout](PixBeastMastery/.context/layout.md) |
| [PixHoly](PixHoly/README.md) | 神圣圣骑士 · 烈日先驱 | [layout](PixHoly/.context/layout.md) |
| [PixProtection](PixProtection/README.md) | 防护圣骑士 · 铸光者 | [layout](PixProtection/.context/layout.md) |
| [PixRetribution](PixRetribution/README.md) | 惩戒圣骑士 · 烈日先驱 | [layout](PixRetribution/.context/layout.md) |

## 环境与运行

在 Windows 上安装 uv，然后同步根目录的共用环境：

```powershell
git clone https://github.com/liantian-cn/PixWOW.git
cd PixWOW
uv sync --locked
```

根目录的 `pyproject.toml`、`uv.lock` 和 `.python-version` 统一管理依赖及 Python 版本；环境位于根 `.venv`。依赖变更在根目录使用 `uv add` 或 `uv remove`，提交更新后的配置和锁文件。

选择项目目录运行，例如：

```powershell
uv run --locked --directory PixBlood pythonw -m pix
```

也可以先进入对应子目录：

```powershell
cd PixBlood
uv run --locked pythonw -m pix
```

五个项目的 Python 包都叫 `pix`，工作目录决定运行哪个项目。不要直接在仓库根目录执行 `pythonw -m pix`。游戏插件安装、专精设置和截图诊断见各项目 README。

### BAT 与桌面快捷方式

`scripts/` 目录提供五个启动脚本：`PixBlood.bat`、`PixBeastMastery.bat`、`PixHoly.bat`、`PixProtection.bat`、`PixRetribution.bat`。

安装 uv 并确保其位于 PATH 后，右键对应 BAT，选择“以管理员身份运行”。脚本通过自身所在目录的上一级定位仓库，使用根目录共享环境执行 `uv run --locked --directory <应用名> pythonw -m pix`，不包含本机绝对路径。

脚本通过 PowerShell 在隐藏窗口中启动 uv，随后关闭启动控制台。目录定位、uv 检查或进程创建失败时显示错误并暂停；后台 uv 或应用的运行错误不会在 BAT 窗口中展示。

可为 BAT 创建桌面快捷方式，在快捷方式的“属性 → 高级”中勾选“用管理员身份运行”，将“运行方式”设为“最小化”，并使用对应应用的 `pix/assets/app.ico` 图标。应用本身要求管理员权限。快捷方式绑定创建时的仓库位置，移动仓库后需更新目标和起始位置。

## 文档与检查

- 共用经验：[字形覆盖](.context/cell-glyph-coverage.md)、[宏快捷键顺序](.context/macro-key-order.md)。
- 专属文档：各项目 `.context/layout.md`（布局）、`keymap.md`（键位）、`rotation.md`（循环与思路），以及 `banner.prompt.md`（配图提示词）。
- 开发约定：统一由根 [AGENTS.md](AGENTS.md) 管理，包含各专精约束和按任务读取文档的规则。
- 各项目根目录保留 LICENSE、README、banner.png 和 CHANGELOG.md。导入时保留的本地提示、布局表和 JSON 资料继续受原忽略规则管理，不随 Git 克隆分发。

在根目录对指定项目执行现有检查：

```powershell
uv run --locked pyright PixBlood/pix
uv run --locked --directory PixBlood python -m compileall -q pix
git diff --check
```

替换目录名即可检查其他项目。根 Pyright 配置为五份 `pix` 设置了独立的导入根。

## 构建全部项目

构建需要 Windows x64、uv、CPython 3.13，以及带 Windows SDK 的 Visual Studio C++ 构建工具。在根目录执行：

```powershell
.\build.ps1
# 或直接执行 Python 入口
uv run --no-project --python 3.13 build.py
```

脚本根据自身位置定位仓库，也可以从其他工作目录通过脚本路径调用。它只扫描根目录的直接子目录：目录名以 `Pix` 开头（区分大小写），且存在 `pix/__main__.py`，就按名称排序逐个打包。未来新增项目满足这两个条件即可，无需修改项目清单；入口按 `python -m pix` 的语义执行，不要求定义 `main()`。没有匹配项目时返回失败。

构建使用根 `pyproject.toml` 和 `uv.lock` 的运行依赖，在根 `build/.venv` 中安装 Nuitka `4.2.2`，不修改开发环境或锁文件。各项目独立编译，中间文件与编译报告位于 `build/nuitka/<项目名>/`。首次构建可能下载依赖和编译辅助工具，耗时较长。

产物位于 `dist/<项目名>/<项目名>.exe`，分发时需要复制整个 `dist/<项目名>/` 目录。EXE 使用目录名命名，保留管理员权限及无控制台设置。不写产品版本，也不写依赖版本号的 Windows 产品名和文件描述元数据。运行日志位于 `%LOCALAPPDATA%/<项目名>.stdout.log` 和对应的 `.stderr.log`。项目的 `pix/assets/app.ico`、`pix/assets/`、`pix/lua/` 存在时纳入打包，不要求固定业务模块或 Lua TOC。

每个项目在 EXE、入口编译结果和资源校验通过后才替换旧产物，替换失败时回滚。单个项目失败会保留旧产物并继续其余项目；最后汇总结果，任一失败返回非零退出码。共享环境准备失败则整体退出。脚本不会清空整个 `dist` 或删除其他项目的产物。
