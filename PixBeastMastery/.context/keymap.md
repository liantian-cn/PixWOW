# PixBeastMastery 键位映射

## 映射约定

本表核对 [Rotation.keymap](../pix/rotation.py) 与 [Lua 宏](../pix/lua/macro.lua)，包含全部现行绑定。插件创建安全按钮并覆盖绑定，无需手工创建宏。`RCTRL`、`RSHIFT`、`RALT` 分别为右 Ctrl、右 Shift、右 Alt；`NUMPAD` 为小键盘，宏中的 `\n` 表示换行。

## 键位表

| 组合键 | 动作名 | 宏文本 |
| --- | --- | --- |
| `CTRL-F12` | reloadUI | `/reload` |
| `RCTRL-NUMPAD1` | target倒刺射击 | `/cast [@target,harm,nodead] 倒刺射击` |
| `RCTRL-NUMPAD2` | 焦点反制射击 | `/cast [@focus,harm,nodead] 反制射击` |
| `RCTRL-NUMPAD3` | 目标反制射击 | `/cast [@target,harm,nodead] 反制射击` |
| `RSHIFT-NUMPAD0` | 鼠标指向反制射击 | `/cast [@mouseover,harm,nodead] 反制射击` |
| `RCTRL-NUMPAD4` | 狂野怒火 | `/cast 狂野怒火` |
| `RCTRL-NUMPAD5` | target狂野鞭笞 | `/cast [@target,harm,nodead] 狂野鞭笞` |
| `RCTRL-NUMPAD6` | target杀戮命令 | `/cast [@target,harm,nodead] 杀戮命令` |
| `RCTRL-NUMPAD7` | target眼镜蛇射击 | `/cast [@target,harm,nodead] 眼镜蛇射击` |
| `RCTRL-NUMPAD8` | 爆发药水 | `/use item:241293\n/use item:241292\n/use item:241288\n/use item:241289` |
| `RCTRL-NUMPAD9` | 治疗宠物 | `/cast 治疗宠物` |
| `RCTRL-NUMPAD0` | 召唤/复活宠物 | `/cast [@pet,dead] 复活宠物\n/castsequence [nopet] reset=3 召唤宠物 1,复活宠物` |
| `RSHIFT-NUMPAD1` | 误导party1 | `/cast [@party1,help,nodead] 误导` |
| `RSHIFT-NUMPAD2` | 误导party2 | `/cast [@party2,help,nodead] 误导` |
| `RSHIFT-NUMPAD3` | 误导party3 | `/cast [@party3,help,nodead] 误导` |
| `RSHIFT-NUMPAD4` | 误导party4 | `/cast [@party4,help,nodead] 误导` |
| `RSHIFT-NUMPAD5` | 治疗石 | `/use item:5512` |
| `RSHIFT-NUMPAD6` | 银月城生命药水 | `/use item:241304` |
| `RSHIFT-NUMPAD7` | 意气风发 | `/cast 意气风发` |
| `RSHIFT-NUMPAD8` | 上饰品 | `/use 13` |
| `RSHIFT-NUMPAD9` | 下饰品 | `/use 14` |
| `RCTRL-F1` | focus倒刺射击 | `/cast [@focus,harm,nodead] 倒刺射击` |
| `RCTRL-F2` | focus狂野鞭笞 | `/cast [@focus,harm,nodead] 狂野鞭笞` |
| `RCTRL-F3` | focus杀戮命令 | `/cast [@focus,harm,nodead] 杀戮命令` |
| `RCTRL-F4` | focus眼镜蛇射击 | `/cast [@focus,harm,nodead] 眼镜蛇射击` |
| `RCTRL-F5` | 设置焦点 | `/focus [@target,exists]` |

## 维护规则

`reloadUI` 是 Lua 的固定辅助绑定，不加入 Python 循环映射。动作名、组合键和宏目标须同时维护于 Python、Lua 与本表；修改后重载插件并重启桌面程序。共用候选顺序见 [宏快捷键顺序](../../.context/macro-key-order.md)，项目现有绑定以本表和代码为准。

循环条件见 [rotation.md](rotation.md)，像素字段见 [layout.md](layout.md)。
