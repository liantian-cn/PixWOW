# PixWOW 共用开发与审核规范

## 范围与证据

仓库根目录以 `AGENTS.md` 和共享 `pyproject.toml` 定位；不能依赖终端当前目录。先确定选中的 PixBlood、PixBeastMastery、PixHoly、PixProtection 或 PixRetribution。请求和上下文都无法确定项目时，询问范围，不默认修改全部项目。以下源码路径均相对选中的子项目。

先读根 AGENTS.md、项目 README.md 和任务相关的 `.context/layout.md`、`keymap.md`、`rotation.md`。分析、比较、修改循环前必须读 rotation.md。各项目拥有独立的 Context、Matrix、Rotation、配置和宏，不能拿 PixBlood 的实现替代其他项目的事实。

源码说明当前行为，用户确认的需求说明期望行为；二者不一致时报告差异，不通过改文档掩盖代码缺陷。现有代码只是实现参考，不代表满足本规范。保留根 AGENTS.md 的访谈、确认、最小修改和文件范围提交要求。

## 项目约定的单一来源

按任务读取根 `.context`，开发与审查使用同一份约定：

- [项目开发思路](../../../../.context/development-principles.md)：模块职责、正常游戏环境的范围、业务数值归属与文档分工。
- [代码质量控制](../../../../.context/code-quality.md)：如果／=> 业务注释、最长 1 秒周期兜底、原生绑定豁免及静态验证。
- [WoW API 与解析约定](../../../../.context/wow-api-notes.md)：Deprecated API、预测生命、秘密值显示、false／0 兜底、图标比较和药水品阶。

这些正文只在根 `.context` 维护，skill 负责流程和按需引用。已确认的设计不能仅因与通用建议不同就再次列为缺陷；存在具体偏离、新故障或支持环境变化时，仍应报告证据。

## 外部参考

需要新增或解释属性编码、秘密值、原生绑定、刷新或反向解析时，按当前技能目录中的名称 `wow-pixel-encoding` 找到并读取其 SKILL.md，然后只加载相关 reference。它提供编码知识，不提供本项目的截图定位、轮转或执行框架。不要复制全套经验到本仓库，也不在项目 skill 中写死用户主目录。

涉及 WoW API 签名、秘密值限制、事件、模板或原生显示生命周期时，优先查仓库相邻的 `../wow-ui-source`。记录其 `version.txt`/提交与选中项目 TOC 的版本，按 API 名定向搜索 `Interface/AddOns/Blizzard_APIDocumentationGenerated` 和实际使用该 API 的 Blizzard 实现。版本不匹配要说明限制，不能自动拉取或切换外部仓库。

依赖缺失时先检查当前可用技能目录和已知本地资源；仍缺失则说明具体缺失项，询问路径或查阅官方上游。无法取得依据时继续不依赖它的工作，将相关判断标为待验证，不虚构 API，也不以猜测完成依赖该 API 的实现。

## 验证和报告

执行[代码质量控制](../../../../.context/code-quality.md#验证)中与变更相关的静态检查，说明实际覆盖与限制。截图定位诊断为 `uv run --locked --directory PixBlood python -m pix.test_captura`，它不发键，仅在任务需要时运行。开发结束后的独立审查按 rotation 开发与审核 skill 执行，不以主 agent 自查替代。

审查默认只读；明确请求修复时才修改。开发任务中自动审核发现的本次问题由主 agent 核实修复；历史问题仅报告，除非它阻碍本次需求。报告范围、按影响排序的发现、文件位置、双方证据、影响及最小建议；区分确定不一致、规范缺口、待确认意图、实机待验证。标明本次引入或历史遗留，不能依据印象给结论。无发现时说明检查范围和未验证部分。

报告直接回复用户，不新增验收文档、迁移记录或平行 docs 目录。行为修改同步受影响的三份 `.context` 文档；不因本任务整理无关文档。
