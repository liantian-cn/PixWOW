# 宏快捷键优先绑定顺序

日期：2026-09-26。

## 来源与使用约定

原始来源为 Phantom 的 `phantom/core/macro_keys.py` 中的 `MACRO_KEYS`（旧仓库路径 `references/Phantom/phantom/core/macro_keys.py`）。该参考源码未包含在本仓库中；下面保留原记录的148项顺序。

用户指定这些组合为优先绑定顺序，以降低与玩家键位冲突的概率。使用原有右侧修饰键，按宏声明顺序从首项分配。各项目由 Python 和 Lua 手写相同映射，不实现运行时自动分配或同步。

- `RALT-F4`、`RALT-RSHIFT-F4` 在源记录中仅为跳过注释，不属于148项，不占序号。
- 本表保留原始序号；具体项目的固定绑定、保留键和已用键位由该项目决定，不从其他专精的历史分配推断。
- 鲜血的 F12 保留规则和当前具体分配见 [PixBlood 键位映射](../PixBlood/.context/keymap.md)。

## 原始148项顺序

| 原始序号 | 键位 |
| --- | --- |
| 1 | `RCTRL-NUMPAD1` |
| 2 | `RCTRL-NUMPAD2` |
| 3 | `RCTRL-NUMPAD3` |
| 4 | `RCTRL-NUMPAD4` |
| 5 | `RCTRL-NUMPAD5` |
| 6 | `RCTRL-NUMPAD6` |
| 7 | `RCTRL-NUMPAD7` |
| 8 | `RCTRL-NUMPAD8` |
| 9 | `RCTRL-NUMPAD9` |
| 10 | `RCTRL-NUMPAD0` |
| 11 | `RSHIFT-NUMPAD1` |
| 12 | `RSHIFT-NUMPAD2` |
| 13 | `RSHIFT-NUMPAD3` |
| 14 | `RSHIFT-NUMPAD4` |
| 15 | `RSHIFT-NUMPAD5` |
| 16 | `RSHIFT-NUMPAD6` |
| 17 | `RSHIFT-NUMPAD7` |
| 18 | `RSHIFT-NUMPAD8` |
| 19 | `RSHIFT-NUMPAD9` |
| 20 | `RSHIFT-NUMPAD0` |
| 21 | `RCTRL-F1` |
| 22 | `RCTRL-F2` |
| 23 | `RCTRL-F3` |
| 24 | `RCTRL-F4` |
| 25 | `RCTRL-F5` |
| 26 | `RCTRL-F6` |
| 27 | `RCTRL-F7` |
| 28 | `RCTRL-F8` |
| 29 | `RCTRL-F9` |
| 30 | `RCTRL-F10` |
| 31 | `RCTRL-F11` |
| 32 | `RCTRL-F12` |
| 33 | `RSHIFT-F1` |
| 34 | `RSHIFT-F2` |
| 35 | `RSHIFT-F3` |
| 36 | `RSHIFT-F4` |
| 37 | `RSHIFT-F5` |
| 38 | `RSHIFT-F6` |
| 39 | `RSHIFT-F7` |
| 40 | `RSHIFT-F8` |
| 41 | `RSHIFT-F9` |
| 42 | `RSHIFT-F10` |
| 43 | `RSHIFT-F11` |
| 44 | `RSHIFT-F12` |
| 45 | `RALT-F1` |
| 46 | `RALT-F2` |
| 47 | `RALT-F3` |
| 48 | `RALT-F5` |
| 49 | `RALT-F6` |
| 50 | `RALT-F7` |
| 51 | `RALT-F8` |
| 52 | `RALT-F9` |
| 53 | `RALT-F10` |
| 54 | `RALT-F11` |
| 55 | `RALT-F12` |
| 56 | `RALT-NUMPAD1` |
| 57 | `RALT-NUMPAD2` |
| 58 | `RALT-NUMPAD3` |
| 59 | `RALT-NUMPAD4` |
| 60 | `RALT-NUMPAD5` |
| 61 | `RALT-NUMPAD6` |
| 62 | `RALT-NUMPAD7` |
| 63 | `RALT-NUMPAD8` |
| 64 | `RALT-NUMPAD9` |
| 65 | `RALT-NUMPAD0` |
| 66 | `RCTRL-,` |
| 67 | `RCTRL-.` |
| 68 | `RCTRL-/` |
| 69 | `RCTRL-;` |
| 70 | `RCTRL-'` |
| 71 | `RCTRL-[` |
| 72 | `RCTRL-]` |
| 73 | `RCTRL-=` |
| 74 | `RALT-,` |
| 75 | `RALT-.` |
| 76 | `RALT-/` |
| 77 | `RALT-;` |
| 78 | `RALT-'` |
| 79 | `RALT-[` |
| 80 | `RALT-]` |
| 81 | `RALT-=` |
| 82 | `RSHIFT-,` |
| 83 | `RSHIFT-.` |
| 84 | `RSHIFT-/` |
| 85 | `RSHIFT-;` |
| 86 | `RSHIFT-'` |
| 87 | `RSHIFT-[` |
| 88 | `RSHIFT-]` |
| 89 | `RSHIFT-=` |
| 90 | `RCTRL-RSHIFT-NUMPAD1` |
| 91 | `RCTRL-RSHIFT-NUMPAD2` |
| 92 | `RCTRL-RSHIFT-NUMPAD3` |
| 93 | `RCTRL-RSHIFT-NUMPAD4` |
| 94 | `RCTRL-RSHIFT-NUMPAD5` |
| 95 | `RCTRL-RSHIFT-NUMPAD6` |
| 96 | `RCTRL-RSHIFT-NUMPAD7` |
| 97 | `RCTRL-RSHIFT-NUMPAD8` |
| 98 | `RCTRL-RSHIFT-NUMPAD9` |
| 99 | `RCTRL-RSHIFT-NUMPAD0` |
| 100 | `RALT-RSHIFT-NUMPAD1` |
| 101 | `RALT-RSHIFT-NUMPAD2` |
| 102 | `RALT-RSHIFT-NUMPAD3` |
| 103 | `RALT-RSHIFT-NUMPAD4` |
| 104 | `RALT-RSHIFT-NUMPAD5` |
| 105 | `RALT-RSHIFT-NUMPAD6` |
| 106 | `RALT-RSHIFT-NUMPAD7` |
| 107 | `RALT-RSHIFT-NUMPAD8` |
| 108 | `RALT-RSHIFT-NUMPAD9` |
| 109 | `RALT-RSHIFT-NUMPAD0` |
| 110 | `RCTRL-RSHIFT-F1` |
| 111 | `RCTRL-RSHIFT-F2` |
| 112 | `RCTRL-RSHIFT-F3` |
| 113 | `RCTRL-RSHIFT-F4` |
| 114 | `RCTRL-RSHIFT-F5` |
| 115 | `RCTRL-RSHIFT-F6` |
| 116 | `RCTRL-RSHIFT-F7` |
| 117 | `RCTRL-RSHIFT-F8` |
| 118 | `RCTRL-RSHIFT-F9` |
| 119 | `RCTRL-RSHIFT-F10` |
| 120 | `RCTRL-RSHIFT-F11` |
| 121 | `RCTRL-RSHIFT-F12` |
| 122 | `RALT-RSHIFT-F1` |
| 123 | `RALT-RSHIFT-F2` |
| 124 | `RALT-RSHIFT-F3` |
| 125 | `RALT-RSHIFT-F5` |
| 126 | `RALT-RSHIFT-F6` |
| 127 | `RALT-RSHIFT-F7` |
| 128 | `RALT-RSHIFT-F8` |
| 129 | `RALT-RSHIFT-F9` |
| 130 | `RALT-RSHIFT-F10` |
| 131 | `RALT-RSHIFT-F11` |
| 132 | `RALT-RSHIFT-F12` |
| 133 | `RCTRL-RSHIFT-,` |
| 134 | `RCTRL-RSHIFT-.` |
| 135 | `RCTRL-RSHIFT-/` |
| 136 | `RCTRL-RSHIFT-;` |
| 137 | `RCTRL-RSHIFT-'` |
| 138 | `RCTRL-RSHIFT-[` |
| 139 | `RCTRL-RSHIFT-]` |
| 140 | `RCTRL-RSHIFT-=` |
| 141 | `RALT-RSHIFT-,` |
| 142 | `RALT-RSHIFT-.` |
| 143 | `RALT-RSHIFT-/` |
| 144 | `RALT-RSHIFT-;` |
| 145 | `RALT-RSHIFT-'` |
| 146 | `RALT-RSHIFT-[` |
| 147 | `RALT-RSHIFT-]` |
| 148 | `RALT-RSHIFT-=` |

新增宏时，先核对所选项目的固定绑定与已用键，再手写更新该项目的 `pix/rotation.py` 和 `pix/lua/macro.lua`。
