# PixBlood 键位映射

## 映射约定

本表核对 [Rotation.keymap](../pix/rotation.py) 与 [Lua 宏](../pix/lua/macro.lua)，包含全部现行绑定。插件创建安全按钮并覆盖绑定，无需手工创建宏。`RCTRL`、`RSHIFT`、`RALT` 分别为右 Ctrl、右 Shift、右 Alt；`NUMPAD` 为小键盘，宏中的 `\n` 表示换行。

## 键位表

| 组合键 | 动作名 | 宏文本 |
| --- | --- | --- |
| `CTRL-F12` | reloadUI | `/reload` |
| `RCTRL-NUMPAD1` | target灵界打击 | `/cast [@target] 灵界打击` |
| `RCTRL-NUMPAD2` | 焦点心灵冰冻 | `/cast [@focus] 心灵冰冻` |
| `RCTRL-NUMPAD3` | 目标心灵冰冻 | `/cast [@target] 心灵冰冻` |
| `RCTRL-NUMPAD4` | target死神印记 | `/cast [@target] 死神印记` |
| `RCTRL-NUMPAD5` | 符文刃舞 | `/cast 符文刃舞` |
| `RCTRL-NUMPAD6` | target精髓分裂 | `/cast [@target] 精髓分裂` |
| `RCTRL-NUMPAD7` | target死神的抚摩 | `/cast [@target] 死神的抚摩` |
| `RCTRL-NUMPAD8` | 圣光潜力 | `/cast item:241308\n/cast item:241309` |
| `RCTRL-NUMPAD9` | 血液沸腾 | `/cast 血液沸腾` |
| `RCTRL-NUMPAD0` | 枯萎凋零 | `/cast [@player] 枯萎凋零` |
| `RSHIFT-NUMPAD1` | target心脏打击 | `/cast [@target] 心脏打击` |
| `RSHIFT-NUMPAD2` | 亡者复生 | `/cast 亡者复生` |
| `RSHIFT-NUMPAD3` | focus灵界打击 | `/cast [@focus] 灵界打击` |
| `RSHIFT-NUMPAD4` | focus死神印记 | `/cast [@focus] 死神印记` |
| `RSHIFT-NUMPAD5` | focus精髓分裂 | `/cast [@focus] 精髓分裂` |
| `RSHIFT-NUMPAD6` | focus心脏打击 | `/cast [@focus] 心脏打击` |
| `RSHIFT-NUMPAD7` | focus死神的抚摩 | `/cast [@focus] 死神的抚摩` |

## 维护规则

`reloadUI` 是 Lua 的固定辅助绑定，不加入 Python 循环映射。动作名、组合键和宏目标须同时维护于 Python、Lua 与本表；修改后重载插件并重启桌面程序。共用候选顺序见 [宏快捷键顺序](../../.context/macro-key-order.md)，项目现有绑定以本表和代码为准。

鲜血新增宏按共用顺序选择未使用项，跳过第32项 `RCTRL-F12`，为固定重载组合保留位置；不重排其余键位。`RALT-F4`、`RALT-RSHIFT-F4` 不在共用可选表中。

循环条件见 [rotation.md](rotation.md)，像素字段见 [layout.md](layout.md)。

圣光潜力宏保留 241308 和 241309 两个品阶；第 054 格分别检查两者的非银行库存与冷却，任一就绪即可触发宏。共享冷却不意味着 GetItemCount 会合并两个物品 ID 的库存。
