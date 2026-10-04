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

## 构建脚本状态

各项目的 `build.py` 和 `build.ps1` 原样保留，等待下一步整合。旧脚本仍要求子目录内存在 `pyproject.toml` 和 `uv.lock`；这两个文件已上移根目录，因此当前不能直接使用旧脚本打包。本次整合不改变应用代码或打包实现。
