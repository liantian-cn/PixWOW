# PixRetribution 键位映射

## 映射约定

本表核对 [Rotation.keymap](../pix/rotation.py) 与 [Lua 宏](../pix/lua/macro.lua)，包含全部现行绑定。插件创建安全按钮并覆盖绑定，无需手工创建宏。`RCTRL`、`RSHIFT`、`RALT` 分别为右 Ctrl、右 Shift、右 Alt；`NUMPAD` 为小键盘，宏中的 `\n` 表示换行。

## 键位表

| 组合键 | 动作名 | 宏文本 |
| --- | --- | --- |
| `CTRL-F12` | reloadUI | `/reload` |
| `RCTRL-NUMPAD1` | 最终审判 | `/cast [@target,harm,nodead] 最终审判` |
| `RCTRL-NUMPAD2` | 焦点责难 | `/cast [@focus,harm,nodead] 责难` |
| `RCTRL-NUMPAD3` | 目标责难 | `/cast [@target,harm,nodead] 责难` |
| `RCTRL-NUMPAD4` | 复仇之怒 | `/cast 复仇之怒` |
| `RCTRL-NUMPAD5` | 处决宣判 | `/cast [@target,harm,nodead] 处决宣判` |
| `RCTRL-NUMPAD6` | 灰烬觉醒 | `/cast 灰烬觉醒` |
| `RCTRL-NUMPAD7` | 公正之剑 | `/cast [@target,harm,nodead] 公正之剑` |
| `RCTRL-NUMPAD8` | 圣光潜力 | `/use item:241308\n/use item:241309` |
| `RCTRL-NUMPAD9` | 审判 | `/cast [@target,harm,nodead] 审判` |
| `RCTRL-NUMPAD0` | 神圣风暴 | `/cast 神圣风暴` |
| `RSHIFT-NUMPAD1` | 圣洁鸣钟 | `/cast [@target,harm,nodead] 圣洁鸣钟` |
| `RSHIFT-NUMPAD2` | 圣疗术 | `/cast [@player] 圣疗术` |
| `RSHIFT-NUMPAD3` | 圣盾术 | `/cast 圣盾术` |
| `RSHIFT-NUMPAD4` | 荣耀圣令 | `/cast [@player] 荣耀圣令` |
| `RSHIFT-NUMPAD5` | 治疗石 | `/use item:5512` |
| `RSHIFT-NUMPAD6` | 银月城生命药水 | `/use item:241304` |
| `RSHIFT-NUMPAD7` | 清毒术 | `/cast [@player]清毒术` |
| `RSHIFT-NUMPAD8` | 上饰品 | `/use 13` |
| `RSHIFT-NUMPAD9` | 下饰品 | `/use 14` |

## 维护规则

`reloadUI` 是 Lua 的固定辅助绑定，不加入 Python 循环映射。动作名、组合键和宏目标须同时维护于 Python、Lua 与本表；修改后重载插件并重启桌面程序。共用候选顺序见 [宏快捷键顺序](../../.context/macro-key-order.md)，项目现有绑定以本表和代码为准。

循环条件见 [rotation.md](rotation.md)，像素字段见 [layout.md](layout.md)。

圣光潜力宏保留 241308 和 241309 两个品阶；第 054 格分别检查两者的非银行库存与冷却，任一就绪即可触发宏。共享冷却不意味着 GetItemCount 会合并两个物品 ID 的库存。
