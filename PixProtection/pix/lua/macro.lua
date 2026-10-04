local addonName, addonTable = ...
local insert = table.insert
local CreateFrame = CreateFrame
local SetOverrideBindingClick = SetOverrideBindingClick
local logging = addonTable.logging

-- 复用 base.lua 的检查结果，不为待重载插件绑定技能宏。
if addonTable.RELOAD_REQUIRED then return end

local macroList = {}
insert(macroList, { title = "reloadUI", key = "CTRL-F12", text = "/reload" })
insert(macroList, { title = "目标正义盾击", key = "RCTRL-NUMPAD1", text = "/cast [@target,harm,nodead] 正义盾击" })
insert(macroList, { title = "焦点责难", key = "RCTRL-NUMPAD2", text = "/cast [@focus,harm,nodead] 责难" })
insert(macroList, { title = "目标责难", key = "RCTRL-NUMPAD3", text = "/cast [@target,harm,nodead] 责难" })
insert(macroList, { title = "戒卫", key = "RCTRL-NUMPAD4", text = "/cast 戒卫" })
insert(macroList, { title = "目标复仇者之盾", key = "RCTRL-NUMPAD5", text = "/cast [@target,harm,nodead] 复仇者之盾" })
insert(macroList, { title = "焦点复仇者之盾", key = "RCTRL-NUMPAD6", text = "/cast [@focus,harm,nodead] 复仇者之盾" })
insert(macroList, { title = "奉献", key = "RCTRL-NUMPAD7", text = "/cast 奉献" })
insert(macroList, { title = "祝福之锤", key = "RCTRL-NUMPAD8", text = "/cast 祝福之锤" })
insert(macroList, { title = "目标审判", key = "RCTRL-NUMPAD9", text = "/cast [@target,harm,nodead] 审判" })
insert(macroList, { title = "焦点审判", key = "RCTRL-NUMPAD0", text = "/cast [@focus,harm,nodead] 审判" })
insert(macroList, { title = "圣洁鸣钟", key = "RSHIFT-NUMPAD1", text = "/cast [@target,harm,nodead] 圣洁鸣钟" })
insert(macroList, { title = "神圣壁垒", key = "RSHIFT-NUMPAD2", text = "/cast [@player] 神圣壁垒" })
insert(macroList, { title = "圣洁武器", key = "RSHIFT-NUMPAD3", text = "/cast [@player] 圣洁武器" })
insert(macroList, { title = "荣耀圣令", key = "RSHIFT-NUMPAD4", text = "/cast [@player] 荣耀圣令" })
insert(macroList, { title = "焦点正义盾击", key = "RSHIFT-NUMPAD5", text = "/cast [@focus,harm,nodead] 正义盾击" })
insert(macroList, { title = "圣言祭礼", key = "RSHIFT-NUMPAD6", text = "/cast 圣言祭礼\n/use 16" })
insert(macroList, { title = "清毒术", key = "RSHIFT-NUMPAD7", text = "/cast [@player] 清毒术" })
insert(macroList, { title = "上饰品", key = "RSHIFT-NUMPAD8", text = "/use 13" })
insert(macroList, { title = "下饰品", key = "RSHIFT-NUMPAD9", text = "/use 14" })

for _, macro in ipairs(macroList) do
    local buttonName = addonName .. "Button" .. macro.title
    local frame = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
    frame:SetAttribute("type", "macro")
    frame:SetAttribute("macrotext", macro.text)
    frame:RegisterForClicks("AnyDown", "AnyUp")
    SetOverrideBindingClick(frame, true, macro.key, buttonName)
    logging("bind " .. macro.key .. " > " .. macro.text)
end
