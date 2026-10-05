# PixProtection 像素布局

Lua cell、TOC、Context与本表配套使用。普通格保持001–068，IconTile保持I01–I19。

## 编码约定

- 正式模式Cell为4×4物理像素，基板高12px；截图和Matrix协议不变。
- 布尔：白为真、黑为假。百分比：灰度/255×100。
- 圣能、充能、光环层数、治疗阈值和军备枚举：灰度字节直接表示整数，不除以255当计数。
- 冷却：秒数0/10/30/120/245对应灰度255/155/115/25/0。黑色也可能是未知技能，不视为就绪。
- 光环时长：秒数0/15/30/60/240对应灰度0/150/180/210/255；黑色可能为缺失或到期，白色可能为永久或≥240秒。
- 光环采用player的HELPFUL|PLAYER筛选；持续时间原生绑定字体颜色，层数原生绑定共享CountFormatter。
- 射程是指定技能的判定，不表示精确码数。敌人数仅包含可观察且射程非秘密的姓名板，不代表全部附近敌人。

## 普通格

| 位置 | 字段／文件名后缀 | 类型 | 参数与含义 |
| --- | --- | --- | --- |
| 001 | `enable` | Cell / 布尔 | 反应addonTable.ENABLE的状态 |
| 002 | `in_burst` | Cell / 布尔 | 反应addonTable.InBurst()的状态 |
| 003 | `delaying` | Cell / 布尔 | 白=延迟中；Python 暂停全部自动动作，包括打断、自保和物品。 |
| 004 | `player_is_alive` | Cell / 布尔 | 玩家存活 |
| 005 | `player_health_pct` | 百分比 | 玩家预测生命百分比；UnitHealthPercent(unit, true, curve)，usePredicted=true |
| 006 | `power_holy_power` | Cell / 整数 | 圣能；普通整数直接编码为灰度字节，Python 四舍五入读取；秘密值或非法整数明确报错。 |
| 007 | `force_single_target` | 布尔 | force_single_target，默认false；强制单体禁止自动鸣钟 |
| 008 | `player_in_combat` | Cell / 布尔 | 玩家是否处于战斗。 |
| 009 | `player_is_player_target` | Cell / 布尔 | 玩家的目标是自己 |
| 010 | `player_is_moving` | Cell / 布尔 | 玩家正在移动 |
| 011 | `player_in_vehicle` | Cell / 布尔 | 玩家在坐骑/载具上 |
| 012 | `player_is_targeting_spell` | Cell / 布尔 | 玩家在选取施法目标的状态 |
| 013 | `player_is_chatting` | Cell / 布尔 | 玩家在聊天 |
| 014 | `ticket_13_ready` | 布尔 | 装备槽13；物品可用且冷却就绪 |
| 015 | `ticket_14_ready` | 布尔 | 装备槽14；物品可用且冷却就绪 |
| 016 | `healthstone_ready` | 布尔 | 物品5512；保留监控，不自动使用 |
| 017 | `heal_potion_ready` | 布尔 | 物品241304；保留监控，不自动使用 |
| 018 | `player_has_heal_absorb` | 阈值布尔 | player；治疗吸收量严格大于250000 |
| 019 | `player_has_damage_absorb` | 阈值布尔 | player；伤害吸收量严格大于500000 |
| 020 | `player_cast_progress` | Cell / 百分比 | 玩家的cast/channel进度 |
| 021 | `player_is_empowering` | Cell / 布尔 | 玩家是否在蓄力 |
| 022 | `target_is_exists` | Cell / 布尔 | 目标存在 |
| 023 | `target_is_alive` | Cell / 布尔 | 目标存活 |
| 024 | `target_can_attack` | Cell / 布尔 | 目标可攻击 |
| 025 | `target_can_assist` | Cell / 布尔 | 目标可协助 |
| 026 | `target_health_pct` | Cell / 百分比 | 目标预测生命百分比；UnitHealthPercent(unit, true, curve)，usePredicted=true |
| 027 | `target_cast_interruptible` | 布尔 | target；原始可打断状态。Python另提供黑名单过滤结果 |
| 028 | `target_cast_progress` | Cell / 百分比 | 目标的cast/channel进度 |
| 029 | `target_in_melee_range` | 布尔 | target；责难96231自身射程 |
| 030 | `target_in_ranged_range` | 布尔 | target；复仇者之盾31935自身射程 |
| 031 | `target_in_interrupt_range` | 布尔 | target；责难96231自身射程 |
| 032 | `focus_is_exists` | Cell / 布尔 | 焦点存在 |
| 033 | `focus_is_alive` | Cell / 布尔 | 焦点存活 |
| 034 | `focus_can_attack` | Cell / 布尔 | 焦点可攻击 |
| 035 | `focus_can_assist` | Cell / 布尔 | 焦点可协助 |
| 036 | `focus_health_pct` | Cell / 百分比 | 焦点预测生命百分比；UnitHealthPercent(unit, true, curve)，usePredicted=true |
| 037 | `focus_cast_interruptible` | 布尔 | focus；原始可打断状态。Python另提供黑名单过滤结果 |
| 038 | `focus_cast_progress` | Cell / 百分比 | 焦点的cast/channel进度 |
| 039 | `focus_in_melee_range` | 布尔 | focus；责难96231自身射程 |
| 040 | `focus_in_ranged_range` | 布尔 | focus；复仇者之盾31935自身射程 |
| 041 | `focus_in_interrupt_range` | 布尔 | focus；责难96231自身射程 |
| 042 | `spell_cd_global_cooldown` | 冷却秒数 | 61304 |
| 043 | `spell_cd_rebuke` | 冷却秒数 | 责难96231 |
| 044 | `spell_cd_sentinel` | 冷却秒数 | 戒卫389539 |
| 045 | `spell_cd_avengers_shield` | 冷却秒数 | 复仇者之盾31935 |
| 046 | `spell_cd_consecration` | 冷却秒数 | 奉献26573 |
| 047 | `spell_charges_blessed_hammer` | 灰度整数 | 祝福之锤204019；0–3充能 |
| 048 | `spell_charges_judgment` | 灰度整数 | 审判候选275779、20271，按此顺序选择；0–2充能 |
| 049 | `power_mana_pct` | 百分比 | player；Enum.PowerType.Mana，UnitPowerPercent的unmodified=false |
| 050 | `player_has_buff_sacred_weapon` | 布尔 | player增益433550；圣言祭礼存在 |
| 051 | `spell_cd_divine_toll` | 冷却秒数 | 圣洁鸣钟375576 |
| 052 | `player_buff_duration_shield_of_the_righteous` | 光环秒数 | player增益132403；正义盾击 |
| 053 | `player_buff_duration_consecration` | 光环秒数 | player增益188370；奉献 |
| 054 | `player_buff_stacks_shining_light` | 灰度层数 | player增益327510；闪耀之光 |
| 055 | `player_buff_stacks_shining_light_progress` | 灰度层数 | player增益182104；小闪耀之光 |
| 056 | `spell_charges_holy_bulwark` | 灰度整数 | 读取432459充能；1289728只代理已知性；0–2充能 |
| 057 | `spell_charges_sacred_weapon` | 灰度整数 | 读取432472充能；1289728只代理已知性；0–2充能 |
| 058 | `spec_protection_holy_armaments` | 灰度枚举 | 防骑GetOverrideSpell(375576)：0未知、1壁垒432459、2武器432472 |
| 059 | `word_of_glory_two_stacks_health_pct` | 灰度整数 | 荣耀圣令双层血量阈值；默认75，55–95，步长1 |
| 060 | `word_of_glory_one_stack_health_pct` | 灰度整数 | 荣耀圣令单层血量阈值；默认55，35–75，步长1 |
| 061 | `word_of_glory_progress_health_pct` | 灰度整数 | 荣耀圣令叠层血量阈值；默认90，70–100，步长1 |
| 062 | `focus_in_hammer_of_justice_range` | 布尔 | focus；制裁之锤853射程 |
| 063 | `target_in_hammer_of_justice_range` | 布尔 | target；制裁之锤853射程 |
| 064 | `player_has_dispellable_poison_or_disease` | 布尔 | player；可驱散的Poison或Disease，原生光环筛选 |
| 065 | `spell_cd_cleanse_toxins` | 冷却秒数 | 清毒术213644 |
| 066 | `auto_cleanse_enabled` | 布尔 | auto_cleanse_enabled，默认true；清毒优先于祝福之锤 |
| 067 | `auto_trinket_enabled` | 布尔 | auto_trinket_enabled，默认true；爆发且目标或焦点在制裁射程时使用 |
| 068 | `player_melee_enemies_count` | 归一化计数 | 853射程；nameplate1–40；COMBAT_ONLY=false；每0.2秒刷新；解码round(灰度/255×40) |

## IconTile

| 位置 | 内容 | 参数 |
| --- | --- | --- |
| I01 | 玩家施法／引导图标 | player |
| I02 | 辅助战斗推荐图标 | GetNextCastSpell(false) |
| I03 | 目标施法／引导图标 | target |
| I04 | 焦点施法／引导图标 | focus |
| I05–I19 | 打断黑名单 | 固定15槽，按法术ID升序取前15项，加载失败留空 |

黑名单默认ID为1216571、1223204、1241214、1238063、1228176、384194、1294815、1246687、371984、1295125。图标位置、裁剪、指纹与现有配置编辑器不变。责难使用黑名单过滤结果；飞盾使用027／037的原始可打断状态。

## 保留与替换

001–043保留通用结构；007只改面板说明，030／040从383328改为31935。029／031及039／041继续保留各自的责难射程监控。

044–062在原编号替换职业字段，051鸣钟不变；048审判增加防骑优先ID。063–068保留原参数，066／067更新说明。016–019等通用监控保留，但不因此增加自动使用物品或保命技能的规则。

| 格号 | 原内容 | 当前内容 |
| --- | --- | --- |
| 044 | 复仇之怒冷却31884 | 戒卫389539冷却 |
| 045 | 处决宣判343527冷却 | 飞盾31935冷却 |
| 046 | 灰烬觉醒255937冷却 | 奉献26573冷却 |
| 047 | 公正之剑184575冷却 | 祝福之锤204019充能 |
| 048 | 审判20271充能 | 审判275779、20271充能 |
| 049 | 鼠标指向责难射程 | 玩家法力百分比 |
| 050 | 爆发药水开关 | 圣言祭礼433550增益 |
| 052 | 圣疗633冷却 | 盾击132403增益时长 |
| 053 | 圣盾642冷却 | 奉献188370增益时长 |
| 054 | 圣光潜力241308物品就绪 | 闪耀之光327510层数 |
| 055 | 复仇之怒31884增益 | 小闪耀之光182104层数 |
| 056 | 神圣意志408458增益 | 壁垒432459充能 |
| 057 | 晨光431522增益 | 武器432472充能 |
| 058 | 战争艺术406086增益 | 防骑军备形态 |
| 059 | 神圣仲裁风暴1306162增益 | 双层治疗血量阈值 |
| 060 | 四件套开关 | 单层治疗血量阈值 |
| 061 | 目标公正之剑184575射程 | 叠层治疗血量阈值 |
| 062 | 目标审判20271射程 | 焦点制裁之锤853射程 |

## 防骑军备

`spec_protection_holy_armaments`通过 C_SpecializationInfo.GetSpecialization() 检查专精，只在圣骑士防御专精输出形态。替代技能结果是普通432459／432472时分别编码1／2，其余情况清零。进入世界、法术书、专精、图标事件后延后刷新，并每秒兜底。

1289728只用于军备已学会判定，绝不替代432459／432472作为充能读取ID。军备未知时循环跳过军备分支。当前客户端和天赋下的替代关系，以及两次形态切换后的颜色与施放，需要游戏内验收。

## 刷新与解析约定

005、006、018、019、026、036、049 保留事件更新并每秒兜底；007、059、060、061、066、067 保留配置回调并每秒刷新输出。I05–I19 每秒只重绘已选图标，不重复请求法术数据。现有更快轮询保持不变；光环存在性、层数和持续时间沿用原生绑定。

布尔异常、计数显示与图标比较采用[共用 API 与解析约定](../../.context/wow-api-notes.md)。
