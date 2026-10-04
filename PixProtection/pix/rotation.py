"""铸光防骑战斗优先级：从上到下判断，执行首个满足条件的动作。"""

from pix.action import Cast, Idle, Use
from pix.context import Context


class Rotation:
    def __init__(self) -> None:
        self.keymap: dict[str, str] = {
            "目标正义盾击": "RCTRL-NUMPAD1",
            "焦点责难": "RCTRL-NUMPAD2",
            "目标责难": "RCTRL-NUMPAD3",
            "戒卫": "RCTRL-NUMPAD4",
            "目标复仇者之盾": "RCTRL-NUMPAD5",
            "焦点复仇者之盾": "RCTRL-NUMPAD6",
            "奉献": "RCTRL-NUMPAD7",
            "祝福之锤": "RCTRL-NUMPAD8",
            "目标审判": "RCTRL-NUMPAD9",
            "焦点审判": "RCTRL-NUMPAD0",
            "圣洁鸣钟": "RSHIFT-NUMPAD1",
            "神圣壁垒": "RSHIFT-NUMPAD2",
            "圣洁武器": "RSHIFT-NUMPAD3",
            "荣耀圣令": "RSHIFT-NUMPAD4",
            "焦点正义盾击": "RSHIFT-NUMPAD5",
            "圣言祭礼": "RSHIFT-NUMPAD6",
            "清毒术": "RSHIFT-NUMPAD7",
            "上饰品": "RSHIFT-NUMPAD8",
            "下饰品": "RSHIFT-NUMPAD9",
        }

    def main_rotation(self, ctx: Context) -> Cast | Use | Idle:
        # 如果 插件未启用
        # => 不执行动作
        if not ctx.enable:
            return Idle("插件未启用")
        # 如果 处于手动操作延迟窗口
        # => 不执行动作
        if ctx.delaying:
            return Idle("手动操作延迟中")

        # 如果 玩家未存活
        # => 不执行动作
        if not ctx.player_is_alive:
            return Idle("玩家未存活")
        # 如果 玩家骑乘／在载具中、正在输入或地面选点（任一成立）
        # => 不执行动作
        if ctx.player_in_vehicle or ctx.player_is_chatting or ctx.player_is_targeting_spell:
            return Idle("骑乘、载具、输入或地面选点中")

        # 如果 玩家正在施法、引导或蓄力
        # => 等待当前动作结束
        if ctx.player_cast_progress > 0 or ctx.player_is_empowering:
            return Idle("玩家正在施法、引导或蓄力")

        # 如果 玩家脱战
        # => 检查圣言祭礼，然后等待；不执行后续战斗规则
        if not ctx.player_in_combat:
            # 如果 玩家脱战且缺少圣言祭礼增益
            # => 为主手补充圣言祭礼
            if not ctx.player_has_buff_sacred_weapon:
                return Cast("圣言祭礼")
            return Idle("玩家不在战斗")

        # 如果 当前目标存在、存活且可攻击
        # => 标记为有效敌对目标
        target_valid = ctx.target_is_exists and ctx.target_is_alive and ctx.target_can_attack
        # 如果 焦点存在、存活且可攻击
        # => 标记为有效敌对焦点
        focus_valid = ctx.focus_is_exists and ctx.focus_is_alive and ctx.focus_can_attack
        # 如果 目标或焦点任一有效
        # => 满足不另限制射程的敌人存在条件
        any_enemy = target_valid or focus_valid
        # 如果 目标有效且在制裁之锤射程
        # => 允许目标参与盾击、审判和鸣钟等攻击分支
        target_attack = target_valid and ctx.target_in_hammer_of_justice_range
        # 如果 焦点有效且在制裁之锤射程
        # => 允许焦点参与盾击、审判等攻击分支
        focus_attack = focus_valid and ctx.focus_in_hammer_of_justice_range
        # 如果 目标有效且在复仇者之盾自身射程
        # => 允许对目标施放飞盾
        target_shield = target_valid and ctx.target_in_ranged_range
        # 如果 焦点有效且在复仇者之盾自身射程
        # => 允许对焦点施放飞盾
        focus_shield = focus_valid and ctx.focus_in_ranged_range
        holy_power = ctx.power_holy_power
        health = ctx.player_health_pct
        mana = ctx.power_mana_pct
        shining_light = ctx.player_buff_stacks_shining_light

        # 如果 圣能不少于3点，正义盾击增益剩余不超过4秒
        # => 优先对目标施放正义盾击，目标无效或超距时改打焦点
        if holy_power >= 3 and ctx.player_buff_duration_shield_of_the_righteous <= 4:
            # 如果 续防资源与增益条件成立，目标有效且在制裁之锤射程
            # => 对目标施放正义盾击
            if target_attack:
                return Cast("目标正义盾击", "续防")
            # 如果 续防条件成立、目标分支未命中，焦点有效且在制裁之锤射程
            # => 对焦点施放正义盾击
            if focus_attack:
                return Cast("焦点正义盾击", "续防")

        # 如果 闪耀之光为2层，法力至少20%，血量不高于双层治疗阈值
        # => 对自身施放荣耀圣令
        if (shining_light == 2 and mana >= 20
                and health <= ctx.word_of_glory_two_stacks_health_pct):
            return Cast("荣耀圣令", "双层闪耀之光")

        # 如果 闪耀之光为1层，法力至少5%，血量不高于单层治疗阈值
        # => 对自身施放荣耀圣令
        if (shining_light == 1 and mana >= 5
                and health <= ctx.word_of_glory_one_stack_health_pct):
            return Cast("荣耀圣令", "单层闪耀之光")

        # 如果 闪耀之光和小闪耀之光均为2层，圣能至少3点、法力至少50%
        # 如果 血量不高于叠层治疗阈值
        # => 对自身施放荣耀圣令
        if (shining_light == 2 and ctx.player_buff_stacks_shining_light_progress == 2
                and holy_power >= 3 and mana >= 50
                and health <= ctx.word_of_glory_progress_health_pct):
            return Cast("荣耀圣令", "叠层治疗")

        # 如果 飞盾冷却为 0
        # => 按焦点、目标顺序检查原始可打断状态，不检查黑名单
        if ctx.spell_cd_avengers_shield == 0:
            # 如果 飞盾就绪，焦点有效且在飞盾射程、不可协助并且原始施法可打断
            # => 对焦点施放复仇者之盾打断
            if focus_shield and not ctx.focus_can_assist and ctx.focus_cast_interruptible_raw:
                return Cast("焦点复仇者之盾", "打断")
            # 如果 飞盾就绪、焦点打断未命中，目标有效且在飞盾射程、不可协助并且原始施法可打断
            # => 对目标施放复仇者之盾打断
            if target_shield and not ctx.target_can_assist and ctx.target_cast_interruptible_raw:
                return Cast("目标复仇者之盾", "打断")

        # 如果 责难冷却为 0
        # => 按焦点、目标顺序检查射程及黑名单过滤后的可打断状态
        if ctx.spell_cd_rebuke == 0:
            # 如果 责难就绪，焦点有效、不可协助、在责难射程且通过图标与黑名单的可打断检查
            # => 对焦点施放责难
            if (focus_valid and not ctx.focus_can_assist and ctx.focus_in_interrupt_range
                    and ctx.focus_cast_interruptible):
                return Cast("焦点责难")
            # 如果 责难就绪、焦点分支未命中，目标有效、不可协助、在责难射程且通过图标与黑名单的可打断检查
            # => 对目标施放责难
            if (target_valid and not ctx.target_can_assist and ctx.target_in_interrupt_range
                    and ctx.target_cast_interruptible):
                return Cast("目标责难")

        # 如果 有有效敌对单位，玩家静止、奉献增益剩余不超过1秒且技能就绪
        # => 施放奉献
        if (any_enemy and not ctx.player_is_moving
                and ctx.player_buff_duration_consecration <= 1 and ctx.spell_cd_consecration == 0):
            return Cast("奉献")

        # 如果 审判为2充能
        # => 在制裁之锤射程内优先攻击目标，否则尝试焦点
        if ctx.spell_charges_judgment == 2:
            # 如果 审判恰好 2 充能，目标有效且在制裁之锤射程
            # => 对目标施放审判
            if target_attack:
                return Cast("目标审判", "满充能")
            # 如果 审判恰好 2 充能、目标分支未命中，焦点有效且在制裁之锤射程
            # => 对焦点施放审判
            if focus_attack:
                return Cast("焦点审判", "满充能")

        # 如果 自动饰品开启、爆发窗口有效，且目标或焦点在制裁之锤射程内
        # => 先使用上饰品，再使用下饰品；下一轮重新读取就绪状态
        if ctx.auto_trinket_enabled and ctx.in_burst and (target_attack or focus_attack):
            # 如果 上述自动饰品、爆发及射程条件成立，且上饰品可用
            # => 使用上饰品
            if ctx.ticket_13_ready:
                return Use("上饰品")
            # 如果 上述饰品条件成立、上饰品未使用且下饰品可用
            # => 使用下饰品
            if ctx.ticket_14_ready:
                return Use("下饰品")

        # 如果 有有效敌对单位、爆发窗口有效且戒卫就绪
        # => 施放戒卫，移动中也可使用
        if any_enemy and ctx.in_burst and ctx.spell_cd_sentinel == 0:
            return Cast("戒卫")

        # 如果 未强制单体且制裁之锤范围内可观察敌人数至少 2 个
        # => 标记为多目标条件
        multi_target = not ctx.force_single_target and ctx.player_melee_enemies_count >= 2
        # 如果 目标有效且在制裁之锤射程、爆发窗口有效、多目标、圣能不多于 2 点且鸣钟就绪
        # => 对当前目标施放圣洁鸣钟，移动中也可使用
        if (target_attack and ctx.in_burst and multi_target and holy_power <= 2
                and ctx.spell_cd_divine_toll == 0):
            return Cast("圣洁鸣钟")

        # 如果 有有效敌对目标或焦点，且爆发窗口有效
        # => 按当前军备形态检查 2 充能施放条件
        if any_enemy and ctx.in_burst:
            # 如果 上述军备条件成立、形态为神圣壁垒且壁垒恰好 2 充能
            # => 对自身施放神圣壁垒
            if ctx.spec_protection_holy_armaments == 1 and ctx.spell_charges_holy_bulwark == 2:
                return Cast("神圣壁垒")
            # 如果 上述军备条件成立、形态为圣洁武器且武器恰好 2 充能
            # => 对自身施放圣洁武器
            if ctx.spec_protection_holy_armaments == 2 and ctx.spell_charges_sacred_weapon == 2:
                return Cast("圣洁武器")

        # 如果 飞盾就绪
        # => 在飞盾自身射程内优先攻击目标，否则尝试焦点
        if ctx.spell_cd_avengers_shield == 0:
            # 如果 飞盾就绪，目标有效且在飞盾自身射程
            # => 对目标施放复仇者之盾
            if target_shield:
                return Cast("目标复仇者之盾")
            # 如果 飞盾就绪、目标分支未命中，焦点有效且在飞盾自身射程
            # => 对焦点施放复仇者之盾
            if focus_shield:
                return Cast("焦点复仇者之盾")

        # 如果 审判为1充能
        # => 在制裁之锤射程内优先攻击目标，否则尝试焦点
        if ctx.spell_charges_judgment == 1:
            # 如果 审判恰好 1 充能，目标有效且在制裁之锤射程
            # => 对目标施放审判
            if target_attack:
                return Cast("目标审判")
            # 如果 审判恰好 1 充能、目标分支未命中，焦点有效且在制裁之锤射程
            # => 对焦点施放审判
            if focus_attack:
                return Cast("焦点审判")

        # 如果 圣能为5点
        # => 在制裁之锤射程内施放正义盾击，优先目标、其次焦点
        if holy_power == 5:
            # 如果 圣能恰好 5 点，目标有效且在制裁之锤射程
            # => 对目标施放正义盾击
            if target_attack:
                return Cast("目标正义盾击", "满圣能")
            # 如果 圣能恰好 5 点、目标分支未命中，焦点有效且在制裁之锤射程
            # => 对焦点施放正义盾击
            if focus_attack:
                return Cast("焦点正义盾击", "满圣能")

        # 如果 自动清毒开启，自身有可驱散的中毒或疾病，且清毒术就绪
        # => 对自身清毒；无敌对目标时仍执行，优先级仅在祝福之锤之前
        if (ctx.auto_cleanse_enabled and ctx.player_has_dispellable_poison_or_disease
                and ctx.spell_cd_cleanse_toxins == 0):
            return Cast("清毒术")

        # 如果 有有效敌对单位，且祝福之锤至少有1充能
        # => 施放祝福之锤，不检查敌人距离
        if any_enemy and ctx.spell_charges_blessed_hammer >= 1:
            return Cast("祝福之锤")

        return Idle("没有满足条件的动作")
