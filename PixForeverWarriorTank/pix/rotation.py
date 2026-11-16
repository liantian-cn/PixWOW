"""Forever 防战：每轮只执行首个命中的动作。"""
from pix.action import Cast, Idle
from pix.context import Context


class Rotation:
    def __init__(self) -> None:
        self.keymap: dict[str, str] = {
            "英勇打击": "RCTRL-NUMPAD1",
            "撕裂": "RCTRL-NUMPAD2",
            "复仇": "RCTRL-NUMPAD3",
            "挫志怒吼": "RCTRL-NUMPAD4",
            "战斗怒吼": "RCTRL-NUMPAD5",
            "破甲攻击": "RCTRL-NUMPAD6",
            "防御姿态": "RCTRL-NUMPAD7",
            "盾牌格挡": "RCTRL-NUMPAD8",
            "焦点盾击": "RCTRL-NUMPAD9",
            "目标盾击": "RCTRL-NUMPAD0",
            "雷霆一击": "RSHIFT-NUMPAD1",
            "顺劈斩": "RSHIFT-NUMPAD2",
        }

    def check_pause(self, ctx: Context) -> Idle | None:
        # 如果 插件未启用
        # => 不执行动作
        if not ctx.enable:
            return Idle("插件未启用")
        # 如果 插件延迟中
        # => 不执行动作
        if ctx.delaying:
            return Idle("插件延迟中")
        # 如果 玩家不在战斗
        # => 不执行动作
        if not ctx.player_in_combat:
            return Idle("玩家不在战斗")
        # 如果 玩家正在施法或引导
        # => 不执行动作
        if ctx.player_cast_progress > 0:
            return Idle("玩家正在施法或引导")
        # 如果 玩家正在蓄力
        # => 不执行动作
        if ctx.player_is_empowering:
            return Idle("玩家正在蓄力")
        # 如果 目标不可攻击
        # => 不执行动作
        if not (ctx.target_is_exists and ctx.target_is_alive and ctx.target_can_attack):
            return Idle("目标不可攻击")
        # 如果 玩家的目标是玩家
        # => 不执行动作
        if ctx.player_is_player_target:
            return Idle("玩家的目标是玩家")
        # 如果 玩家未存活
        # => 不执行动作
        if not ctx.player_is_alive:
            return Idle("玩家未存活")
        # 如果 坐骑、载具、输入或地面选点中
        # => 不执行动作
        if ctx.player_in_vehicle or ctx.player_is_chatting or ctx.player_is_targeting_spell:
            return Idle("坐骑、载具、输入或地面选点中")
        return None

    def interrupt_rotation(self, ctx: Context, rage: float) -> Cast | None:
        # 如果 盾击冷却不为0或怒气不严格大于10
        # => 跳过打断
        if ctx.spell_cd_shield_bash != 0 or rage <= 10:
            return None
        # 如果 焦点存在、存活、可攻击且不可协助，在近战范围，施法可打断且不在黑名单，已过进度严格超过配置阈值
        # => 优先对焦点盾击
        if (ctx.focus_is_exists and ctx.focus_is_alive and ctx.focus_can_attack
                and not ctx.focus_can_assist and ctx.focus_in_melee_range
                and ctx.focus_cast_interruptible
                and ctx.focus_cast_progress > ctx.interrupt_progress_threshold):
            return Cast("焦点盾击")
        # 如果 目标打断开启，当前目标在近战范围、施法可打断且不在黑名单，已过进度严格超过阈值
        # => 对通过全局有效性门控的当前目标盾击
        if (ctx.target_interrupt_enabled and ctx.target_in_melee_range
                and ctx.target_cast_interruptible
                and ctx.target_cast_progress > ctx.interrupt_progress_threshold):
            return Cast("目标盾击")
        return None

    def main_rotation(self, ctx: Context) -> Cast | Idle:
        action = self.check_pause(ctx)
        # 如果 暂停检查返回动作
        # => 本轮结束
        if action is not None:
            return action
        rage = ctx.power_rage_ratio * ctx.power_rage_max
        interrupt = self.interrupt_rotation(ctx, rage)
        # 如果 打断命中
        # => 本轮只执行盾击
        if interrupt is not None:
            return interrupt
        # 如果 当前不是防御姿态18
        # => 切换防御姿态，本轮结束
        if ctx.player_stance != 18:
            return Cast("防御姿态")
        # 如果 强制AOE，或自动模式且可观察近战敌人数严格大于2
        # => 执行AOE；仅单体及其他情况执行单体
        if ctx.attack_mode == 20 or (ctx.attack_mode == 0 and ctx.player_enemies_count > 2):
            result = self.aoe_rotation(ctx, rage)
        else:
            result = self.single_target_rotation(ctx, rage)
        # 如果 输出分支命中
        # => 执行该动作，否则等待
        if result is not None:
            return result
        return Idle("无满足条件的技能")

    def single_target_rotation(self, ctx: Context, rage: float) -> Cast | None:
        # 如果 目标在近战范围，且盾牌格挡冷却为0、怒气≥10且自身无盾牌格挡
        # => 施放盾牌格挡
        if ctx.target_in_melee_range and (ctx.spell_cd_shield_block == 0 and rage >= 10 and not ctx.player_has_buff_shield_block):
            return Cast("盾牌格挡")
        # 如果 目标在近战范围，且最高已学复仇usable为真且复仇冷却为0
        # => 施放复仇
        if ctx.target_in_melee_range and (ctx.spell_usable_revenge and ctx.spell_cd_revenge == 0):
            return Cast("复仇")
        # 如果 非练级模式，且目标在近战范围，且破甲层数≤2或剩余≤5秒，且怒气≥配置破甲成本
        # => 施放破甲攻击
        if not ctx.leveling_enabled and ctx.target_in_melee_range and ((ctx.target_sunder_armor_stacks <= 2 or ctx.target_sunder_armor_remaining <= 5) and rage >= ctx.sunder_rage_cost):
            return Cast("破甲攻击")
        # 如果 非练级模式，且目标在近战范围，且目标雷霆剩余≤1秒且怒气≥16
        # => 施放雷霆一击
        if not ctx.leveling_enabled and ctx.target_in_melee_range and (ctx.target_thunder_clap_remaining <= 1 and rage >= 16):
            return Cast("雷霆一击")
        # 如果 自身战斗怒吼剩余≤5秒且怒气≥10；不要求近战射程
        # => 施放战斗怒吼
        if ctx.player_battle_shout_remaining <= 5 and rage >= 10:
            return Cast("战斗怒吼")
        # 如果 非练级模式，且目标在近战范围，且目标挫志剩余≤1秒且怒气≥10
        # => 施放挫志怒吼
        if not ctx.leveling_enabled and ctx.target_in_melee_range and (ctx.target_demoralizing_shout_remaining <= 1 and rage >= 10):
            return Cast("挫志怒吼")
        # 如果 非练级模式，且目标在近战范围，且破甲层数<5或剩余≤5秒，且怒气≥配置破甲成本
        # => 施放破甲攻击
        if not ctx.leveling_enabled and ctx.target_in_melee_range and ((ctx.target_sunder_armor_stacks < 5 or ctx.target_sunder_armor_remaining <= 5) and rage >= ctx.sunder_rage_cost):
            return Cast("破甲攻击")
        # 如果 目标在近战范围，且练级模式下目标无自身撕裂（普通模式为剩余≤1秒）、怒气≥20、目标类型不是0/4/9且撕裂开启
        # => 施放撕裂
        if ctx.target_in_melee_range and ((not ctx.target_has_debuff_rend if ctx.leveling_enabled else ctx.target_rend_remaining <= 1) and rage >= 20 and ctx.target_creature_type not in (0, 4, 9) and ctx.rend_enabled):
            return Cast("撕裂")
        # 如果 非练级模式，且目标在近战范围，且怒气≥45
        # => 施放破甲攻击
        if not ctx.leveling_enabled and ctx.target_in_melee_range and (rage >= 45):
            return Cast("破甲攻击")
        # 如果 目标在近战范围，且怒气≥35
        # => 施放英勇打击
        if ctx.target_in_melee_range and (rage >= 35):
            return Cast("英勇打击")
        return None

    def aoe_rotation(self, ctx: Context, rage: float) -> Cast | None:
        # 如果 非练级模式，且目标在近战范围，且目标雷霆剩余≤1秒且怒气≥16
        # => 施放雷霆一击
        if not ctx.leveling_enabled and ctx.target_in_melee_range and (ctx.target_thunder_clap_remaining <= 1 and rage >= 16):
            return Cast("雷霆一击")
        # 如果 目标在近战范围，且盾牌格挡冷却为0、怒气≥10且自身无盾牌格挡
        # => 施放盾牌格挡
        if ctx.target_in_melee_range and (ctx.spell_cd_shield_block == 0 and rage >= 10 and not ctx.player_has_buff_shield_block):
            return Cast("盾牌格挡")
        # 如果 目标在近战范围，且最高已学复仇usable为真且复仇冷却为0
        # => 施放复仇
        if ctx.target_in_melee_range and (ctx.spell_usable_revenge and ctx.spell_cd_revenge == 0):
            return Cast("复仇")
        # 如果 自身战斗怒吼剩余≤5秒且怒气≥20；不要求近战射程
        # => 施放战斗怒吼
        if ctx.player_battle_shout_remaining <= 5 and rage >= 20:
            return Cast("战斗怒吼")
        # 如果 非练级模式，且目标在近战范围，且目标挫志剩余≤1秒且怒气≥10
        # => 施放挫志怒吼
        if not ctx.leveling_enabled and ctx.target_in_melee_range and (ctx.target_demoralizing_shout_remaining <= 1 and rage >= 10):
            return Cast("挫志怒吼")
        # 如果 非练级模式，且目标在近战范围，且破甲层数≤2或剩余≤5秒，且怒气≥配置破甲成本
        # => 施放破甲攻击
        if not ctx.leveling_enabled and ctx.target_in_melee_range and ((ctx.target_sunder_armor_stacks <= 2 or ctx.target_sunder_armor_remaining <= 5) and rage >= ctx.sunder_rage_cost):
            return Cast("破甲攻击")
        # 如果 自身战斗怒吼剩余≤5秒且怒气≥20；不要求近战射程
        # => 施放战斗怒吼
        if ctx.player_battle_shout_remaining <= 5 and rage >= 10:
            return Cast("战斗怒吼")
        # 如果 非练级模式，且目标在近战范围，且目标挫志剩余≤1秒且怒气≥20
        # => 施放挫志怒吼
        if not ctx.leveling_enabled and ctx.target_in_melee_range and (ctx.target_demoralizing_shout_remaining <= 1 and rage >= 20):
            return Cast("挫志怒吼")
        # 如果 非练级模式，且目标在近战范围，且破甲层数<5或剩余≤5秒，且怒气≥配置破甲成本
        # => 施放破甲攻击
        if not ctx.leveling_enabled and ctx.target_in_melee_range and ((ctx.target_sunder_armor_stacks < 5 or ctx.target_sunder_armor_remaining <= 5) and rage >= ctx.sunder_rage_cost):
            return Cast("破甲攻击")
        # 如果 目标在近战范围，且练级模式下目标无自身撕裂（普通模式为剩余≤1秒）、怒气≥20、目标类型不是0/4/9且撕裂开启
        # => 施放撕裂
        if ctx.target_in_melee_range and ((not ctx.target_has_debuff_rend if ctx.leveling_enabled else ctx.target_rend_remaining <= 1) and rage >= 20 and ctx.target_creature_type not in (0, 4, 9) and ctx.rend_enabled):
            return Cast("撕裂")
        # 如果 目标在近战范围，且怒气≥45
        # => 施放顺劈斩
        if ctx.target_in_melee_range and (rage >= 45):
            return Cast("顺劈斩")
        return None
