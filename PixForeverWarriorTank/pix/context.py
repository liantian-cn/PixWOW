"""Semantic properties decoded from the current Lua cells and icon tiles."""

import numpy as np

from pix.matrix import Matrix


class Context:
    def __init__(self, matrix: Matrix) -> None:
        self.matrix = matrix

    def readBooleanCell(self, x: int) -> bool:
        return self.matrix.getCell(x).is_white

    def readPercentCell(self, x: int) -> float:
        return self.matrix.getCell(x).percent

    def readNumberCell(self, x: int) -> float:
        return self.matrix.getCell(x).mean

    def readValueBarCell(self, x: int, width: int, max_value: float) -> float:
        return self.matrix.getValueBar(x, width).ratio * max_value

    def readSpellCDCell(self, x: int) -> float:
        return float(np.interp(self.matrix.getCell(x).mean, (0, 25, 115, 155, 255), (245, 120, 30, 10, 0)))

    def readAuraDurationCell(self, x: int) -> float:
        return float(np.interp(self.matrix.getCell(x).mean, (0, 150, 180, 210, 255), (0, 15, 30, 60, 240)))

    def readIconTile(self, x: int) -> str | None:
        return self.matrix.getIconTile(x).hash

    @property
    def enable(self) -> bool:
        return self.readBooleanCell(1)

    @property
    def delaying(self) -> bool:
        return self.readBooleanCell(2)

    @property
    def player_is_alive(self) -> bool:
        return self.readBooleanCell(3)

    @property
    def player_in_combat(self) -> bool:
        return self.readBooleanCell(4)

    @property
    def player_is_player_target(self) -> bool:
        return self.readBooleanCell(5)

    @property
    def player_in_vehicle(self) -> bool:
        return self.readBooleanCell(6)

    @property
    def player_is_targeting_spell(self) -> bool:
        return self.readBooleanCell(7)

    @property
    def player_is_chatting(self) -> bool:
        return self.readBooleanCell(8)

    @property
    def player_cast_progress(self) -> float:
        return self.readPercentCell(9)

    @property
    def player_is_empowering(self) -> bool:
        return self.readBooleanCell(10)

    @property
    def target_is_exists(self) -> bool:
        return self.readBooleanCell(11)

    @property
    def target_is_alive(self) -> bool:
        return self.readBooleanCell(12)

    @property
    def target_can_attack(self) -> bool:
        return self.readBooleanCell(13)

    @property
    def target_cast_interruptible_raw(self) -> bool:
        return self.readBooleanCell(14)

    @property
    def target_cast_progress(self) -> float:
        return self.readPercentCell(15)

    @property
    def target_in_melee_range(self) -> bool:
        return self.readBooleanCell(16)

    @property
    def focus_is_exists(self) -> bool:
        return self.readBooleanCell(17)

    @property
    def focus_is_alive(self) -> bool:
        return self.readBooleanCell(18)

    @property
    def focus_can_attack(self) -> bool:
        return self.readBooleanCell(19)

    @property
    def focus_can_assist(self) -> bool:
        return self.readBooleanCell(20)

    @property
    def focus_cast_interruptible_raw(self) -> bool:
        return self.readBooleanCell(21)

    @property
    def focus_cast_progress(self) -> float:
        return self.readPercentCell(22)

    @property
    def focus_in_melee_range(self) -> bool:
        return self.readBooleanCell(23)

    @property
    def power_rage_ratio(self) -> float:
        return self.matrix.getCell(24).ratio

    @property
    def power_rage_max(self) -> int:
        return int(self.readNumberCell(25) + 0.5)

    @property
    def sunder_rage_cost(self) -> int:
        return int(self.readNumberCell(26) + 0.5)

    @property
    def rend_enabled(self) -> bool:
        return self.readBooleanCell(27)

    @property
    def attack_mode(self) -> int:
        return int(self.readNumberCell(28) + 0.5)

    @property
    def target_interrupt_enabled(self) -> bool:
        return self.readBooleanCell(29)

    @property
    def interrupt_progress_threshold(self) -> float:
        return int(self.readNumberCell(30) + 0.5)

    @property
    def player_enemies_count(self) -> int:
        return int(self.matrix.getCell(31).ratio * 40 + 0.5)

    @property
    def player_stance(self) -> int:
        return int(self.readNumberCell(32) + 0.5)

    @property
    def target_creature_type(self) -> int:
        return int(self.readNumberCell(33) + 0.5)

    @property
    def spell_cd_shield_bash(self) -> float:
        return self.readSpellCDCell(34)

    @property
    def spell_cd_shield_block(self) -> float:
        return self.readSpellCDCell(35)

    @property
    def spell_usable_revenge(self) -> bool:
        return self.readBooleanCell(36)

    @property
    def player_has_buff_shield_block(self) -> bool:
        return self.readBooleanCell(37)

    @property
    def target_sunder_armor_stacks(self) -> int:
        return int(self.readNumberCell(38) + 0.5)

    @property
    def target_sunder_armor_remaining(self) -> float:
        return self.readAuraDurationCell(39)

    @property
    def target_thunder_clap_remaining(self) -> float:
        return self.readAuraDurationCell(40)

    @property
    def player_battle_shout_remaining(self) -> float:
        return self.readAuraDurationCell(41)

    @property
    def target_demoralizing_shout_remaining(self) -> float:
        return self.readAuraDurationCell(42)

    @property
    def target_rend_remaining(self) -> float:
        return self.readAuraDurationCell(43)

    @property
    def target_cast_interruptible(self) -> bool:
        # 如果 原生可打断标记为真且当前施法图标不在黑名单
        # => 允许进入循环的进度与单位检查
        icon = self.readIconTile(3)
        return self.target_cast_interruptible_raw and icon is not None and icon not in self.interrupt_blacklist

    @property
    def focus_cast_interruptible(self) -> bool:
        # 如果 原生可打断标记为真且当前施法图标不在黑名单
        # => 允许进入循环的进度与单位检查
        icon = self.readIconTile(4)
        return self.focus_cast_interruptible_raw and icon is not None and icon not in self.interrupt_blacklist

    @property
    def interrupt_blacklist(self) -> list[str]:
        # 如果 黑名单槽位有有效图标
        # => 将其纳入匹配列表，忽略空槽
        return [icon for x in range(5, 20) if (icon := self.readIconTile(x)) is not None]
