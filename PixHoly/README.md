<p align="center">
  <img src="banner.png" alt="圣骑士小队横幅" width="100%">
</p>

<h1 align="center">PixHoly</h1>
<p align="center"><strong>烈日奶骑 · 小队治疗 · 像素读取</strong></p>
<p align="center">Lua显示战斗状态，Python动态选择治疗目标，按优先级执行技能。</p>

## 项目简介

PixHoly 是运行在 Windows 上的神圣圣骑士像素循环工具，针对烈日先驱治疗构筑。游戏内插件显示小队状态、圣能、法力、技能、增益和首领信息；桌面程序读取像素，执行一套手写治疗循环。

- **固定五个单位**：玩家与party1–4，支持单人和小队；进入团队仍只处理这五个单位。
- **动态治疗目标**：按生命评分、职责、增益时长与受伤人数选择治疗；驱散按魔法、疾病、中毒顺序处理。
- **读条预测**：记录当前治疗目标，将治疗吸收和本次读条估算纳入评分，普通读条最后0.4秒选择下一技能。
- **首领规则**：支持特定首领的治疗与停止施法窗口。
- **控制与观察**：保留启停、爆发窗口、手动延迟、自动驱散、自动饰品以及施法图标和黑名单观察；不执行自动打断或插入技能。

## 快速开始

使用 Windows、Python 3.13、uv，以及简体中文正式服客户端。当前插件声明 Interface `120100`、版本 `12.1.0.69933`，专精门控为神圣序号1。

```powershell
git clone https://github.com/liantian-cn/PixWOW.git
cd PixWOW
uv sync --locked
cd PixHoly
uv run pythonw -m pix
```

在桌面界面中选择游戏进程，点击**拷贝插件**，将插件安装到 `Interface/AddOns/PixHoly/`，然后在游戏内 `/reload`。
也可以手动将 `pix/lua/` 的全部文件和子目录复制到该目录。设置独立保存在 `PixHolyDB`，不读取其他专精的配置。
先启动截图确认定位，再启动循环。像素基板为716×12物理像素，需要完整显示。

## 配置与控制

| 命令／设置 | 用途 |
| --- | --- |
| `/pix toggle` | 切换启停 |
| `/pix disable` | 关闭自动动作 |
| `/pix burst 15` | 开启15秒爆发窗口，传0结束 |
| `/pix delay 0.4` | 手动操作后的暂停窗口 |
| 自动驱散 | 默认开启，按魔法、疾病、中毒顺序处理小队和友方目标 |
| 自动饰品 | 默认开启，战斗中的爆发窗口内，驱散与自身急救之后先用上饰品，再用下饰品 |

## 工作原理

Lua 显示五人状态，Python 解码后按生命评分动态选择治疗对象，发送对应单位的技能宏。治疗、驱散和读条预测的详细规则见 [.context/rotation.md](.context/rotation.md)。

治疗吸收条内容为5个Cell、共20px，完整占6个Cell，精度约5个百分点。伤害吸收只显示是否存在，不加入生命评分。

## 文档导航

| 文档 | 内容 |
| --- | --- |
| [layout.md](.context/layout.md) | 像素布局、字段与编码 |
| [keymap.md](.context/keymap.md) | 完整键位与宏目标 |
| [rotation.md](.context/rotation.md) | 循环优先级、条件与设计约定 |
| [CHANGELOG.md](CHANGELOG.md) | 后续更新记录 |
| [banner.prompt.md](.context/banner.prompt.md) | 横幅提示词与来源说明 |

修改项目时遵循 [根 AGENTS.md](../AGENTS.md)。详细键位和循环规则集中维护在 `.context`。

## 开发与检查

| 文件／目录 | 职责 |
| --- | --- |
| `pix/lua/cells/` | 状态、技能、小队与首领像素 |
| `pix/lua/core/units.lua` | 小队集中创建与队伍刷新 |
| `pix/lua/macro.lua` | 固定单位宏及键位 |
| `pix/context.py` | 像素解码和五成员字典 |
| `pix/rotation.py` | 动态选人、预测与治疗优先级 |
| `pix/action.py`、`pix/keyboard.py` | 顺序执行与按键发送 |
| `pix/capture.py`、`pix/matrix.py` | 截图定位与像素区域解析 |
| `.context/layout.md` | 完整位置和编码约定 |

在当前项目子目录执行：

```powershell
uv run --locked pyright pix
uv run --locked python -m compileall -q pix
git diff --check
```

需要截图诊断时运行 `uv run --locked python -m pix.test_captura`，只截图定位。

## 常见问题

**团队中会治疗所有人吗？** 仍只处理玩家与party1–4。

**脱战时不需要选择敌人吗？** 治疗分支可以脱战执行，输出分支另行检查战斗和敌对目标。

**截图定位失败？** 确认716×12物理像素基板完整显示，插件与 Python 来自同一版本。

## 共用环境与构建

本项目共用 [PixWOW 根目录](../README.md) 的 Python 3.13、依赖、锁文件和 `.venv`。安装依赖在根目录运行 `uv sync --locked`；运行与检查命令在 `PixHoly` 子目录执行，工作目录决定加载哪份 `pix`。

`build.py`、`build.ps1` 仍读取原子目录的 `pyproject.toml` 和 `uv.lock`，需后续适配后才能打包。

## 许可与配图

本项目采用 [GNU GPLv3](LICENSE)。横幅位于 [banner.png](banner.png)，提示词与来源说明见 [.context/banner.prompt.md](.context/banner.prompt.md)。
