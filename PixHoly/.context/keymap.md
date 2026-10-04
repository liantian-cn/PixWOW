# PixHoly 键位映射

## 映射约定

本表核对 [Rotation.keymap](../pix/rotation.py) 与 [Lua 宏](../pix/lua/macro.lua)，包含全部现行绑定。插件创建安全按钮并覆盖绑定，无需手工创建宏。`RCTRL`、`RSHIFT`、`RALT` 分别为右 Ctrl、右 Shift、右 Alt；`NUMPAD` 为小键盘，宏中的 `\n` 表示换行。

## 键位表

| 组合键 | 动作名 | 宏文本 |
| --- | --- | --- |
| `CTRL-F12` | reloadUI | `/reload` |
| `RCTRL-NUMPAD1` | 荣耀圣令_player | `/cast [known:156322,@player,help,nodead] 永恒之火; [@player,help,nodead] 荣耀圣令` |
| `RCTRL-NUMPAD2` | 荣耀圣令_party1 | `/cast [known:156322,@party1,help,nodead] 永恒之火; [@party1,help,nodead] 荣耀圣令` |
| `RCTRL-NUMPAD3` | 荣耀圣令_party2 | `/cast [known:156322,@party2,help,nodead] 永恒之火; [@party2,help,nodead] 荣耀圣令` |
| `RCTRL-NUMPAD4` | 荣耀圣令_party3 | `/cast [known:156322,@party3,help,nodead] 永恒之火; [@party3,help,nodead] 荣耀圣令` |
| `RCTRL-NUMPAD5` | 荣耀圣令_party4 | `/cast [known:156322,@party4,help,nodead] 永恒之火; [@party4,help,nodead] 荣耀圣令` |
| `RCTRL-NUMPAD6` | 圣光术_player | `/cast [@player,help,nodead] 圣光术` |
| `RCTRL-NUMPAD7` | 圣光术_party1 | `/cast [@party1,help,nodead] 圣光术` |
| `RCTRL-NUMPAD8` | 圣光术_party2 | `/cast [@party2,help,nodead] 圣光术` |
| `RCTRL-NUMPAD9` | 圣光术_party3 | `/cast [@party3,help,nodead] 圣光术` |
| `RCTRL-NUMPAD0` | 圣光术_party4 | `/cast [@party4,help,nodead] 圣光术` |
| `RSHIFT-NUMPAD1` | 圣光闪现_player | `/cast [@player,help,nodead] 圣光闪现` |
| `RSHIFT-NUMPAD2` | 圣光闪现_party1 | `/cast [@party1,help,nodead] 圣光闪现` |
| `RSHIFT-NUMPAD3` | 圣光闪现_party2 | `/cast [@party2,help,nodead] 圣光闪现` |
| `RSHIFT-NUMPAD4` | 圣光闪现_party3 | `/cast [@party3,help,nodead] 圣光闪现` |
| `RSHIFT-NUMPAD5` | 圣光闪现_party4 | `/cast [@party4,help,nodead] 圣光闪现` |
| `RSHIFT-NUMPAD6` | 神圣震击_player | `/cast [@player,help,nodead] 神圣震击` |
| `RSHIFT-NUMPAD7` | 神圣震击_party1 | `/cast [@party1,help,nodead] 神圣震击` |
| `RSHIFT-NUMPAD8` | 神圣震击_party2 | `/cast [@party2,help,nodead] 神圣震击` |
| `RSHIFT-NUMPAD9` | 神圣震击_party3 | `/cast [@party3,help,nodead] 神圣震击` |
| `RSHIFT-NUMPAD0` | 神圣震击_party4 | `/cast [@party4,help,nodead] 神圣震击` |
| `RCTRL-F1` | 美德道标_player | `/cast [@player,help,nodead] 美德道标` |
| `RCTRL-F2` | 美德道标_party1 | `/cast [@party1,help,nodead] 美德道标` |
| `RCTRL-F3` | 美德道标_party2 | `/cast [@party2,help,nodead] 美德道标` |
| `RCTRL-F4` | 美德道标_party3 | `/cast [@party3,help,nodead] 美德道标` |
| `RCTRL-F5` | 美德道标_party4 | `/cast [@party4,help,nodead] 美德道标` |
| `RCTRL-F6` | 圣洁鸣钟_player | `/cast [@player,help,nodead] 圣洁鸣钟` |
| `RCTRL-F7` | 圣洁鸣钟_party1 | `/cast [@party1,help,nodead] 圣洁鸣钟` |
| `RCTRL-F8` | 圣洁鸣钟_party2 | `/cast [@party2,help,nodead] 圣洁鸣钟` |
| `RCTRL-F9` | 圣洁鸣钟_party3 | `/cast [@party3,help,nodead] 圣洁鸣钟` |
| `RCTRL-F10` | 圣洁鸣钟_party4 | `/cast [@party4,help,nodead] 圣洁鸣钟` |
| `RCTRL-F11` | 清洁术_player | `/cast [@player,help,nodead] 清洁术` |
| `RSHIFT-F1` | 清洁术_party1 | `/cast [@party1,help,nodead] 清洁术` |
| `RSHIFT-F2` | 清洁术_party2 | `/cast [@party2,help,nodead] 清洁术` |
| `RSHIFT-F3` | 清洁术_party3 | `/cast [@party3,help,nodead] 清洁术` |
| `RSHIFT-F4` | 清洁术_party4 | `/cast [@party4,help,nodead] 清洁术` |
| `RSHIFT-F5` | 荣耀圣令_target | `/cast [known:156322,@target,help,nodead] 永恒之火; [@target,help,nodead] 荣耀圣令` |
| `RSHIFT-F6` | 圣光术_target | `/cast [@target,help,nodead] 圣光术` |
| `RSHIFT-F7` | 圣光闪现_target | `/cast [@target,help,nodead] 圣光闪现` |
| `RSHIFT-F8` | 神圣震击_target | `/cast [@target,help,nodead] 神圣震击` |
| `RSHIFT-F9` | 清洁术_target | `/cast [@target,help,nodead] 清洁术` |
| `RSHIFT-F10` | 攻击审判 | `/cast [@target,harm,nodead] 审判` |
| `RSHIFT-F11` | 攻击神圣震击 | `/cast [@target,harm,nodead] 神圣震击` |
| `RSHIFT-F12` | 攻击正义盾击 | `/cast [@target,harm,nodead] 正义盾击` |
| `RALT-F1` | 圣疗术_player | `/cast [@player,help,nodead] 圣疗术` |
| `RALT-F2` | 上饰品 | `/use 13` |
| `RALT-F3` | 下饰品 | `/use 14` |
| `RALT-F5` | 治疗药水_271884 | `/use item:271884` |
| `RALT-F6` | 治疗药水_271883 | `/use item:271883` |
| `RALT-F7` | 治疗药水_241304 | `/use item:241304` |
| `RALT-F8` | 停止施法 | `/stopcasting` |

## 维护规则

`reloadUI` 是 Lua 的固定辅助绑定，不加入 Python 循环映射。动作名、组合键和宏目标须同时维护于 Python、Lua 与本表；修改后重载插件并重启桌面程序。共用候选顺序见 [宏快捷键顺序](../../.context/macro-key-order.md)，项目现有绑定以本表和代码为准。

循环条件见 [rotation.md](rotation.md)，像素字段见 [layout.md](layout.md)。
