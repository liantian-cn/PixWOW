# PixForeverWarriorTank 键位映射

插件创建安全按钮并覆盖绑定；无需手工创建宏。按共用顺序分配，右侧修饰键与Python映射一致。

| 组合键 | 动作名 | 宏文本 |
| --- | --- | --- |
| `CTRL-F12` | reloadUI | `/reload` |
| `RCTRL-NUMPAD1` | 英勇打击 | `/startattack\n/cast 英勇打击` |
| `RCTRL-NUMPAD2` | 撕裂 | `/startattack\n/cast 撕裂` |
| `RCTRL-NUMPAD3` | 复仇 | `/startattack\n/cast 复仇` |
| `RCTRL-NUMPAD4` | 挫志怒吼 | `/cast 挫志怒吼` |
| `RCTRL-NUMPAD5` | 战斗怒吼 | `/cast 战斗怒吼` |
| `RCTRL-NUMPAD6` | 破甲攻击 | `/startattack\n/cast 破甲攻击` |
| `RCTRL-NUMPAD7` | 防御姿态 | `/startattack\n/cast 防御姿态` |
| `RCTRL-NUMPAD8` | 盾牌格挡 | `/startattack\n/cast 盾牌格挡` |
| `RCTRL-NUMPAD9` | 焦点盾击 | `/startattack\n/cast [@focus,harm,nodead] 盾击` |
| `RCTRL-NUMPAD0` | 目标盾击 | `/startattack\n/cast [@target,harm,nodead] 盾击` |
| `RSHIFT-NUMPAD1` | 雷霆一击 | `/cast 雷霆一击` |
| `RSHIFT-NUMPAD2` | 顺劈斩 | `/startattack\n/cast 顺劈斩` |
| `RSHIFT-NUMPAD3` | 乘胜追击 | `/startattack\n/cast 乘胜追击` |

普通输出使用当前目标；焦点只用于优先盾击，不切目标、不自动设置焦点。宏中的startattack按用户原文保留。
