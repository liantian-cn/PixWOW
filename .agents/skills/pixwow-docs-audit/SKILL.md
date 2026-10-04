---
name: pixwow-docs-audit
description: 审查 PixWOW 子项目的 .context/layout.md、keymap.md、rotation.md 是否与当前 Lua 和 Python 代码一致。用于文档核对、文档漂移检查和行为修改后的文档复核；默认只报告，明确要求修复时才修改。
---

# 文档与代码一致性审查

先读 [共用规范](../pixwow-rotation-develop/references/project-rules.md)，确定子项目和审查范围。完整审查覆盖三份文档；用户指定局部时仅检查该部分及必要关联。

## 核对路径

- **layout.md：** 从 TOC 确认可加载文件，再追踪 `pix/lua/cells`、`core/base.lua`、`ui` 及共享 helper 的实际位置和编码，和 `pix/context.py`、`pix/matrix.py` 对照。检查字段名、单位、技能/物品 ID、单位 token、位置、跨度、类型、曲线、量程、缺失/永久/饱和状态和刷新说明。复杂布局按 [像素一致性审查](../pixwow-pixel-audit/SKILL.md) 展开。不要把表中“完成”标志当验证证据。
- **keymap.md：** 三方核对 `Rotation.keymap`、实际返回的 Cast/Use 动作和 `pix/lua/macro.lua` 的启用条目。展开动态治疗动作名，核对组合键、宏换行、单位目标、物品槽位、重复/缺失绑定。固定 reloadUI 是 Lua 辅助动作，不能强行加进 Python 循环。保留现有 F12 预留和根目录宏键顺序约定，不借核对重排绑定。
- **rotation.md：** 顺着 `main_rotation` 和辅助函数按实际执行顺序还原门控、首个匹配返回、目标选择和回退。检查严格阈值、与或关系、配置默认值与可选值、爆发/单体开关、冷却/充能、治疗评分和读条排队窗口。Context 的派生条件（例如打断黑名单）与 Action 的执行语义也属于证据。排除注释掉的代码，不把重复规则擅自改写成新策略。

## 输出与修复边界

按共用规范报告每处文档表述与源码行为的差异，提供两侧位置。区分文档过时、代码疑似偏离已确认需求和信息不足；不默认代码就是期望行为。

用户要求同步文档且行为明确时，最小修改对应文档并检查链接；业务意图冲突时先确认。仅审查文档不自动修改循环、布局或宏。不能将未执行的游戏验证写成已完成。
