# PixForeverWarriorTank 像素布局

普通格001–047连续占用，基板196×12物理像素；IconTile保持旧项目的槽位含义。

## 编码约定

布尔白真黑假，Python仅纯白判真。整数按灰度字节舍入；比例按0–255归一化。
冷却使用(灰度,秒)节点(0,245)、(25,120)、(115,30)、(155,10)、(255,0)，黑色缺失不算就绪。
光环剩余使用(0,0)、(150,15)、(180,30)、(210,60)、(255,240)，永久或饱和为240秒；层数255表示至少255层。

## 普通格

| 位置 | 字段／文件名后缀 | 类型 | 参数与含义 |
| --- | --- | --- | --- |
| 001 | `enable` | bool | 插件启用状态 |
| 002 | `delaying` | bool | 手动延迟窗口 |
| 003 | `player_is_alive` | bool | 玩家存活 |
| 004 | `player_in_combat` | bool | 玩家在战斗 |
| 005 | `player_is_player_target` | bool | UnitIsUnit(player,target)：仅选中自己暂停 |
| 006 | `player_in_vehicle` | bool | 玩家骑乘或在载具 |
| 007 | `player_is_targeting_spell` | bool | 玩家正在地面选点 |
| 008 | `player_is_chatting` | bool | 输入框持有键盘焦点 |
| 009 | `player_cast_progress` | percent | 玩家施法或引导已过百分数0–100 |
| 010 | `player_is_empowering` | bool | 玩家正在蓄力 |
| 011 | `target_is_exists` | bool | 当前目标存在 |
| 012 | `target_is_alive` | bool | 当前目标存活 |
| 013 | `target_can_attack` | bool | 当前目标可攻击 |
| 014 | `target_cast_interruptible_raw` | bool | 目标施法/引导原始可打断布尔，Context另检查图标黑名单 |
| 015 | `target_cast_progress` | percent | 目标施法/引导已过百分数0–100 |
| 016 | `target_in_melee_range` | bool | 破甲7386对当前目标的射程 |
| 017 | `focus_is_exists` | bool | 焦点存在 |
| 018 | `focus_is_alive` | bool | 焦点存活 |
| 019 | `focus_can_attack` | bool | 焦点可攻击 |
| 020 | `focus_can_assist` | bool | 焦点可协助 |
| 021 | `focus_cast_interruptible_raw` | bool | 焦点施法/引导原始可打断布尔，Context另检查图标黑名单 |
| 022 | `focus_cast_progress` | percent | 焦点施法/引导已过百分数0–100 |
| 023 | `focus_in_melee_range` | bool | 破甲7386对焦点的射程 |
| 024 | `power_rage_ratio` | ratio | 怒气比例0–1；rotation乘025配置上限 |
| 025 | `power_rage_max` | int | 默认100，100–130，步进5 |
| 026 | `sunder_rage_cost` | int | 默认15，12–15，步进1 |
| 027 | `rend_enabled` | bool | 默认开启；跨脱战与重载保存；图标132155/132363 |
| 028 | `attack_mode` | int | 0自动、10单体、20AOE；脱战和重载回0 |
| 029 | `target_interrupt_enabled` | bool | 默认开启，保存 |
| 030 | `interrupt_progress_threshold` | threshold | 默认30%，10–90%，步进10；Context保留百分数 |
| 031 | `player_enemies_count` | count | 姓名板1–40：存活、可攻击、在战斗及破甲7386范围；比例乘40舍入 |
| 032 | `player_stance` | int | 姿态ID；0无姿态、17战斗、18防御 |
| 033 | `target_creature_type` | int | 直接调用UnitCreatureType，取第二返回值目标类型ID 1–15；仅检查ID，类型名称不参与判断；ID为秘密、异常或缺失时为0；无旧目标缓存 |
| 034 | `spell_cd_shield_bash` | cd | 1672,1671,72；最高已学等级盾击冷却 |
| 035 | `spell_cd_shield_block` | cd | 2565；盾牌格挡冷却 |
| 036 | `spell_usable_revenge` | bool | 25288,11601,11600,7379,6574,6572；最高已学等级复仇usable |
| 037 | `player_has_buff_shield_block` | bool | 2565；原生光环多ID筛选 |
| 038 | `target_sunder_armor_stacks` | int | 11597,11596,8380,7405,7386；原生光环多ID筛选；目标不限来源 |
| 039 | `target_sunder_armor_remaining` | duration | 11597,11596,8380,7405,7386；原生光环多ID筛选；目标不限来源 |
| 040 | `target_thunder_clap_remaining` | duration | 11581,11580,8205,8204,8198,6343；原生光环多ID筛选；目标不限来源 |
| 041 | `player_battle_shout_remaining` | duration | 25289,11551,11550,11549,6192,5242,6673；原生光环多ID筛选 |
| 042 | `target_demoralizing_shout_remaining` | duration | 11556,11555,11554,6190,1160；原生光环多ID筛选；目标不限来源 |
| 043 | `target_rend_remaining` | duration | 11574,11573,11572,6548,6547,6546,772；原生光环多ID筛选；目标仅自身撕裂 |
| 044 | `in_burst` | bool | 爆发窗口中为白色，否则黑色；每0.1秒刷新；当前循环不使用 |
| 045 | `spell_cd_revenge` | cd | 25288,11601,11600,7379,6574,6572；最高已学等级冷却，忽略GCD；缺失不算就绪 |

| 046 | `leveling_enabled` | bool | 练级模式，默认关，持久保存；面板设置，无icon |
| 047 | `target_has_debuff_rend` | bool | 目标自身来源撕裂存在；ID同043；原生光环绑定 |

## IconTile

| 位置 | 内容 | 参数 |
| --- | --- | --- |
| I01–I02 | 保留空槽 | 不采样 |
| I03 | 目标施法图标 | 无施法为黑底 |
| I04 | 焦点施法图标 | 无施法为黑底 |
| I05–I19 | 打断黑名单 | 默认列表沿用兽王；法术ID升序前15项，图标匹配；资源不可用保持黑底并异步刷新 |

## 刷新与解析约定

冷却与usable每0.1秒刷新，等级在进入世界及SPELLS_CHANGED重新选择。姿态监听UPDATE_SHAPESHIFT_FORM、UPDATE_SHAPESHIFT_FORMS；类型监听目标变化，二者每秒兜底。
配置、资源、敌人数、普通状态均保留不超过1秒兜底。AuraContainer及DurationText原生更新豁免轮询；目标变化事件重刷目标光环。
技能范围统一以破甲7386检测；秘密射程交原生布尔颜色，姓名板计数仅纳入可读取的范围结果。秘密怒气、光环、层数不在Lua中比较。
类型0、4、9禁止撕裂；生物类型异常直接清0。修改插件后执行/reload并重启桌面程序重新定位。
