-- 同一属性按单位顺序集中创建，空槽由存在性控制。
local addonName, addonTable = ...

-- 项目引用
local Units = addonTable.UnitCells
local Aura = Units.Aura

Aura(69, { "target" }, "HARMFUL|RAID_PLAYER_DISPELLABLE", { includeDispelTypes = { Magic = true } })
