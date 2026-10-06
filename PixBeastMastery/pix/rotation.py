"""猎群领袖兽王猎：按优先级执行第一个满足条件的动作。"""

from pix.action import Cast, Idle, Use
from pix.context import Context


class Rotation:
    def __init__(self) -> None:
        self.keymap: dict[str, str] = {
            "倒刺射击": "RCTRL-NUMPAD1",
            "焦点反制射击": "RCTRL-NUMPAD2",
            "目标反制射击": "RCTRL-NUMPAD3",
            "鼠标指向反制射击": "RSHIFT-NUMPAD0",
            "狂野怒火": "RCTRL-NUMPAD4",
            "狂野鞭笞": "RCTRL-NUMPAD5",
            "杀戮命令": "RCTRL-NUMPAD6",
            "眼镜蛇射击": "RCTRL-NUMPAD7",
            "爆发药水": "RCTRL-NUMPAD8",
            "治疗宠物": "RCTRL-NUMPAD9",
            "召唤/复活宠物": "RCTRL-NUMPAD0",
            "误导party1": "RSHIFT-NUMPAD1",
            "误导party2": "RSHIFT-NUMPAD2",
            "误导party3": "RSHIFT-NUMPAD3",
            "误导party4": "RSHIFT-NUMPAD4",
            "治疗石": "RSHIFT-NUMPAD5",
            "银月城生命药水": "RSHIFT-NUMPAD6",
            "意气风发": "RSHIFT-NUMPAD7",
            "上饰品": "RSHIFT-NUMPAD8",
            "下饰品": "RSHIFT-NUMPAD9",
        }

    def check_pause(self, ctx: Context) -> Idle | None:
        """检查全局暂停条件；返回 Idle 时结束本轮。"""
        # 如果 插件未启用
        # => 不执行动作
        if not ctx.enable:
            return Idle("插件未启用")
        # 如果 处于手动延迟窗口
        # => 暂停全部自动动作
        if ctx.delaying:
            return Idle("手动操作延迟中")
        # 如果 玩家未存活
        # => 不执行动作
        if not ctx.player_is_alive:
            return Idle("玩家未存活")
        # 如果 玩家骑乘／在载具中、正在输入或地面选点（任一成立）
        # => 不执行动作
        if ctx.player_in_vehicle or ctx.player_is_chatting or ctx.player_is_targeting_spell:
            return Idle("坐骑、载具、输入或地面选点中")
        # 如果 施法／引导进度大于 0，或正在蓄力
        # => 等待当前动作结束
        if ctx.player_cast_progress > 0 or ctx.player_is_empowering:
            return Idle("玩家正在施法、引导或蓄力")
        return None

    def precombat_rotation(self, ctx: Context) -> Cast | Idle | None:
        """每轮处理宠物恢复、脱战误导及战斗／目标门控。"""
        # 如果 宠物不存在或未存活
        # => 优先恢复宠物，先检查玩家是否站定；此处不要求战斗或目标
        if not ctx.pet_is_exists or not ctx.pet_is_alive:
            # 如果 需要恢复宠物且玩家正在移动
            # => 等待站定；站定后执行召唤／复活宏
            if ctx.player_is_moving:
                return Idle("等待站定召唤或复活宠物")
            return Cast("召唤/复活宠物")

        # 如果 玩家脱战且在非团队小队，误导已学会且冷却为 0；第一位存活在线坦克编号为 1–4 且在误导射程
        # => 对该坦克施放误导；先选坦克再检查射程，不改选后续坦克
        if (not ctx.player_in_combat and ctx.player_in_party
                and ctx.spell_known_misdirection and ctx.spell_cd_misdirection == 0
                and 1 <= ctx.party_tank_index <= 4 and ctx.party_tank_in_misdirection_range):
            return Cast(f"误导party{ctx.party_tank_index}")
        # 如果 玩家不在战斗
        # => 不执行后续打断、自保、输出或治疗宠物
        if not ctx.player_in_combat:
            return Idle("玩家不在战斗")
        # 如果 当前目标不存在、未存活或不可攻击（任一成立）
        # => 不执行后续动作
        if not (ctx.target_is_exists and ctx.target_is_alive and ctx.target_can_attack):
            return Idle("目标不可攻击")
        return None

    def defensive_rotation(self, ctx: Context) -> Cast | Use | None:
        """通过战斗及有效目标门控后，优先检查自保。"""
        # 如果 自身生命不高于 30% 且治疗石可用
        # => 使用治疗石
        if ctx.player_health_pct <= 30 and ctx.healthstone_ready:
            return Use("治疗石")
        # 如果 自身生命不高于 30% 且治疗药水可用，前序治疗石未使用
        # => 使用银月城生命药水
        if ctx.player_health_pct <= 30 and ctx.heal_potion_ready:
            return Use("银月城生命药水")
        # 如果 自身生命不高于 50% 且意气风发冷却为 0
        # => 施放意气风发
        if ctx.player_health_pct <= 50 and ctx.spell_cd_exhilaration == 0:
            return Cast("意气风发")
        return None

    def interrupt_rotation(self, ctx: Context) -> Cast | None:
        """通过战斗及有效目标门控、自保未命中后，按单位优先级打断。"""
        # 如果 反制射击冷却为 0
        # => 按焦点、鼠标指向、目标顺序检查打断
        if ctx.spell_cd_counter_shot == 0:
            # 三种打断共用已过进度阈值，按焦点、鼠标指向、目标依次判断。
            interrupt_progress = ctx.interrupt_progress_threshold
            # 如果 反制射击就绪，焦点存在、存活、可攻击且不可协助，在打断射程，通过黑名单检查且已过进度严格大于阈值
            # => 对焦点施放反制射击
            if (ctx.focus_is_exists and ctx.focus_is_alive and ctx.focus_can_attack
                    and not ctx.focus_can_assist and ctx.focus_in_interrupt_range
                    and ctx.focus_cast_interruptible and ctx.focus_cast_progress > interrupt_progress):
                return Cast("焦点反制射击")
            # 如果 反制射击就绪、前序焦点未命中，鼠标打断开启；鼠标单位存在、存活、可攻击且不可协助，在射程，通过黑名单检查且进度严格大于阈值
            # => 对鼠标指向施放反制射击
            if (ctx.mouseover_interrupt_enabled and ctx.mouseover_is_exists and ctx.mouseover_is_alive
                    and ctx.mouseover_can_attack and not ctx.mouseover_can_assist
                    and ctx.mouseover_in_interrupt_range and ctx.mouseover_cast_interruptible
                    and ctx.mouseover_cast_progress > interrupt_progress):
                return Cast("鼠标指向反制射击")
            # 如果 反制射击就绪、前序打断未命中，目标打断开启；有效当前目标不可协助、在射程，通过黑名单检查且进度严格大于阈值
            # => 对当前目标施放反制射击
            if (ctx.target_interrupt_enabled and not ctx.target_can_assist and ctx.target_in_interrupt_range
                    and ctx.target_cast_interruptible and ctx.target_cast_progress > interrupt_progress):
                return Cast("目标反制射击")
        return None

    def aoe_rotation(self, ctx: Context, is_finishing: bool) -> Cast | Use | None:
        """通过战斗及有效目标门控后，按AOE优先级返回首个药水或技能动作。"""
        # 如果 当前目标不在反制射击射程内
        # => 跳过药水与输出，返回入口继续检查治疗宠物
        if not ctx.target_in_interrupt_range:
            return None

        # 如果 爆发窗口有效、自动爆发药水开启且药水可用
        # => 优先使用爆发药水
        if ctx.in_burst and ctx.burst_potion_enabled and ctx.reckless_potion_ready:
            return Use("爆发药水")

        focus = ctx.power_focus
        barbed_charges = ctx.spell_charges_barbed_shot
        wrath_cd = ctx.spell_cd_bestial_wrath
        thrash_cd = ctx.spell_cd_wild_thrash
        cleave_remaining = ctx.player_buff_beast_cleave_remaining

        # 如果 倒刺射击充能至少 2 层
        # => 施放倒刺射击，满层时避免浪费充能
        if barbed_charges >= 2:
            return Cast("倒刺射击", "满层，避免浪费")
        # 如果 倒刺射击充能至少 1 层，且下一层恢复时间不超过 4 秒
        # => 施放倒刺射击，即将满层时避免浪费充能
        if barbed_charges >= 1 and ctx.spell_recharge_barbed_shot <= 4:
            return Cast("倒刺射击", "即将满层，避免浪费")
        # 如果 倒刺射击充能至少 1 层、狂野怒火冷却不超过 4 秒，且未收尾
        # => 施放倒刺射击，为狂野怒火提供的充能留出空间
        if barbed_charges >= 1 and wrath_cd <= 4 and not is_finishing:
            return Cast("倒刺射击", "即将由狂野怒火获得充能，避免浪费")

        # 如果 狂野怒火冷却为 0、未收尾，且野兽顺劈剩余至少 2 秒
        # => 先检查自动饰品，再在顺劈期间施放狂野怒火
        if wrath_cd == 0 and not is_finishing and cleave_remaining >= 2:
            # 如果 上述AOE怒火条件成立且自动饰品开启
            # => 按上饰品、下饰品顺序检查，不要求爆发窗口
            if ctx.auto_trinket_enabled:
                # 如果 自动饰品开启且上饰品可用
                # => 本轮使用上饰品，下一轮重新判断全部条件
                if ctx.ticket_13_ready:
                    return Use("上饰品")
                # 如果 自动饰品开启、上饰品不可用且下饰品可用
                # => 本轮使用下饰品，下一轮重新判断全部条件
                if ctx.ticket_14_ready:
                    return Use("下饰品")
            return Cast("狂野怒火", "狂野怒火CD好")

        # 如果 狂野鞭笞冷却为 0，且集中值至少 35 点
        # => 施放狂野鞭笞，卡冷却使用
        if thrash_cd == 0 and focus >= 35:
            return Cast("狂野鞭笞", "卡CD打")
        # 如果 集中值至少 35 点、野兽顺劈剩余至少 1 秒，且利牙层数大于 3
        # => 在顺劈期间施放 4 层利牙眼镜蛇射击
        if focus >= 35 and cleave_remaining >= 1 and ctx.player_buff_stacks_cobra_fangs > 3:
            return Cast("眼镜蛇射击", "4层利牙")

        # 如果 狂野怒火冷却不超过 4 秒，且未收尾
        # => 标记怒火即将就绪，随后保留最后 1 层杀戮命令充能
        wrath_soon = wrath_cd <= 4 and not is_finishing
        kill_charges = ctx.spell_charges_kill_command
        # 如果 杀戮命令充能至少 1 层，且并非“怒火即将就绪且杀戮仅剩 1 层”
        # 如果 集中值至少 35 点、野兽顺劈剩余至少 1 秒，且猎群领袖之嚎存在
        # => 施放杀戮命令；怒火前保留充能，以 35 点集中值门槛避免影响鞭笞
        if (kill_charges >= 1 and not (wrath_soon and kill_charges == 1)
                and focus >= 35 and cleave_remaining >= 1
                and ctx.player_has_buff_howl_of_the_pack_leader):
            return Cast("杀戮命令", "猎群领袖之嚎高亮")
        # 如果 杀戮命令充能至少 1 层，且并非“怒火即将就绪且杀戮仅剩 1 层”
        # 如果 集中值至少 35 点、野兽顺劈剩余至少 1 秒，且自然之友存在
        # => 施放杀戮命令；怒火前保留充能，以 35 点集中值门槛避免影响鞭笞
        if (kill_charges >= 1 and not (wrath_soon and kill_charges == 1)
                and focus >= 35 and cleave_remaining >= 1
                and ctx.player_has_buff_natures_ally):
            return Cast("杀戮命令", "自然之友高亮")

        # 如果 倒刺射击充能至少 1 层，且前序规则未命中
        # => 施放兜底倒刺射击
        if barbed_charges >= 1:
            return Cast("倒刺射击", "兜底倒刺")
        # 如果 集中值至少 35 点、狂野鞭笞冷却严格大于 1 秒，且前序规则未命中
        # => 施放兜底眼镜蛇射击，鞭笞将在 1 秒内就绪时留出资源
        if focus >= 35 and thrash_cd > 1:
            return Cast("眼镜蛇射击", "兜底眼镜蛇")
        return None

    def single_target_rotation(self, ctx: Context, is_finishing: bool) -> Cast | Use | None:
        """通过战斗及有效目标门控后，按单体优先级返回首个药水或技能动作。"""
        # 如果 当前目标不在反制射击射程内
        # => 跳过药水与输出，返回入口继续检查治疗宠物
        if not ctx.target_in_interrupt_range:
            return None

        # 如果 爆发窗口有效、自动爆发药水开启且药水可用
        # => 优先使用爆发药水
        if ctx.in_burst and ctx.burst_potion_enabled and ctx.reckless_potion_ready:
            return Use("爆发药水")

        focus = ctx.power_focus
        barbed_charges = ctx.spell_charges_barbed_shot
        wrath_cd = ctx.spell_cd_bestial_wrath

        # 如果 倒刺射击充能至少 2 层
        # => 施放倒刺射击，满层时避免浪费充能
        if barbed_charges >= 2:
            return Cast("倒刺射击", "满层，避免浪费")
        # 如果 倒刺射击充能至少 1 层，且下一层恢复时间不超过 4 秒
        # => 施放倒刺射击，即将满层时避免浪费充能
        if barbed_charges >= 1 and ctx.spell_recharge_barbed_shot <= 4:
            return Cast("倒刺射击", "即将满层，避免浪费")
        # 如果 倒刺射击充能至少 1 层、狂野怒火冷却不超过 4 秒，且未收尾
        # => 施放倒刺射击，为狂野怒火提供的充能留出空间
        if barbed_charges >= 1 and wrath_cd <= 4 and not is_finishing:
            return Cast("倒刺射击", "即将由狂野怒火获得充能，避免浪费")

        # 如果 狂野怒火冷却为 0，且未收尾
        # => 先检查自动饰品，再施放狂野怒火；单体不要求顺劈
        if wrath_cd == 0 and not is_finishing:
            # 如果 上述单体怒火条件成立且自动饰品开启
            # => 按上饰品、下饰品顺序检查，不要求爆发窗口
            if ctx.auto_trinket_enabled:
                # 如果 自动饰品开启且上饰品可用
                # => 本轮使用上饰品，下一轮重新判断全部条件
                if ctx.ticket_13_ready:
                    return Use("上饰品")
                # 如果 自动饰品开启、上饰品不可用且下饰品可用
                # => 本轮使用下饰品，下一轮重新判断全部条件
                if ctx.ticket_14_ready:
                    return Use("下饰品")
            return Cast("狂野怒火", "狂野怒火CD好")

        # 如果 集中值至少 35 点，且利牙层数大于 3
        # => 施放 4 层利牙眼镜蛇射击；单体不要求顺劈
        if focus >= 35 and ctx.player_buff_stacks_cobra_fangs > 3:
            return Cast("眼镜蛇射击", "4层利牙")

        # 如果 狂野怒火冷却不超过 4 秒，且未收尾
        # => 标记怒火即将就绪，随后保留最后 1 层杀戮命令充能
        wrath_soon = wrath_cd <= 4 and not is_finishing
        kill_charges = ctx.spell_charges_kill_command
        # 如果 杀戮命令充能至少 1 层，且并非“怒火即将就绪且杀戮仅剩 1 层”
        # 如果 集中值至少 35 点，且猎群领袖之嚎存在
        # => 施放杀戮命令；怒火前保留充能，以 35 点集中值门槛避免影响鞭笞
        if (kill_charges >= 1 and not (wrath_soon and kill_charges == 1)
                and focus >= 35
                and ctx.player_has_buff_howl_of_the_pack_leader):
            return Cast("杀戮命令", "猎群领袖之嚎高亮")
        # 如果 杀戮命令充能至少 1 层，且并非“怒火即将就绪且杀戮仅剩 1 层”
        # 如果 集中值至少 35 点，且自然之友存在
        # => 施放杀戮命令；怒火前保留充能，以 35 点集中值门槛避免影响鞭笞
        if (kill_charges >= 1 and not (wrath_soon and kill_charges == 1)
                and focus >= 35
                and ctx.player_has_buff_natures_ally):
            return Cast("杀戮命令", "自然之友高亮")

        # 如果 倒刺射击充能至少 1 层，且前序规则未命中
        # => 施放兜底倒刺射击
        if barbed_charges >= 1:
            return Cast("倒刺射击", "兜底倒刺")
        # 如果 集中值至少 35 点，且前序规则未命中
        # => 施放兜底眼镜蛇射击
        if focus >= 35:
            return Cast("眼镜蛇射击", "兜底眼镜蛇")
        return None

    def main_rotation(self, ctx: Context) -> Cast | Use | Idle:
        """按阶段选择首个动作；None 继续，包含 Idle 在内的动作立即返回。"""
        action = self.check_pause(ctx)
        if action is not None:
            return action

        action = self.precombat_rotation(ctx)
        if action is not None:
            return action

        action = self.defensive_rotation(ctx)
        if action is not None:
            return action

        action = self.interrupt_rotation(ctx)
        if action is not None:
            return action

        # 如果 反制射击范围内可观察敌人数至少 2 个
        # => 自动选择 AOE，否则选择单体；随后应用强制模式
        is_aoe = ctx.player_enemies_count >= 2
        # 如果 攻击模式为 10
        # => 强制单体，覆盖自动人数判断
        if ctx.attack_mode == 10:
            is_aoe = False
        # 如果 攻击模式为 20
        # => 强制 AOE，覆盖自动人数判断；其他模式保留自动结果
        elif ctx.attack_mode == 20:
            is_aoe = True

        # 如果 不在遭遇战且目标预测生命严格低于收尾阈值
        # => 自动进入收尾；其他情况不收尾，随后应用强制模式
        is_finishing = not ctx.encounter_in_progress and ctx.target_health_pct < ctx.finishing_health_threshold
        # 如果 收尾模式为 10
        # => 强制不收尾，覆盖遭遇战及血量判断
        if ctx.finishing == 10:
            is_finishing = False
        # 如果 收尾模式为 20
        # => 强制收尾；其他模式保留自动结果
        elif ctx.finishing == 20:
            is_finishing = True

        # debug区域
        # return Idle(f"野兽顺劈剩余{ctx.player_buff_beast_cleave_remaining=}")
        # return Idle(f"野性怒火冷却{ctx.spell_cd_bestial_wrath=}, 倒刺层数{ctx.spell_charges_barbed_shot=},倒刺恢复{ctx.spell_recharge_barbed_shot=}")

        # 如果 自动人数判断或强制模式选中 AOE
        # => 执行完整 AOE 规则；否则执行完整单体规则
        if is_aoe:
            action = self.aoe_rotation(ctx, is_finishing)
        else:
            action = self.single_target_rotation(ctx, is_finishing)
        if action is not None:
            return action

        # 如果 宠物存在且存活、生命严格低于 70%，治疗宠物冷却为 0；前序动作未命中且已通过战斗／目标门控
        # => 施放治疗宠物
        if ctx.pet_is_exists and ctx.pet_is_alive and ctx.pet_health_pct < 70 and ctx.spell_cd_mend_pet == 0:
            return Cast("治疗宠物")
        return Idle("没有满足条件的动作")
