-- ============================================================
--  Opulent Casting Bars — Commands.lua
--  Slash commands /ocb
-- ============================================================

SCB.Commands = {}

function SCB.Commands:Register()
    SLASH_OCB1 = "/ocb"
    SLASH_OCB2 = "/opulentcastingbars"
    SlashCmdList["OCB"] = function(msg)
        SCB.Commands:Handle(msg)
    end
end

function SCB.Commands:Handle(msg)
    -- Découpe les arguments en mots, tout en minuscules
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word:lower())
    end

    local cmd = args[1]

    -- /ocb  (sans argument) → ouvre les options
    if not cmd or cmd == "" then
        SCB.Options:Toggle()
        return
    end

    -- /ocb options | config | opt
    if cmd == "options" or cmd == "config" or cmd == "opt" then
        SCB.Options:Toggle()
        return
    end

    -- /ocb test [school] [duration]
    --   Exemples :
    --     /ocb test             → frost 3s
    --     /ocb test frost       → frost 3s
    --     /ocb test frost 5     → frost 5s
    --     /ocb test fire 1.5    → fire 1.5s
    if cmd == "test" then
        local school   = args[2] or "neutral"
        local duration = tonumber(args[3]) or 3

        if not SCB.Schools:Exists(school) then
            print("|cffFF9900[OCB]|r School '" .. school ..
                  "' not yet available. Using neutral.")
            school = "neutral"
        end

        duration = math.max(0.5, math.min(duration, 60))

        local displayName = SCB.Schools:Get(school).name
        print(string.format(
            "|cff00CCFF[OCB]|r Testing |cffffff00%s|r — |cffAAFFAA%.1fs|r",
            displayName, duration))

        SCB.Bar:StartCast(displayName .. " — Test", duration, school)
        return
    end

    -- /ocb debug  → active/désactive le mode debug (affiche spellID et events en chat)
    if cmd == "debug" then
        SCB._debugMode = not SCB._debugMode
        if SCB._debugMode then
            print("|cff00CCFF[OCB]|r |cffFF9900Debug ON|r — Lance des sorts pour voir les spellIDs.")
        else
            print("|cff00CCFF[OCB]|r Debug OFF.")
        end
        return
    end

    -- /ocb stop
    if cmd == "stop" then
        SCB.Bar:StopCast(false)
        return
    end

    -- /ocb lock
    if cmd == "lock" then
        SCB.Config:Set("locked", true)
        SCB.Bar.frame:EnableMouse(false)
        print("|cff00CCFF[OCB]|r Bar |cffFF4444locked|r.")
        return
    end

    -- /ocb unlock
    if cmd == "unlock" then
        SCB.Config:Set("locked", false)
        SCB.Bar.frame:EnableMouse(true)
        print("|cff00CCFF[OCB]|r Bar |cff00FF00unlocked|r — drag to reposition.")
        return
    end

    -- /ocb schools  → liste les écoles disponibles
    if cmd == "schools" then
        print("|cff00CCFF[OCB]|r Available schools :")
        for key, school in pairs(SCB.Schools.data) do
            print("  |cffffff00" .. key .. "|r  →  " .. school.name)
        end
        return
    end

    -- /ocb help
    self:PrintHelp()
end

function SCB.Commands:PrintHelp()
    print("|cff00CCFFOpulent Casting Bars|r — Commands :")
    print("  |cffffff00/ocb|r                           Open options")
    print("  |cffffff00/ocb test [school] [seconds]|r   Preview a cast")
    print("  |cffffff00/ocb stop|r                      Stop current cast")
    print("  |cffffff00/ocb lock|r  /  |cffffff00unlock|r            Lock/unlock bar")
    print("  |cffffff00/ocb schools|r                   List available schools")
    print("  |cffffff00/ocb help|r                      Show this message")
    print(" ")
    print("  Schools : neutral, frost, fire, earth, arcane, arcaneum, nature, shadow, holy, physical")
    print("  Example : |cffffff00/ocb test earth 5|r")
end
