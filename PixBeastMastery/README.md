<p align="center">
  <img src="banner.png" alt="PixBeastMastery：猎人与五只萌兽的狂暴冲锋" width="100%">
</p>

<h1 align="center">PixBeastMastery</h1>
<p align="center"><strong>猎群领袖兽王猎 · 像素读取 · 自动循环</strong></p>

Lua 在游戏内显示状态，Python 读取像素并按优先级发送技能键位。面向 Windows、正式服简体中文客户端，只维护猎群领袖兽王猎的一套循环。

## 项目简介

面向 Windows、正式服简体中文客户端的猎群领袖兽王猎项目。维护一套循环，覆盖宠物恢复、误导、打断、自保与输出。

## 快速开始

需要 Python 3.13 和 uv。从 PixWOW 仓库根目录运行：

```powershell
uv sync --locked
cd PixBeastMastery
uv run pythonw -m pix
```

1. 启动游戏，等待桌面程序识别 `wow.exe`。
2. 点击 **拷贝插件**，将 `pix/lua/` 的全部内容复制到游戏目录的 `Interface/AddOns/PixBeastMastery/`。
3. 在游戏内执行 `/reload`，确认插件已启用。
4. 桌面端点击 **启动截图**，确认定位成功后点击 **启动循环**。

也可手动复制插件。`PixBeastMastery.toc` 必须直接位于 `AddOns/PixBeastMastery/` 下，保留子目录、字体和纹理。拷贝按钮会覆盖同名文件，并保留目标目录中的额外文件。

TOC 声明 Interface `120100`、版本 `12.1.0.69933`，这是仓库目标版本，不代表其他客户端已验证。插件检查猎人兽王专精；英雄天赋由玩家自行选择猎群领袖。切换专精后会提示重载，不匹配时禁用自身，不会自动启用其他插件。

插件加载时绑定[键位表](.context/keymap.md)中的组合键，并设置 UI 缩放、抗锯齿、亮度、对比度及部分镜头 CVar，详见 [base.lua](pix/lua/core/base.lua)。像素区域需要可见且不被遮挡。

## 配置与控制

配置保存在独立的 `PixBeastMasteryDB`，不读取其他职业插件的配置。

| 设置 | 默认值 | 行为 |
| --- | --- | --- |
| 单体/AOE输出模式 | 自动 | 自动按敌人数选择；仅单体：强制单体；仅AOE：强制AOE |
| 残血收尾模式 | 自动 | 自动：非遭遇战且目标血量严格低于阈值时收尾；残血持续爆发：不收尾，狂野怒火仍按原有施放条件使用；残血不爆发：始终强制收尾，不受血量阈值影响，包括遭遇战中。收尾禁用狂野怒火及其前置自动饰品，不影响药水 |
| 收尾血量阈值（%） | 20 | 可设0–50，步进5；仅影响自动模式，0表示自动不收尾；脱战及重载保留 |
| 集中值上限 | 100 | 可设100–120整数；应与角色实际上限一致，用于还原集中值点数 |
| 自动饰品 | 开启 | 满足全部怒火条件且轮到释放怒火时，先按13、14槽顺序使用可用饰品；不要求爆发窗口，无可用饰品则直接怒火 |
| 爆发药水 | 开启 | 爆发窗口内且目标在攻击范围时按241293→241292→241288→241289尝试，优先狂放恣意饮剂，再尝试鲁莽药水；共用检测格和使用宏 |
| 打断黑名单 | 内置默认列表 | 可编辑法术ID；升序取前15项，按施法图标匹配 |

两个状态按钮均为66×66原生 UI 单位，不参与像素采样区的分辨率换算，只显示60×60图标，四边各留3，不显示文字。攻击模式自动、仅单体、仅AOE的背景分别为深绿、深蓝、深橙；收尾自动、残血持续爆发、残血不爆发使用相同配色，左击按各自三态顺序循环。六张兼具可爱感的WoW风格黑龙／棕熊手绘图标位于 `pix/lua/ui/status/`，采用不透明暗色背景，两个自动状态均带金色循环箭头；保留PNG源图，插件加载128×128的TGA纹理。当前素材与提示词另存于根目录 `assets/status-icons/wow-v3/`，供复用。收尾按钮左上角紧贴攻击模式按钮右上角，两模块左右排列。Shift+左键拖动攻击模式时两者一起移动，位置保存；攻击模式按钮不存在时，收尾按钮才独立拖动。

模式实际变化时，通过聊天框输出 `单体/AOE输出模式：自动/仅单体/仅AOE` 或 `残血收尾模式：自动/残血持续爆发/残血不爆发` 中对应的当前状态，包括脱战恢复自动；初始化、重复设置相同状态和周期刷新不打印。

每次脱离战斗或重载，攻击模式与收尾模式均恢复自动。收尾血量阈值、其他配置和按钮位置保留。

| 命令 | 作用 |
| --- | --- |
| `/pix` | 显示帮助 |
| `/pix toggle` | 切换插件启停 |
| `/pix disable` | 关闭插件 |
| `/pix auto` | 单体/AOE输出模式：自动 |
| `/pix single` | 仅单体（强制单体） |
| `/pix aoe` | 仅AOE（强制AOE） |
| `/pix end auto`、`/pix end off`、`/pix end on`、`/pix end toggle` | 自动、残血持续爆发、残血不爆发；toggle按此顺序循环，残血不爆发始终禁用狂野怒火，不受血量阈值影响 |
| `/pix burst` | 开启15秒爆发窗口 |
| `/pix burst 30`、`/pix burst 0` | 开启30秒窗口、结束窗口 |
| `/pix delay 0.4` | 暂停所有自动动作0.4秒；省略参数同样为0.4秒 |

插件加载时默认启用，并开启60秒爆发窗口。爆发窗口只控制共用爆发药水（狂放恣意饮剂优先，鲁莽药水兜底）。狂野怒火按输出规则与收尾状态判断，AOE 额外要求野兽顺劈剩余时间至少2秒，不附加存在布尔条件；自动饰品在怒火分支内优先使用，每轮重新判断，不等待饰品冷却或锁定后续怒火。

## 工作原理

Lua 显示状态 → Capture 截图 → Matrix 解码 → Context 解析 → Rotation 决策 → Action 顺序执行 → Keyboard 发送按键。

截图失败或帧龄超过0.5秒时不发送对应动作。动作日志代表选择了动作，不代表游戏确认施法成功。

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

截图默认25 FPS，可选15–35；Action默认10 FPS，可选8–16，间隔有±50%随机浮动。桌面参数只保留到退出；停止截图会停止循环，再次启动截图后需单独启动循环。

保持 `pix/lua/core/base.lua` 的 `debug = false`。像素协议见 [.context/layout.md](.context/layout.md)，插件与 Python 必须配套使用。

在当前项目子目录执行：

```powershell
uv run --locked pyright pix
uv run --locked python -m compileall -q pix
git diff --check
```

需要截图诊断时运行 `uv run --locked python -m pix.test_captura`，只截图定位。

## 常见问题

**没有动作？** 查看日志的 Idle 原因、宠物状态、插件开关与当前目标。

**截图定位失败？** 确认像素区域完整可见，且未使用调试倍率。

## 共用环境与构建

本项目共用 [PixWOW 根目录](../README.md) 的 Python 3.13、依赖、锁文件和 `.venv`。安装依赖在根目录运行 `uv sync --locked`；运行与检查命令在 `PixBeastMastery` 子目录执行，工作目录决定加载哪份 `pix`。

在仓库根目录运行 `./build.ps1` 统一打包，产物位于根目录的 `dist/PixBeastMastery/`，分发时保留整个目录。构建要求与自动发现规则见[根目录构建说明](../README.md#构建全部项目)。

## 许可与配图

本项目采用 [GNU GPLv3](LICENSE)。横幅位于 [banner.png](banner.png)，提示词与来源说明见 [.context/banner.prompt.md](.context/banner.prompt.md)。
