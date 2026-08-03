-- AztarecMemory/UI/MemoryFrame.lua
-- The movable memory-game window: 7 blank slots, 4 raid-icon buttons, and a clear button.

AztarecMemory = AztarecMemory or {}
AztarecMemory.UI = {}
local UI = AztarecMemory.UI

local SLOT_COUNT   = 7
local SLOT_SIZE    = 40
local ICON_SIZE    = 32
local SLOT_SPACING = 6
local BUTTON_SIZE  = 32
local BUTTON_SPACING = 10

-- Raid target icon indices, as used by SetRaidTarget/UI-RaidTargetingIcon textures:
-- 1 Star, 2 Circle, 3 Diamond, 4 Triangle, 5 Moon, 6 Square, 7 Cross(X), 8 Skull
local ICON_INDEX = {
    diamond = 3,
    circle  = 2,
    square  = 6,
    cross   = 7,
}

local function IconTexture(index)
    return "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. index
end

local frame
local slots = {}
local fillHistory = {}   -- ordered list of slot indices, in the order they were filled

-- ---------------------------------------------------------------------------
-- Slot handling
-- ---------------------------------------------------------------------------
local function CreateSlot(parent, xOffset)
    local slot = CreateFrame("Frame", nil, parent)
    slot:SetSize(SLOT_SIZE, SLOT_SIZE)
    slot:SetPoint("TOPLEFT", xOffset, 0)

    local bg = slot:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\Buttons\\UI-EmptySlot")

    local icon = slot:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetPoint("CENTER")

    slot.icon = icon
    return slot
end

local function FillNextEmptySlot(iconIndex)
    for i, slot in ipairs(slots) do
        if not slot.icon:GetTexture() then
            slot.icon:SetTexture(IconTexture(iconIndex))
            table.insert(fillHistory, i)
            return true
        end
    end
    return false
end

function UI.Clear()
    for _, slot in ipairs(slots) do
        slot.icon:SetTexture(nil)
    end
    wipe(fillHistory)
end

function UI.Undo()
    local lastIndex = table.remove(fillHistory)
    if lastIndex then
        slots[lastIndex].icon:SetTexture(nil)
    end
end

-- ---------------------------------------------------------------------------
-- Icon buttons
-- ---------------------------------------------------------------------------
local function CreateIconButton(parent, iconIndex, xOffset, tooltipText)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:SetPoint("TOPLEFT", xOffset, 0)

    btn:SetNormalTexture(IconTexture(iconIndex))
    btn:SetPushedTexture(IconTexture(iconIndex))
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

    btn:SetScript("OnClick", function()
        FillNextEmptySlot(iconIndex)
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(tooltipText)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return btn
end

local function CreateClearButton(parent, xOffset)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(70, BUTTON_SIZE)
    btn:SetPoint("TOPLEFT", xOffset, 4)
    btn:SetText("Clear")
    btn:SetScript("OnClick", UI.Clear)
    return btn
end

local function CreateUndoButton(parent, xOffset)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(70, BUTTON_SIZE)
    btn:SetPoint("TOPLEFT", xOffset, 4)
    btn:SetText("Undo")
    btn:SetScript("OnClick", UI.Undo)
    return btn
end

-- ---------------------------------------------------------------------------
-- Frame construction
-- ---------------------------------------------------------------------------
local function CreateMemoryFrame()
    local slotsRowWidth = (SLOT_COUNT * SLOT_SIZE) + ((SLOT_COUNT - 1) * SLOT_SPACING)
    local width  = slotsRowWidth + 40
    local height = 150

    local f = CreateFrame("Frame", "AztarecMemoryFrame", UIParent, "BackdropTemplate")
    f:SetSize(width, height)
    f:SetPoint("CENTER")
    f:SetFrameStrata("MEDIUM")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile     = true, tileSize = 32, edgeSize = 32,
        insets   = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    f:SetBackdropColor(0, 0, 0, 0.9)

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -14)
    title:SetText("|cff88aaff[Memory Game]|r")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- 7 slots, centered
    local slotsRow = CreateFrame("Frame", nil, f)
    slotsRow:SetSize(slotsRowWidth, SLOT_SIZE)
    slotsRow:SetPoint("TOP", 0, -40)

    for i = 1, SLOT_COUNT do
        local xOffset = (i - 1) * (SLOT_SIZE + SLOT_SPACING)
        slots[i] = CreateSlot(slotsRow, xOffset)
    end

    -- Buttons row: Diamond, Circle, Square, Cross(X), Undo, Clear
    local buttonsRowWidth = (4 * BUTTON_SIZE) + (5 * BUTTON_SPACING) + 70 + 70
    local buttonsRow = CreateFrame("Frame", nil, f)
    buttonsRow:SetSize(buttonsRowWidth, BUTTON_SIZE)
    buttonsRow:SetPoint("TOP", slotsRow, "BOTTOM", 0, -20)

    local x = 0
    CreateIconButton(buttonsRow, ICON_INDEX.diamond, x, "Diamond"); x = x + BUTTON_SIZE + BUTTON_SPACING
    CreateIconButton(buttonsRow, ICON_INDEX.circle,  x, "Circle");  x = x + BUTTON_SIZE + BUTTON_SPACING
    CreateIconButton(buttonsRow, ICON_INDEX.square,  x, "Square");  x = x + BUTTON_SIZE + BUTTON_SPACING
    CreateIconButton(buttonsRow, ICON_INDEX.cross,   x, "X");       x = x + BUTTON_SIZE + BUTTON_SPACING
    CreateUndoButton(buttonsRow, x);                                x = x + 70 + BUTTON_SPACING
    CreateClearButton(buttonsRow, x)

    f:Hide()
    return f
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------
function UI.Toggle()
    if not frame then
        frame = CreateMemoryFrame()
    end

    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
