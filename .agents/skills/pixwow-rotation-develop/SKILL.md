---
name: pixwow-rotation-develop
description: 开发或修改 PixWOW 子项目的 rotation 业务规则及必要配套编码、解码、宏和文档。按需读取 wow-pixel-encoding 与 wow-ui-source，遵守项目规范，并在修改完成后自动启动独立 subagent 审核。
---

# Rotation 开发

先读 [共用规范](references/project-rules.md) 和选中项目 `.context/rotation.md`，遵循根 AGENTS.md 的需求访谈与确认流程。先查明已有行为，再询问仍未确定的业务决策。

## 确定规则与数据

把需求落实为门控、优先级插入位置、目标顺序、精确阈值及单位、爆发/单体/配置关系、动作与失败回退。区分用户希望的策略和当前实现，不凭外部攻略改写已确认规则。

追踪所需 Context 属性是否已有可用来源。缺少属性时读取 wow-pixel-encoding 的 SKILL.md 和对应 reference；涉及 API、事件或原生绑定时定位本地 wow-ui-source 的定义与使用示例，检查版本。纯 Python 优先级修改无需无关地加载全部编码文档。

设计新增输出时同步确定 Lua 位置、编码、刷新、Python 解码及 layout 文档；动态输出保持最长 1 秒兜底，AuraContainer 原生绑定按共用规范豁免。保留现行稳定键位，新增动作核对宏目标与绑定。

## 实现与同步

- 按[Rotation 函数拆分建议](../../../.context/development-principles.md#rotation-函数拆分)适当拆分 `main_rotation`。推荐参考 `check_pause`、`precombat_rotation`、`defensive_rotation`、`interrupt_rotation`、`aoe_rotation`、`single_target_rotation` 六类职责，不强制套用；允许分类方法传参，入口保留适量非战斗、辅助逻辑及模式计算。拆分时核对门控、首个动作返回和各专精已确认的调用顺序。
- 新增或修改 cells Lua 时执行[Lua cells 文件头规范](../../../.context/code-quality.md#lua-cells-文件头)：按规定分组、本地化稳定引用，并核对动态访问例外的生命周期。风格整理保持行为不变，不扩大到未授权文件。
- 按既有模块边界做最小改动，业务判断保留在 Python。每个业务分支按共用规范写条件与结果注释，包括嵌套分支和辅助函数。
- 保留项目专属约定：血 DK 的目标/焦点规则和 F12 预留；兽王已确认的狂野怒火/野兽顺劈规则；奶骑五单位模型、评分及显式目标宏；防骑的射程和打断黑名单差异；惩戒的套装消耗与单多目标定义。详细条件以当前源码、项目文档及新确认需求为准，不在 skill 中固化可变数值。
- 同步受影响的 rotation、keymap、layout 文档，复核返回动作及动态名称都能找到正确宏。不要把格式整理扩大为优先级重构。
- 执行共用规范中的相关静态检查。若修改 Lua 或像素路径，列出需要实机确认的状态转换，不声称静态检查证明了游戏行为。

## 独立审核与完成

修改完成后读取并执行 [rotation 审核](../pixwow-rotation-review/SKILL.md)，启动独立只读 subagent；这是本开发流程的一部分。传递用户确认需求、变更范围和源码入口，不替审核者预设结论。

主 agent 核实审核发现，修复本次引入或阻碍需求的问题；其余历史问题报告即可。修复后只对受影响项复核，必要时让同一审核者重审；不无条件重复全量审核。遇到需要新业务决策或实机证据的问题，明确未决项并请求所需信息，不猜测关闭问题。

subagent 不可用时说明独立审核未完成，可继续静态自查，但不能报告完整流程已通过。完成时说明修改、验证、遗留事项，按根 AGENTS.md 的文件范围规则提交。
