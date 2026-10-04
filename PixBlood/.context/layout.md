# PixBlood 像素布局

Lua cell、TOC、Context 与本表配套使用。普通格为 001–064，IconTile 为 I01–I19。

## 编码约定

- 布尔：白为真、黑为假。百分比：灰度 / 255 × 100。
- 符文能量比例：灰度 / 255，返回 0–1；符文数量直接读取灰度字节。
- 充能与光环层数：灰度字节直接表示计数，Python 四舍五入读取；缺失、饱和及特殊计数见对应行。
- 冷却：灰度 0/25/115/155/255 对应 245/120/30/10/0 秒。
- 光环时长：灰度 0/150/180/210/255 对应 0/15/30/60/240 秒。
- 沸点倒计时、敌人数和打断阈值分别使用对应行列出的量程，不套用其他计数规则。

## 普通格

| 位置 | 字段／文件名后缀 | 类型 | 参数与含义 |
| --- | --- | --- | --- |
| 001 | `enable` | Cell / 布尔 | 反应addonTable.ENABLE的状态 |
| 002 | `in_burst` | Cell / 布尔 | 反应addonTable.InBurst()的状态 |
| 003 | `delaying` | Cell / 布尔 | 反应addonTable.Delaying()的状态 |
| 004 | `player_is_alive` | Cell / 布尔 | 玩家存活 |
| 005 | `player_health_pct` | Cell / Curve曲线 | 玩家预测生命百分比；UnitHealthPercent(unit, true, curve)，usePredicted=true |
| 006 | `power_runic_power_ratio` | Cell / Curve曲线 | 符文能量比例 0–1；Context 返回 ratio，rotation 按当前版本上限 125 点换算 |
| 007 | `power_rune` | Cell / 浮点 | 符文个数 |
| 008 | `player_in_combat` | Cell / 布尔 | 玩家是否在状态 |
| 009 | `player_is_player_target` | Cell / 布尔 | 玩家的目标是自己 |
| 010 | `player_is_moving` | Cell / 布尔 | 玩家正在移动 |
| 011 | `player_in_vehicle` | Cell / 布尔 | 玩家在坐骑/载具上 |
| 012 | `player_is_targeting_spell` | Cell / 布尔 | 玩家在选取施法目标的状态 |
| 013 | `player_is_chatting` | Cell / 布尔 | 玩家在聊天 |
| 014 | `ticket_13_ready` | Cell / 布尔 | 一号饰品可用(SLOT 13) |
| 015 | `ticket_14_ready` | Cell / 布尔 | 二号饰品可用(SLOT 14) |
| 016 | `healthstone_ready` | Cell / 布尔 | 治疗石可用 |
| 017 | `heal_potion_ready` | Cell / 布尔 | 治疗药水可用 |
| 018 | `player_has_heal_absorb` | CellBackplate / 进度条 | 玩家治疗吸收量严格大于 250000（>250000） |
| 019 | `player_has_damage_absorb` | CellBackplate / 进度条 | 玩家伤害吸收量严格大于 500000（>500000） |
| 020 | `player_cast_progress` | Cell / Curve曲线 | 玩家的cast/channel进度 |
| 021 | `player_is_empowering` | Cell / 布尔 | 玩家是否在蓄力 |
| 022 | `target_is_exists` | Cell / 布尔 | 目标存在 |
| 023 | `target_is_alive` | Cell / 布尔 | 目标存活 |
| 024 | `target_can_attack` | Cell / 布尔 | 目标可攻击 |
| 025 | `target_can_assist` | Cell / 布尔 | 目标可协助 |
| 026 | `target_health_pct` | Cell / Curve曲线 | 目标预测生命百分比；UnitHealthPercent(unit, true, curve)，usePredicted=true |
| 027 | `target_cast_interruptible` | Cell / 布尔 | 目标可打断 |
| 028 | `target_cast_progress` | Cell / Curve曲线 | 目标的cast/channel进度 |
| 029 | `target_in_melee_range` | Cell / 布尔 | 目标在近战范围(用[灵界打击]。SPELLID:49998判断) |
| 030 | `target_in_ranged_range` | Cell / 布尔 | 目标在远程范围(用[死神的抚摩]。SPELLID:195292判断) |
| 031 | `target_in_interrupt_range` | Cell / 布尔 | 目标在可打断范围(用[心灵冰冻]。SPELLID:47528判断) |
| 032 | `focus_is_exists` | Cell / 布尔 | 焦点存在 |
| 033 | `focus_is_alive` | Cell / 布尔 | 焦点存活 |
| 034 | `focus_can_attack` | Cell / 布尔 | 焦点可攻击 |
| 035 | `focus_can_assist` | Cell / 布尔 | 焦点可协助 |
| 036 | `focus_health_pct` | Cell / Curve曲线 | 焦点预测生命百分比；UnitHealthPercent(unit, true, curve)，usePredicted=true |
| 037 | `focus_cast_interruptible` | Cell / 布尔 | 焦点可打断 |
| 038 | `focus_cast_progress` | Cell / Curve曲线 | 焦点的cast/channel进度 |
| 039 | `focus_in_melee_range` | Cell / 布尔 | 焦点在近战范围(用[灵界打击]。SPELLID:49998判断) |
| 040 | `focus_in_ranged_range` | Cell / 布尔 | 焦点在远程范围(用[死神的抚摩]。SPELLID:195292判断) |
| 041 | `focus_in_interrupt_range` | Cell / 布尔 | 焦点在可打断范围(用[心灵冰冻]。SPELLID:47528判断) |
| 042 | `spell_cd_global_cooldown` | Cell / Curve曲线 | [Global Cooldown]。SPELLID:61304 的冷却时间,ignore_gcd = false |
| 043 | `spell_cd_mind_freeze` | Cell / Curve曲线 | [心灵冰冻]。SPELLID:47528 的冷却时间,ignore_gcd = true |
| 044 | `spell_cd_reapers_mark` | Cell / Curve曲线 | [死神印记]。SPELLID:439843 的冷却时间,ignore_gcd = true |
| 045 | `spell_cd_dancing_rune_weapon` | Cell / Curve曲线 | [符文刃舞]。SPELLID:49028 的冷却时间,ignore_gcd = true |
| 046 | `spell_cd_deaths_caress` | Cell / Curve曲线 | [死神的抚摩]。SPELLID:195292 的冷却时间,ignore_gcd = true |
| 047 | `spell_cd_raise_dead` | Cell / Curve曲线 | [亡者复生]。SPELLID:46585 的冷却时间,ignore_gcd = true |
| 048 | `spell_charges_blood_boil` | CellBackplate / 整数灰度 | 血液沸腾 [50842] 充能0–2；秘密值经string.format生成灰度文字，无辅助StatusBar；RGB字节=计数；Python int(mean+0.5)；0含缺失 |
| 049 | `target_has_debuff_blood_plague` | Cell / 原生AuraContainer | 目标有血之疫病debuff  id 55078 |
| 050 | `spec_boiling_point` | Cell / 时间戳倒计时 | 非秘密 SPELL_UPDATE_COOLDOWN ID 1265982 触发3秒窗口；每0.1秒刷新，RGB=ceil(剩余秒数×10)/255，Python亮度/10得秒数；重复触发重置，进入世界清零 |
| 051 | `spell_charges_death_and_decay` | CellBackplate / 整数灰度 | 枯萎凋零 [43265] 充能0–2；秘密值经string.format生成灰度文字，无辅助StatusBar；RGB字节=计数；Python int(mean+0.5)；0含缺失 |
| 052 | `player_buff_stacks_blood_debt` | CellBackplate / 整数灰度 | 血债 [1310372] 层数；RGB字节=计数；Python int(mean+0.5)；0含缺失，255表示至少255 |
| 053 | `mouseover_in_melee_range` | Cell / 布尔 | 每0.1秒查询mouseover存在与灵界打击49998射程；不存在、普通nil或超出范围清黑 |
| 054 | `item_cd_lights_potential` | Cell / 布尔 | 圣光潜力 241308／241309 分别查询非银行库存和冷却；任一有库存、冷却启用且结束即为真；不检查额外可用性 |
| 055 | `player_has_dance_of_midnight` | Cell / 原生AuraContainer | 玩家有午夜舞步buff, buff的spell id 有[1264351, 1264405, 1264568, 1264407] |
| 056 | `player_has_buff_boiling_point` | Cell / 原生AuraContainer | 玩家有沸点buff, buff的spell id 有[1265790, 1265982, 1265968] |
| 057 | `player_has_buff_death_and_decay` | Cell / 原生AuraContainer | 玩家有枯萎凋零buff, buff的spell id 有[188290] |
| 058 | `player_has_buff_crimson_scourge` | Cell / 原生AuraContainer | 玩家有赤色天灾buff, buff的spell id 有[81141, 81136] |
| 059 | `player_has_buff_exterminate` | Cell / 原生AuraContainer | 玩家有破灭buff, buff的spell id 有[441426, 447954, 441424, 441378, 441416] |
| 060 | `player_buff_duration_bone_shield` | Cell / 原生AuraContainer | buff白骨之盾 [195181] 的剩余时间 |
| 061 | `player_buff_stacks_bone_shield` | CellBackplate / 整数灰度 | 白骨之盾 [195181] 层数；RGB字节=计数；Python int(mean+0.5)；0含缺失，255表示至少255 |
| 062 | `burst_potion_enabled` | Cell / 布尔 | 独立爆发药水开关，现有面板combo控制、默认关闭；白色开启、黑色关闭 |
| 063 | `player_melee_enemies_count` | Cell / 整数灰度 | nameplate1–40中存在、可攻击、存活且灵界打击49998射程为普通true的单位数；COMBAT_ONLY=false，秘密/nil射程不计；仅可观察姓名板；初始化、事件延后刷新及0.2秒轮询，RGB=count/40，Python int(ratio×40+0.5)还原0–40 |
| 064 | `interrupt_progress_threshold` | Cell / 整数灰度 | 打断进度阈值；面板滑块10%–90%，步长1%，默认30%；RGB=阈值/255，Python int(mean+0.5)，范围外回退30；初始化、配置变化及每秒兜底刷新；目标和焦点的施法/引导已经过进度严格大于阈值才允许心灵冰冻 |

## IconTile

| 位置 | 内容 | 参数 |
| --- | --- | --- |
| I01 | `player_cast_icon` | 玩家的施法图标，脚标永恒为COLOR.SPELL_TYPE.PLAYER_SPELL |
| I02 | `assisted_combat_icon` | 一件辅助的推荐技能，脚标永恒为COLOR.SPELL_TYPE.PLAYER_SPELL |
| I03 | `target_cast_icon` | 目标的施法图标，脚标根据可打断状态改变 |
| I04 | `focus_cast_icon` | 焦点的施法图标，脚标根据可打断状态改变 |
| I05–I19 | `interrupt_blacklist` | 15槽；面板配置打断黑名单，按法术ID升序取前15项；黄色角标，失败留空不补位；Context过滤None，目标/焦点仅在可打断且图标非空、未命中黑名单时允许打断 |

## 刷新与解析约定

005、006、007、018、019、026、036 保留事件更新并每秒兜底；062、064 保留配置回调并每秒刷新。049 的单位资格／显隐每秒刷新，光环内容由原生 AuraContainer 更新；事件仍可主动刷新光环。I05–I19 每秒重绘已选黑名单图标，不重复请求法术数据。其他已有快速轮询保持不变。

符能上限 125 是当前版本支持天赋的业务前提，战斗中不变化；未来版本变化时修改 rotation 中的换算，不改基础像素比例。布尔异常及图标比较口径见[共用 API 与解析约定](../../.context/wow-api-notes.md)。
