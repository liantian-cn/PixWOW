"""烈日奶骑治疗优先级：动态选择小队成员，执行首个满足条件的动作。"""

from pix.action import Cast, Idle, Use
from pix.context import Context, PartyMember


class Rotation:
    def __init__(self) -> None:
        self.keymap: dict[str, str] = {
            "荣耀圣令_player": "RCTRL-NUMPAD1",
            "荣耀圣令_party1": "RCTRL-NUMPAD2",
            "荣耀圣令_party2": "RCTRL-NUMPAD3",
            "荣耀圣令_party3": "RCTRL-NUMPAD4",
            "荣耀圣令_party4": "RCTRL-NUMPAD5",
            "圣光术_player": "RCTRL-NUMPAD6",
            "圣光术_party1": "RCTRL-NUMPAD7",
            "圣光术_party2": "RCTRL-NUMPAD8",
            "圣光术_party3": "RCTRL-NUMPAD9",
            "圣光术_party4": "RCTRL-NUMPAD0",
            "圣光闪现_player": "RSHIFT-NUMPAD1",
            "圣光闪现_party1": "RSHIFT-NUMPAD2",
            "圣光闪现_party2": "RSHIFT-NUMPAD3",
            "圣光闪现_party3": "RSHIFT-NUMPAD4",
            "圣光闪现_party4": "RSHIFT-NUMPAD5",
            "神圣震击_player": "RSHIFT-NUMPAD6",
            "神圣震击_party1": "RSHIFT-NUMPAD7",
            "神圣震击_party2": "RSHIFT-NUMPAD8",
            "神圣震击_party3": "RSHIFT-NUMPAD9",
            "神圣震击_party4": "RSHIFT-NUMPAD0",
            "美德道标_player": "RCTRL-F1",
            "美德道标_party1": "RCTRL-F2",
            "美德道标_party2": "RCTRL-F3",
            "美德道标_party3": "RCTRL-F4",
            "美德道标_party4": "RCTRL-F5",
            "圣洁鸣钟_player": "RCTRL-F6",
            "圣洁鸣钟_party1": "RCTRL-F7",
            "圣洁鸣钟_party2": "RCTRL-F8",
            "圣洁鸣钟_party3": "RCTRL-F9",
            "圣洁鸣钟_party4": "RCTRL-F10",
            "清洁术_player": "RCTRL-F11",
            "清洁术_party1": "RSHIFT-F1",
            "清洁术_party2": "RSHIFT-F2",
            "清洁术_party3": "RSHIFT-F3",
            "清洁术_party4": "RSHIFT-F4",
            "荣耀圣令_target": "RSHIFT-F5",
            "圣光术_target": "RSHIFT-F6",
            "圣光闪现_target": "RSHIFT-F7",
            "神圣震击_target": "RSHIFT-F8",
            "清洁术_target": "RSHIFT-F9",
            "攻击审判": "RSHIFT-F10",
            "攻击神圣震击": "RSHIFT-F11",
            "攻击正义盾击": "RSHIFT-F12",
            "圣疗术_player": "RALT-F1",
            "上饰品": "RALT-F2",
            "下饰品": "RALT-F3",
            "治疗药水_271884": "RALT-F5",
            "治疗药水_271883": "RALT-F6",
            "治疗药水_241304": "RALT-F7",
            "停止施法": "RALT-F8",
        }

    def calculate_party_health_score(self, ctx: Context) -> list[PartyMember]:
        party: list[PartyMember] = []
        for member in ctx.party.values():
            # 如果 成员不存在、未存活、离线、不可协助或不在治疗范围（任一成立）
            # => 从五单位治疗候选中排除该成员
            if not (member["exist"] and member["alive"] and member["connected"]
                    and member["can_assist"] and member["in_healing_range"]):
                continue
            # 如果 成员有救赎之魂
            # => 不将该成员加入治疗候选
            if member["has_spirit_of_redemption"]:
                continue
            scored = member.copy()
            health = member["health_pct"]
            # 如果 成员职业为死亡骑士（6）且职责为坦克（1）
            # => 先计入护盾血量加成，再按血 DK 分段映射参与统一生命评分
            if member["class_id"] == 6 and member["role"] == 1:
                # 如果 血 DK 存在任意来源、任意大小的伤害吸收盾
                # => 映射前的预测血量增加 20 个百分点
                if member["has_damage_absorb"]:
                    health += 20
                # 如果 血 DK 计入护盾加成后的血量至少为 80%
                # => 基础评分按 100 计算
                if health >= 80:
                    health = 100.0
                # 如果 血 DK 计入护盾加成后的血量严格大于 1% 且小于 80%
                # => 将 1%–80% 均匀映射到 1–100；不超过 1% 时保留原值
                elif health > 1:
                    health = 1 + (health - 1) * 99 / 79
            score = health - member["heal_absorb_pct"]
            # 如果 玩家正在普通读条且该成员就是当前读条目标
            # => 按施法种类预估本次治疗对评分的增量
            if ctx.player_cast_state == 1 and member["unit"] == ctx.player_cast_target:
                # 如果 上述读条目标条件成立且正在施放圣光术
                # => 生命评分增加 40 个百分点
                if ctx.player_cast_kind == 1:
                    score += 40
                # 如果 上述读条目标条件成立且正在施放圣光闪现
                # => 生命评分增加 15 个百分点；其他施法种类不增加
                elif ctx.player_cast_kind == 2:
                    score += 15
            scored["health_score"] = score
            party.append(scored)
        return party

    @staticmethod
    def lowest_member(party: list[PartyMember], threshold: float = 100,
                      role: int | None = None) -> PartyMember | None:
        # 如果 成员评分严格低于阈值，且未限定职责或职责匹配
        # => 加入候选并按评分升序排列；负评分也可成为最低成员
        injured = [member for member in party
                   if member["health_score"] < threshold and (role is None or member["role"] == role)]
        injured.sort(key=lambda member: member["health_score"])
        # 如果 筛选后有成员
        # => 返回评分最低成员；没有则返回 None
        return injured[0] if injured else None

    @staticmethod
    def count_injured(party: list[PartyMember], threshold: float) -> int:
        # 如果 成员评分严格大于 0 且严格小于阈值
        # => 计入受伤人数；零分和负分不计入人数
        return sum(0 < member["health_score"] < threshold for member in party)

    @staticmethod
    def healing_cast(spell: str, member: PartyMember, note: str = "") -> Cast:
        return Cast(f"{spell}_{member['unit']}", note)

    def main_rotation(self, ctx: Context) -> Cast | Use | Idle:
        # 如果 插件未启用
        # => 不执行动作
        if not ctx.enable:
            return Idle("插件未启用")
        # 如果 处于手动操作延迟窗口
        # => 暂停自动动作
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

        # 如果 遭遇编号为 100，且 boss1 或 boss2 已过施法时间至少 4 秒
        # => 优先处理停止施法，并等待危险窗口结束
        if ctx.encounter_index == 100 and max(ctx.boss1_cast_elapsed, ctx.boss2_cast_elapsed) >= 4:
            # 如果 上述危险窗口内，玩家施法状态非 0 或正在蓄力
            # => 停止施法；没有施法时继续等待
            if ctx.player_cast_state or ctx.player_is_empowering:
                return Use("停止施法")
            return Idle("首领危险施法中")

        # 如果 玩家正在引导或蓄力
        # => 等待当前技能结束
        if ctx.player_cast_state == 2 or ctx.player_is_empowering:
            return Idle("玩家正在引导或蓄力")
        # 如果 玩家正在普通读条，且剩余时间严格大于 0.4 秒
        # => 等待进入最后 0.4 秒排队窗口
        if ctx.player_cast_state == 1 and ctx.player_cast_remaining > 0.4:
            return Idle("等待读条排队窗口")

        party = self.calculate_party_health_score(ctx)
        lowest = self.lowest_member(party)
        damage_lowest = self.lowest_member(party, role=3)
        mana = ctx.power_mana_pct
        holy_power = ctx.power_holy_power
        # 如果 玩家正在普通读条且技能种类为圣光术或圣光闪现
        # => 本轮预估圣能增加 1 点
        if ctx.player_cast_state == 1 and ctx.player_cast_kind in (1, 2):
            holy_power += 1
        infusion = ctx.player_buff_duration_infusion_of_light
        divinity = ctx.player_buff_duration_hand_of_divinity
        purpose = ctx.player_buff_duration_divine_purpose
        awakening = ctx.player_buff_duration_awakening
        charges = ctx.spell_charges_holy_shock
        holy_threshold = int(mana - 25)
        flash_lowest = self.lowest_member(party, int(100 - infusion))
        divinity_lowest = self.lowest_member(party, int(100 - 2 * divinity))
        holy_lowest = self.lowest_member(party, holy_threshold)
        c90 = self.count_injured(party, 90)
        c80 = self.count_injured(party, 80)
        c70 = self.count_injured(party, 70)
        c_holy = self.count_injured(party, holy_threshold)
        # 如果 目标存在、存活、可协助且在圣光术射程
        # => 标记当前目标可治疗
        friendly_target = (ctx.target_is_exists and ctx.target_is_alive
                           and ctx.target_can_assist and ctx.target_in_healing_range)
        # 如果 目标存在、存活、可攻击且在制裁之锤射程
        # => 标记当前目标可用于输出
        enemy_target = (ctx.target_is_exists and ctx.target_is_alive
                        and ctx.target_can_attack and ctx.target_in_hammer_of_justice_range)

        # 如果 自动驱散开启且清洁术冷却为 0
        # => 依次筛选魔法、疾病、中毒队友，再检查当前友方目标
        if ctx.auto_cleanse_enabled and ctx.spell_cd_cleanse == 0:
            # 如果 合格成员有可驱散魔法
            # => 按成员原有顺序列为魔法驱散候选
            magic = [member for member in party if member["dispellable_magic"]]
            # 如果 合格成员有可驱散疾病
            # => 按成员原有顺序列为疾病驱散候选
            disease = [member for member in party if member["dispellable_disease"]]
            # 如果 合格成员有可驱散中毒
            # => 按成员原有顺序列为中毒驱散候选
            poison = [member for member in party if member["dispellable_poison"]]
            for candidates in (magic, disease, poison):
                # 如果 当前驱散类型有合格候选成员
                # => 对该类型的第一名成员施放清洁术，保留五单位枚举顺序
                if candidates:
                    return self.healing_cast("清洁术", candidates[0])
            # 如果 前序队友驱散未命中，当前目标可治疗且有魔法、疾病或中毒任一可驱散效果
            # => 对当前目标施放清洁术
            if friendly_target and (ctx.target_dispellable_magic or ctx.target_dispellable_disease
                                    or ctx.target_dispellable_poison):
                return Cast("清洁术_target")

        # 如果 药水的就绪字段为真
        # => 按 271884、271883、241304 顺序取第一种；全不可用时得到 None
        potion = next((item for item, ready in (
            (271884, ctx.concentrated_potion_high_ready),
            (271883, ctx.concentrated_potion_ready),
            (241304, ctx.heal_potion_ready),
        ) if ready), None)
        # 如果 自身生命不高于 30% 且已选出可用治疗药水
        # => 使用按 271884、271883、241304 顺序选中的药水
        if ctx.player_health_pct <= 30 and potion is not None:
            return Use(f"治疗药水_{potion}")
        # 如果 自身生命不高于 20%、没有可用治疗药水且圣疗术冷却为 0
        # => 对自身施放圣疗术
        if ctx.player_health_pct <= 20 and potion is None and ctx.spell_cd_lay_on_hands == 0:
            return Cast("圣疗术_player")

        # 如果 玩家在战斗、爆发窗口有效且自动饰品开启
        # => 按上饰品、下饰品顺序检查
        if ctx.player_in_combat and ctx.in_burst and ctx.auto_trinket_enabled:
            # 如果 上述饰品条件成立且上饰品可用
            # => 使用上饰品
            if ctx.ticket_13_ready:
                return Use("上饰品")
            # 如果 上述饰品条件成立、上饰品未使用且下饰品可用
            # => 使用下饰品
            if ctx.ticket_14_ready:
                return Use("下饰品")

        # 如果 遭遇编号为 92 且存在评分低于 100 的最低成员
        # => 按圣令、灌注闪现、震击、圣光术顺序治疗该成员
        if ctx.encounter_index == 92 and lowest is not None:
            # 如果 上述首领 92 条件成立且预估圣能至少 3 点
            # => 对最低成员施放荣耀圣令
            if holy_power >= 3:
                return self.healing_cast("荣耀圣令", lowest)
            # 如果 上述首领 92 条件成立、前序未命中且灌注剩余大于 0 秒
            # => 对最低成员施放圣光闪现
            if infusion > 0:
                return self.healing_cast("圣光闪现", lowest)
            # 如果 上述首领 92 条件成立、前序未命中且震击充能至少 1 层
            # => 对最低成员施放神圣震击
            if charges >= 1:
                return self.healing_cast("神圣震击", lowest)
            # 如果 上述首领 92 条件成立、前序未命中且灌注剩余为 0 秒
            # => 对最低成员施放圣光术
            if infusion == 0:
                return self.healing_cast("圣光术", lowest)

        # 如果 存在评分低于 100 的最低成员
        # => 检查常规及脱战荣耀圣令条件
        if lowest is not None:
            # 如果 最低成员评分不高于 80，且预估圣能至少 3 点或神圣意志剩余大于 0 秒
            # => 对最低成员施放荣耀圣令
            if lowest["health_score"] <= 80 and (holy_power >= 3 or purpose > 0):
                return self.healing_cast("荣耀圣令", lowest)
            # 如果 最低成员存在、玩家脱战，且神圣意志剩余在 (0,5] 秒或预估圣能恰好 5 点
            # => 对最低成员施放荣耀圣令
            if not ctx.player_in_combat and (0 < purpose <= 5 or holy_power == 5):
                return self.healing_cast("荣耀圣令", lowest)

        # 如果 玩家在战斗、当前敌人在制裁之锤范围，且预估圣能至少 3 点或神圣意志剩余在 (0,3] 秒
        # => 对当前目标施放正义盾击
        if ctx.player_in_combat and enemy_target and (holy_power >= 3 or 0 < purpose <= 3):
            return Cast("攻击正义盾击")

        # 如果 灌注剩余大于 0 秒，且存在评分严格低于 int(100−灌注剩余秒数) 的成员
        # => 对该阈值下评分最低成员施放圣光闪现
        if infusion > 0 and flash_lowest is not None:
            return self.healing_cast("圣光闪现", flash_lowest)

        # 如果 玩家在战斗，存在输出职责最低成员且其评分不高于 80
        # => 依次检查美德道标与圣洁鸣钟的群疗条件
        if ctx.player_in_combat and damage_lowest is not None and damage_lowest["health_score"] <= 80:
            # 如果 上述群疗条件成立，道标冷却为 0，且至少 3 人评分在 (0,90) 或至少 2 人在 (0,80)
            # => 对输出职责最低成员施放美德道标
            if ctx.spell_cd_beacon_of_virtue == 0 and (c90 >= 3 or c80 >= 2):
                return self.healing_cast("美德道标", damage_lowest)
            # 如果 上述群疗条件成立、道标未命中，预估圣能不多于 1 点、鸣钟冷却为 0，且至少 3 人评分在 (0,80) 或至少 2 人在 (0,70)
            # => 对输出职责最低成员施放圣洁鸣钟
            if holy_power <= 1 and ctx.spell_cd_divine_toll == 0 and (c80 >= 3 or c70 >= 2):
                return self.healing_cast("圣洁鸣钟", damage_lowest)

        # 如果 神性之手剩余大于 0 秒且灌注剩余为 0 秒
        # => 优先按神性动态阈值，再按最低评分不高于 80 检查圣光术
        if divinity > 0 and infusion == 0:
            # 如果 上述神性条件成立，存在评分严格低于 int(100−2×神性之手剩余秒数) 的成员
            # => 对该阈值下评分最低成员施放圣光术
            if divinity_lowest is not None:
                return self.healing_cast("圣光术", divinity_lowest)
            # 如果 上述神性条件成立且动态阈值分支未命中，最低成员存在并且评分不高于 80
            # => 对最低成员施放圣光术
            if lowest is not None and lowest["health_score"] <= 80:
                return self.healing_cast("圣光术", lowest)

        # 如果 审判就绪，战斗中有范围内敌人，且觉醒存在或没有圣光灌注
        # => 优先审判
        # 如果 玩家在战斗、敌对目标有效且在制裁之锤射程、审判冷却为 0
        # => 标记可用审判输出；后续优先分支另检查觉醒或灌注
        judgment_ready = ctx.player_in_combat and enemy_target and ctx.spell_cd_judgment == 0
        # 如果 战斗中目标有效且在制裁之锤范围、审判冷却为 0，并且觉醒剩余大于 0 秒或无灌注
        # => 对当前目标优先施放审判
        if judgment_ready and (awakening > 0 or infusion == 0):
            return Cast("攻击审判")

        # 如果 存在评分低于 100 的最低成员
        # => 按满充能、即将恢复第二层、低评分顺序检查治疗震击
        if lowest is not None:
            # 如果 上述最低成员存在且震击充能恰好 2 层
            # => 对最低成员施放神圣震击
            if charges == 2:
                return self.healing_cast("神圣震击", lowest, "满充能")
            # 如果 上述最低成员存在、震击充能恰好 1 层，且下一层恢复不超过 1 秒
            # => 对最低成员施放神圣震击
            if charges == 1 and ctx.spell_recharge_holy_shock <= 1:
                return self.healing_cast("神圣震击", lowest, "即将恢复充能")
            # 如果 上述最低成员存在、震击充能恰好 1 层、成员评分不高于 90 且无灌注
            # => 对最低成员施放神圣震击
            if charges == 1 and lowest["health_score"] <= 90 and infusion == 0:
                return self.healing_cast("神圣震击", lowest)

        # 如果 战斗中目标有效且在制裁之锤范围，审判冷却为 0
        # => 对当前目标施放审判填充输出
        if judgment_ready:
            return Cast("攻击审判")
        # 如果 玩家在战斗、当前敌人在制裁之锤范围且神圣震击冷却为 0
        # => 对当前目标施放神圣震击填充输出
        if ctx.player_in_combat and enemy_target and ctx.spell_cd_holy_shock == 0:
            return Cast("攻击神圣震击")

        # 如果 灌注剩余为 0 秒
        # => 检查圣光术填充，先判断受伤人数，再判断静止单人治疗
        if infusion == 0:
            # 如果 无灌注，至少 2 人评分在 (0,int(法力百分比−25)) 且最低成员存在
            # => 对最低成员施放圣光术；此分支没有移动限制
            if c_holy >= 2 and lowest is not None:
                return self.healing_cast("圣光术", lowest)
            # 如果 无灌注、前序填充未命中，存在低于圣光阈值的成员且玩家静止
            # => 对该阈值下评分最低成员施放圣光术
            if holy_lowest is not None and not ctx.player_is_moving:
                return self.healing_cast("圣光术", holy_lowest)

        # 如果 遭遇编号为 107，当前目标可治疗且是 boss1
        # => 最后按圣令、灌注闪现、震击、圣光术顺序治疗该首领
        if ctx.encounter_index == 107 and friendly_target and ctx.target_is_boss1:
            # 如果 上述首领 107 条件成立且预估圣能至少 3 点
            # => 对当前首领目标施放荣耀圣令
            if holy_power >= 3:
                return Cast("荣耀圣令_target")
            # 如果 上述首领 107 条件成立、前序未命中且灌注剩余大于 0 秒
            # => 对当前首领目标施放圣光闪现
            if infusion > 0:
                return Cast("圣光闪现_target")
            # 如果 上述首领 107 条件成立、前序未命中且震击充能大于 0 层
            # => 对当前首领目标施放神圣震击
            if charges > 0:
                return Cast("神圣震击_target")
            # 如果 上述首领 107 条件成立、前序未命中且法力至少 30%
            # => 对当前首领目标施放圣光术
            if mana >= 30:
                return Cast("圣光术_target")

        return Idle("没有满足条件的动作")
