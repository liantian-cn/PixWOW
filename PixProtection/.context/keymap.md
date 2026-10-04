# PixProtection 键位映射

## 映射约定

本表核对 [Rotation.keymap](../pix/rotation.py) 与 [Lua 宏](../pix/lua/macro.lua)，包含全部现行绑定。插件创建安全按钮并覆盖绑定，无需手工创建宏。`RCTRL`、`RSHIFT`、`RALT` 分别为右 Ctrl、右 Shift、右 Alt；`NUMPAD` 为小键盘，宏中的 `\n` 表示换行。

## 键位表

| 组合键 | 动作名 | 宏文本 |
| --- | --- | --- |
| `CTRL-F12` | reloadUI | `/reload` |
| `RCTRL-NUMPAD1` | 目标正义盾击 | `/cast [@target,harm,nodead] 正义盾击` |
| `RCTRL-NUMPAD2` | 焦点责难 | `/cast [@focus,harm,nodead] 责难` |
| `RCTRL-NUMPAD3` | 目标责难 | `/cast [@target,harm,nodead] 责难` |
| `RCTRL-NUMPAD4` | 戒卫 | `/cast 戒卫` |
| `RCTRL-NUMPAD5` | 目标复仇者之盾 | `/cast [@target,harm,nodead] 复仇者之盾` |
| `RCTRL-NUMPAD6` | 焦点复仇者之盾 | `/cast [@focus,harm,nodead] 复仇者之盾` |
| `RCTRL-NUMPAD7` | 奉献 | `/cast 奉献` |
| `RCTRL-NUMPAD8` | 祝福之锤 | `/cast 祝福之锤` |
| `RCTRL-NUMPAD9` | 目标审判 | `/cast [@target,harm,nodead] 审判` |
| `RCTRL-NUMPAD0` | 焦点审判 | `/cast [@focus,harm,nodead] 审判` |
| `RSHIFT-NUMPAD1` | 圣洁鸣钟 | `/cast [@target,harm,nodead] 圣洁鸣钟` |
| `RSHIFT-NUMPAD2` | 神圣壁垒 | `/cast [@player] 神圣壁垒` |
| `RSHIFT-NUMPAD3` | 圣洁武器 | `/cast [@player] 圣洁武器` |
| `RSHIFT-NUMPAD4` | 荣耀圣令 | `/cast [@player] 荣耀圣令` |
| `RSHIFT-NUMPAD5` | 焦点正义盾击 | `/cast [@focus,harm,nodead] 正义盾击` |
| `RSHIFT-NUMPAD6` | 圣言祭礼 | `/cast 圣言祭礼\n/use 16` |
| `RSHIFT-NUMPAD7` | 清毒术 | `/cast [@player] 清毒术` |
| `RSHIFT-NUMPAD8` | 上饰品 | `/use 13` |
| `RSHIFT-NUMPAD9` | 下饰品 | `/use 14` |

## 维护规则

`reloadUI` 是 Lua 的固定辅助绑定，不加入 Python 循环映射。动作名、组合键和宏目标须同时维护于 Python、Lua 与本表；修改后重载插件并重启桌面程序。共用候选顺序见 [宏快捷键顺序](../../.context/macro-key-order.md)，项目现有绑定以本表和代码为准。

循环条件见 [rotation.md](rotation.md)，像素字段见 [layout.md](layout.md)。
