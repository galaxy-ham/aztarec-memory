-- AztarecMemory/Core.lua
-- Bootstrap and slash command handling.

AztarecMemory = AztarecMemory or {}

local CHAT_PREFIX = "|cff88aaff[MemoryGame]|r "

function AztarecMemory.Print(msg)
    print(CHAT_PREFIX .. msg)
end

-- ---------------------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------------------
SLASH_AZTARECMEMORY1 = "/memorygame"
SLASH_AZTARECMEMORY2 = "/mg"

SlashCmdList["AZTARECMEMORY"] = function(msg)
    msg = msg and msg:lower():trim() or ""

    if not AztarecMemory.UI then
        AztarecMemory.Print("UI failed to load.")
        return
    end

    if msg == "clear" then
        AztarecMemory.UI.Clear()
    elseif msg == "undo" then
        AztarecMemory.UI.Undo()
    elseif msg == "" then
        AztarecMemory.UI.Toggle()
    else
        AztarecMemory.Print("Commands:")
        AztarecMemory.Print("  /mg        - Toggle the memory game window")
        AztarecMemory.Print("  /mg clear  - Clear all 7 slots")
        AztarecMemory.Print("  /mg undo   - Remove the last icon placed")
    end
end
