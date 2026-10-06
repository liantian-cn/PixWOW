# PixBeastMastery 像素布局

Lua Cell、Context和本表必须同步更新。插件与Python必须配套使用。

## 编码约定

正式模式每格4×4物理像素，基板12px高。普通区占1–88列，加左右检测列总宽360px。IconTile仍为8×8，位于基板下方两行。Capture和Matrix协议不变。

- 布尔：白255为真、黑0为假。
- 灰度整数：直接读取字节并四舍五入，不除255。
- 本地怒火施放窗口：第88格灰度0～40表示0～4秒，Lua将剩余秒数乘10向上取整，Python读取亮度后除10，不使用冷却或光环曲线。
- 百分比：灰度/255×100；集中值点数=四舍五入(第6格比例×第61格上限)。上限不在100–120时按0点处理。
- 冷却：亮度0/25/115/155/255对应245/120/30/10/0秒；黑色也包含未知技能和缺失数据，不表示就绪。
- 充能：currentCharges和maxCharges经原生文字显示秘密计数，Python读取灰度。最大充能>0且当前充能≥上限时，下一层恢复时间视为0；否则读取62格。没有恢复对象时62格为黑。
- 攻击模式先按人数≥2计算IsAOE，再由10/20强制覆盖；自动模式0人也按单体。
- 所有攻击射程字段均参考反制射击147362，包括保留名称中的melee/ranged；坦克误导范围单独使用34477。
- 施法和引导进度均为已经过百分比，灰度/255×100；0表示空闲或刚开始，100表示进度末端，结束后回到0。须同时检查可打断状态及施法图标。
- 打断进度阈值为灰度整数，默认30、范围10–90；三种打断均要求解码进度严格大于阈值，不再采集或判断剩余秒数。

## 普通格

| 位置 | 字段／文件名后缀 | 类型 | 参数与含义 |
| --- | --- | --- | --- |
| 001 | `enable` | Cell / 布尔 | 反应addonTable.ENABLE的状态 |
| 002 | `in_burst` | Cell / 布尔 | 反应addonTable.InBurst()的状态 |
| 003 | `delaying` | Cell / 布尔 | 白=延迟中；Python 暂停全部自动动作，包括打断、自保和物品。 |
| 004 | `player_is_alive` | Cell / 布尔 | 玩家存活 |
| 005 | `player_health_pct` | Cell / 百分比 | 玩家预测生命百分比；UnitHealthPercent(unit, true, curve)，usePredicted=true |
| 006 | `power_focus_pct` | 百分比 | UnitPowerPercent，灰度/255×100；与61格组合还原点数 |
| 007 | `attack_mode` | 枚举 | 灰度0自动、10仅单体、20仅AOE；分别对应自动、强制单体、强制AOE，脱战及重载恢复0 |
| 008 | `player_in_combat` | Cell / 布尔 | 玩家是否处于战斗。 |
| 009 | `player_is_player_target` | Cell / 布尔 | 玩家的目标是自己 |
| 010 | `player_is_moving` | Cell / 布尔 | 玩家正在移动 |
| 011 | `player_in_vehicle` | Cell / 布尔 | 玩家在坐骑/载具上 |
| 012 | `player_is_targeting_spell` | Cell / 布尔 | 玩家在选取施法目标的状态 |
| 013 | `player_is_chatting` | Cell / 布尔 | 玩家在聊天 |
| 014 | `ticket_13_ready` | Cell / 布尔 | 一号饰品可用（SLOT 13）；到达单体或 AOE 怒火分支且满足全部施放条件时，自动饰品开启则先使用可用饰品再怒火，不要求爆发窗口。 |
| 015 | `ticket_14_ready` | Cell / 布尔 | 二号饰品可用（SLOT 14）；同上，优先级低于一号饰品，每轮重新读取可用状态。 |
| 016 | `healthstone_ready` | Cell / 布尔 | 治疗石 item:5512；冷却启用且物品可使用时为白色。 |
| 017 | `heal_potion_ready` | Cell / 布尔 | 银月城生命药水 item:241304；冷却启用且物品可使用时为白色。 |
| 018 | `player_has_heal_absorb` | StatusBar / 阈值布尔 | 玩家治疗吸收量严格大于 250000（>250000） |
| 019 | `player_has_damage_absorb` | StatusBar / 阈值布尔 | 玩家伤害吸收量严格大于 500000（>500000） |
| 020 | `player_cast_progress` | Cell / 百分比 | 玩家的cast/channel进度 |
| 021 | `player_is_empowering` | Cell / 布尔 | 玩家是否在蓄力 |
| 022 | `target_is_exists` | Cell / 布尔 | 目标存在 |
| 023 | `target_is_alive` | Cell / 布尔 | 目标存活 |
| 024 | `target_can_attack` | Cell / 布尔 | 目标可攻击 |
| 025 | `target_can_assist` | Cell / 布尔 | 目标可协助 |
| 026 | `target_health_pct` | Cell / 百分比 | 目标预测生命百分比；UnitHealthPercent(unit, true, curve)，usePredicted=true |
| 027 | `target_cast_interruptible` | Cell / 布尔 | 目标可打断 |
| 028 | `target_cast_progress` | Cell / 百分比 | 目标的cast/channel进度 |
| 029 | `target_in_melee_range` | 布尔 | 单位在反制射击147362射程内；nil或无单位显示黑色。 |
| 030 | `target_in_ranged_range` | 布尔 | 单位在反制射击147362射程内；nil或无单位显示黑色。 |
| 031 | `target_in_interrupt_range` | 布尔 | 单位在反制射击147362射程内；nil或无单位显示黑色。 |
| 032 | `focus_is_exists` | Cell / 布尔 | 焦点存在 |
| 033 | `focus_is_alive` | Cell / 布尔 | 焦点存活 |
| 034 | `focus_can_attack` | Cell / 布尔 | 焦点可攻击 |
| 035 | `focus_can_assist` | Cell / 布尔 | 焦点可协助 |
| 036 | `focus_health_pct` | Cell / 百分比 | 焦点预测生命百分比；UnitHealthPercent(unit, true, curve)，usePredicted=true |
| 037 | `focus_cast_interruptible` | Cell / 布尔 | 焦点可打断 |
| 038 | `focus_cast_progress` | Cell / 百分比 | 焦点的cast/channel进度 |
| 039 | `focus_in_melee_range` | 布尔 | 单位在反制射击147362射程内；nil或无单位显示黑色。 |
| 040 | `focus_in_ranged_range` | 布尔 | 单位在反制射击147362射程内；nil或无单位显示黑色。 |
| 041 | `focus_in_interrupt_range` | 布尔 | 单位在反制射击147362射程内；nil或无单位显示黑色。 |
| 042 | `spell_cd_global_cooldown` | Cell / 冷却曲线 | [Global Cooldown]。SPELLID:61304 的冷却时间,ignore_gcd = false |
| 043 | `spell_cd_counter_shot` | 冷却 | 反制射击147362 |
| 044 | `spell_cd_bestial_wrath` | 冷却 | 狂野怒火19574 |
| 045 | `spell_cd_wild_thrash` | 冷却 | 狂野鞭笞1264359 |
| 046 | `spell_cd_kill_command` | 冷却 | 杀戮命令34026冷却字段保留；当前循环以74格充能判断可用，不检查此冷却 |
| 047 | `spell_cd_barbed_shot` | 冷却 | 倒刺射击217200冷却字段保留；当前循环以48格充能判断可用，不检查此冷却 |
| 048 | `spell_charges_barbed_shot` | 整数 | 倒刺射击当前充能；灰度字节即数量 |
| 049 | `mouseover_in_melee_range` / `mouseover_in_interrupt_range` | 布尔 | 鼠标单位在147362射程；两个Context属性复用同一格 |
| 050 | `burst_potion_enabled` | 布尔 | 自动爆发药水开关，默认开启 |
| 051 | `spell_cd_mend_pet` | 冷却 | 治疗宠物136 |
| 052 | `spell_cd_exhilaration` | 冷却 | 意气风发109304 |
| 053 | `spell_cd_misdirection` | 冷却 | 误导34477 |
| 054 | `reckless_potion_ready` | 布尔 | 共用爆发药水就绪：241293、241292、241288、241289任一有库存、冷却启用且已结束；保留原属性名，使用宏按此顺序尝试 |
| 055 | `player_has_buff_howl_of_the_pack_leader` | 布尔 | 猎群领袖之嚎以飞龙471878、猪472324、熊472325三种互斥形态呈现；单个AuraSlot匹配三个ID，任一种存在为白，否则黑 |
| 056 | `player_has_buff_natures_ally` | 布尔 | 玩家自然之友（Nature’s Ally）增益1276720 |
| 057 | `target_has_debuff_hunters_mark` | 布尔 | 目标存在自身猎人印记257284；HARMFUL\|PLAYER筛选，无单位或可协助单位为黑 |
| 058 | `focus_has_debuff_hunters_mark` | 布尔 | 焦点存在自身猎人印记257284；HARMFUL\|PLAYER筛选，无单位或可协助单位为黑 |
| 059 | `player_buff_stacks_cobra_fangs` | 灰度整数 | 玩家眼镜蛇利牙1299389层数；SetApplicationCount绑定共享CountFormatter，灰度字节直接表示层数，Python四舍五入读取；0包含无光环或无计数，255表示至少255层。`player_has_buff_cobra_fangs`由层数>0派生；单体和AOE的优先眼镜蛇均要求层数>3，AOE另需顺劈剩余≥1秒；杀戮不限制利牙层数 |
| 060 | `finishing` | 枚举 | 灰度0自动、10残血持续爆发（关闭收尾）、20残血不爆发（始终开启收尾，不受血量阈值影响，包括遭遇战）；默认、脱战及重载恢复自动；自动模式仅在86格为假且主目标预测生命严格低于87格阈值时收尾，10/20强制覆盖；异常枚举按自动处理 |
| 061 | `power_focus_max` | 整数 | 配置集中值上限100–120，默认100，灰度直接表示点数 |
| 062 | `spell_recharge_barbed_shot` | 冷却曲线 | 倒刺射击下一层充能剩余时间；满充能由48和75格识别 |
| 063 | `pet_is_exists` | 布尔 | 宠物存在 |
| 064 | `pet_is_alive` | 布尔 | 宠物存在且存活 |
| 065 | `pet_health_pct` | 百分比 | 宠物预测生命比例 |
| 066 | `party_tank_index` | 整数 | 0无合格坦克，1–4表示party编号；只选存活在线坦克 |
| 067 | `auto_trinket_enabled` | 布尔 | 自动饰品开关，默认开启 |
| 068 | `player_enemies_count` | 比例计数 | 灰度/255×40并四舍五入；147362范围内可攻击、存活、战斗中的可观察姓名板数量 |
| 069 | `player_in_party` | 布尔 | 在小队且不在团队 |
| 070 | `spell_known_misdirection` | 布尔 | 误导34477已学会 |
| 071 | `party_tank_in_misdirection_range` | 布尔 | 66格选中的坦克在34477射程内 |
| 072 | `target_interrupt_enabled` | 布尔 | 目标打断开关，默认否，持久化保存 |
| 073 | `mouseover_interrupt_enabled` | 布尔 | 鼠标指向打断开关，默认是，持久化保存 |
| 074 | `spell_charges_kill_command` | 整数 | 杀戮命令当前充能 |
| 075 | `spell_max_charges_barbed_shot` | 整数 | 倒刺射击最大充能；0表示缺失 |
| 076 | `player_has_buff_beast_cleave` | 布尔 | 玩家野兽顺劈（Beast Cleave）增益268877是否存在 |
| 077 | `interrupt_progress_threshold` | 整数 | 共用打断进度阈值，默认30，范围10–90，步长1；Python对越界值回退30 |
| 078 | `mouseover_is_exists` | 布尔 | 鼠标单位存在 |
| 079 | `mouseover_is_alive` | 布尔 | 鼠标单位存在且存活 |
| 080 | `mouseover_can_attack` | 布尔 | 鼠标单位存在且可攻击 |
| 081 | `mouseover_can_assist` | 布尔 | 鼠标单位存在且可协助 |
| 082 | `mouseover_cast_interruptible` | 布尔 | 鼠标单位施法或引导可打断；Context额外检查图标存在且不在黑名单 |
| 083 | `mouseover_cast_progress` | 百分比 | 鼠标单位施法或引导已经过百分比，空闲为0 |
| 084 | `player_has_buff_bestial_wrath` | 布尔 | 玩家狂野怒火（Bestial Wrath）增益19574是否存在 |
| 085 | `player_buff_beast_cleave_remaining` | 光环剩余秒数 | 玩家野兽顺劈268877；亮度0/150/180/210/255对应0/15/30/60/240秒，0含不存在或到期，240含永久或上限饱和；原生DurationText绑定更新 |
| 086 | `encounter_in_progress` | 布尔 | C_InstanceEncounter.IsEncounterInProgress()；遭遇战中白、否则黑，不区分编号，不附加玩家存活、战斗或目标条件；初始化读取、进入世界及状态变化后延后刷新，每秒兜底 |
| 087 | `finishing_health_threshold` | 整数 | 收尾血量阈值百分数，灰度字节直接表示；默认20，范围0–50，滑块步进5，持久化保存；0表示自动不收尾，Python越界回退20 |
| 088 | `bestial_wrath_cast_remaining` | 灰度十分之一秒 | 玩家狂野怒火19574成功施放后的本地4秒窗口；仅监听player的UNIT_SPELLCAST_SUCCEEDED，可读ID匹配后开始或重置；秘密、缺失或其他ID忽略。0包含未触发、到期、重载或进入世界清零；不是实际增益剩余时间；保留采集与解码，当前循环不使用 |

主目标选择复用目标和焦点的存在、可攻击、可协助与反制射击射程字段，按焦点→目标判断；不额外检查存活。自动收尾随主目标使用第026或036格预测生命，编码及基板尺寸不变。

## IconTile

| 位置 | 内容 | 参数 |
| --- | --- | --- |
| I01 | 玩家施法/引导图标 | player |
| I02 | 游戏辅助战斗推荐技能图标 | 游戏辅助战斗推荐 |
| I03 | 目标施法/引导图标 | target |
| I04 | 焦点施法/引导图标 | focus |
| I05–I19 | 打断黑名单 | 法术ID升序取前15项；加载失败留空 |
| I20 | 鼠标指向施法/引导图标 | mouseover |

黑名单默认ID为1216571、1223204、1241214、1238063、1228176、384194、1294815、1246687、371984、1295125。匹配沿用Matrix的内区裁剪和指纹算法；黑底表示无图标。可打断判断必须有当前施法图标，并且不在黑名单中。

## 刷新与解析约定

第55格沿用AuraContainer原生光环筛选和显隐，Python只读取该格布尔值；不在Lua中判断三种形态。更新插件与Python后执行`/reload`并重启Python，核对三种形态的出现、切换和消失。

第57、58格复用原空位，分别显示目标和焦点的自身猎人印记257284；原生AuraContainer按HARMFUL|PLAYER筛选，PLAYER来源包含玩家宠物／载具，不匹配其他猎人的印记。白色表示存在，黑底表示不存在；单位不存在或UnitCanAssist("player", unit, true, true)可协助时隐藏容器。初始化、进入世界、对应目标／焦点切换、UNIT_FACTION及UNIT_FLAGS事件后刷新，事件延后下一帧执行；单位资格显隐每秒兜底，日常光环更新交给原生容器。Python沿用现有布尔解析；两格均为false才对主目标补印记，不增加冷却或资源检测格。基板保持360×12；插件与Python须配套更新并重载，实机核对印记添加／移除、单位切换／清空、友方单位、其他猎人的印记及两个宏的施放对象。

第88格按截止时间每0.1秒刷新，匹配怒火施法成功事件后立即刷新；其他技能、打断、切目标和脱战不清除计时，进入世界清零。不监听冷却更新事件；战斗中施法成功事件的ID可读性需实机验证。

冷却、充能恢复、射程、施法进度、可打断状态和施法图标保留0.1秒刷新；鼠标单位变化触发刷新，单位状态每秒兜底；充能数量由事件更新并每秒兜底；资源/生命保留对应事件刷新并每秒兜底，光环由AuraContainer原生绑定。

敌人数按姓名板及进出战斗事件刷新，每秒兜底。坦克编号在进入地图、队伍/职责、连接、生命状态及进出战斗时更新，每1秒兜底；误导射程每0.1秒刷新。

攻击模式与收尾按钮的设置、命令、显示分别完全位于007和060文件中。两者脱战/重载恢复自动，位置单独持久化；087管理收尾血量阈值，与上限和消耗品开关一样保存在PixBeastMasteryDB中，脱战/重载不重置。

两个控制按钮均使用66×66原生 UI 单位，不参与像素采样区的分辨率换算：只显示60×60图标，四边各留3，不创建文字区域。收尾按钮左上角以零偏移锚定攻击模式按钮右上角，形成左右布局；Shift+左键拖动攻击模式时整体移动并保存位置，攻击模式按钮不存在时收尾才独立拖动。007、060采样格的位置与编码不变。两个按钮的三态深色背景依次使用相同的绿、蓝、橙配色，图标从 `ui/status/` 加载六张独立的128×128不透明TGA纹理，以60×60显示；采用兼具可爱感的WoW风格手绘暗底插画，两个自动状态使用金色循环箭头。输出自动为黑龙头、仅单体为一条完整的大黑龙、仅AOE为三只黑龙宝宝；收尾自动为棕熊头、残血持续爆发为发怒棕熊、残血不爆发为蜷睡棕熊。同名PNG为生成源图，根目录 `assets/status-icons/wow-v3/` 保存当前素材与生成提示词。

模式实际变化时，007打印 `单体/AOE输出模式：` 加当前名称（自动、仅单体、仅AOE），060打印 `残血收尾模式：` 加当前名称（自动、残血持续爆发、残血不爆发）。点击、命令、设置面板和脱战恢复自动共用变化检测；初始化、同值写入及周期刷新不重复打印。

打断面板配置保存在PixBeastMasteryDB中，重载后保留；焦点始终启用，优先级为目标→焦点→鼠标指向。三者均要求反制射击就绪、单位存在且存活、可攻击且不可协助、射程内、可打断、图标不在黑名单及已过进度严格超过阈值。保留战斗、宠物恢复、玩家施法和手动延迟等前置门控；自保和打断在主目标选择前执行，不依赖有效当前目标或主目标。目标与鼠标打断仍受各自开关控制。

鼠标指向反制射击绑定RSHIFT-NUMPAD0，宏为`/cast [@mouseover,harm,nodead] 反制射击`，不回退当前目标。第72、73格已替换原剩余秒数，更新时须将插件与Python配套更新并重载。

编码或采样条件变更后，需要核对受影响的游戏内表现；语法和 Python 静态检查不能代替客户端验收。

配置格 007、050、060、061、067、072、073、077、087 保留配置回调，并每秒刷新输出。018／019 吸收阈值、069 小队状态、070 已学误导保留事件更新并每秒兜底。I05–I19 每秒只重绘已选图标，不重复请求全部法术数据。

布尔异常、计数显示与图标比较采用[共用 API 与解析约定](../../.context/wow-api-notes.md)。当前计数显示路线已有用户使用确认；修改编码、字体或采样条件后，应检查受影响的游戏内表现。
