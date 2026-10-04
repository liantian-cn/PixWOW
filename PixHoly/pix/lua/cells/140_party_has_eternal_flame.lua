-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local addonName, addonTable = ...

-- 项目引用
local Units = addonTable.UnitCells
local Aura = Units.Aura
local Party = Units.Party

Aura(140, Party, "HELPFUL", { includeSpellIDs = { [156322] = true } })
