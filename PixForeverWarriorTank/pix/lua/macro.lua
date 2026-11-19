local addonName, addonTable = ...
local insert = table.insert
local CreateFrame = CreateFrame
local SetOverrideBindingClick = SetOverrideBindingClick
local logging = addonTable.logging

-- 复用 base.lua 的检查结果，不为待重载插件绑定技能宏。
if addonTable.RELOAD_REQUIRED then return end

local macroList = {}
insert(macroList, { title = "reloadUI", key = "CTRL-F12", text = "/reload" })
insert(macroList, { title = "英勇打击", key = "RCTRL-NUMPAD1", text = "/startattack\n/cast 英勇打击" })
insert(macroList, { title = "撕裂", key = "RCTRL-NUMPAD2", text = "/startattack\n/cast 撕裂" })
insert(macroList, { title = "复仇", key = "RCTRL-NUMPAD3", text = "/startattack\n/cast 复仇" })
insert(macroList, { title = "挫志怒吼", key = "RCTRL-NUMPAD4", text = "/cast 挫志怒吼" })
insert(macroList, { title = "战斗怒吼", key = "RCTRL-NUMPAD5", text = "/cast 战斗怒吼" })
insert(macroList, { title = "破甲攻击", key = "RCTRL-NUMPAD6", text = "/startattack\n/cast 破甲攻击" })
insert(macroList, { title = "防御姿态", key = "RCTRL-NUMPAD7", text = "/startattack\n/cast 防御姿态" })
insert(macroList, { title = "盾牌格挡", key = "RCTRL-NUMPAD8", text = "/startattack\n/cast 盾牌格挡" })
insert(macroList, { title = "焦点盾击", key = "RCTRL-NUMPAD9", text = "/startattack\n/cast [@focus,harm,nodead] 盾击" })
insert(macroList, { title = "目标盾击", key = "RCTRL-NUMPAD0", text = "/startattack\n/cast [@target,harm,nodead] 盾击" })
insert(macroList, { title = "雷霆一击", key = "RSHIFT-NUMPAD1", text = "/cast 雷霆一击" })
insert(macroList, { title = "顺劈斩", key = "RSHIFT-NUMPAD2", text = "/startattack\n/cast 顺劈斩" })
insert(macroList, { title = "乘胜追击", key = "RSHIFT-NUMPAD3", text = "/startattack\n/cast 乘胜追击" })
for _, macro in ipairs(macroList) do
    local buttonName = addonName .. "Button" .. macro.title
    local frame = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
    frame:SetAttribute("type", "macro")
    frame:SetAttribute("macrotext", macro.text)
    frame:RegisterForClicks("AnyDown", "AnyUp")
    SetOverrideBindingClick(frame, true, macro.key, buttonName)
    logging("bind " .. macro.key .. " > " .. macro.text)
end
