-- 按 party1–4 先取第一位存活在线坦克，再由第 071 格检查其误导射程。
-- 0表示无合格坦克，1至4直接表示party编号；不按射程改选后续坦克。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local ipairs = ipairs

-- WoW API
local After = C_Timer.After
local CreateFrame = CreateFrame
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local UnitExists = UnitExists
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local issecretvalue = issecretvalue

-- 项目引用
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell

-- 本地配置
local cell
local frame = CreateFrame("Frame")

-- RefreshMisdirectionRange 由后加载的 071 文件设置，刷新时动态读取。
addonTable.PartyTankUnit = nil
local function Refresh()
    local selected = 0
    if IsInGroup() and not IsInRaid() then
        for index = 1, 4 do
            local unit = "party" .. index
            if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then
                local role = UnitGroupRolesAssigned(unit)
                if not issecretvalue(role) and role == "TANK" then selected = index; break end
            end
        end
    end
    addonTable.PartyTankUnit = selected > 0 and ("party" .. selected) or nil
    if addonTable.RefreshMisdirectionRange then addonTable.RefreshMisdirectionRange() end
    if cell then
        local gray = selected / 255
        cell:setCellRGBA(gray, gray, gray)
    end
end
for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "GROUP_ROSTER_UPDATE", "PLAYER_ROLES_ASSIGNED", "ROLE_CHANGED_INFORM", "UNIT_CONNECTION", "UNIT_HEALTH", "UNIT_FLAGS", "PARTY_MEMBER_ENABLE", "PARTY_MEMBER_DISABLE", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED" }) do frame:RegisterEvent(event) end
local pending = false
frame:SetScript("OnEvent", function()
    if pending then return end
    pending = true
    After(0, function() pending = false; Refresh() end)
end)
local elapsed = 0
frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 1 then elapsed = elapsed % 1; Refresh() end
end)
insert(UIInitFuncs, function()
    cell = Cell:New({ x = 66 })
    Refresh()
end)
