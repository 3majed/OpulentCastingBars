-- ============================================================
--  Opulent Casting Bars — Animations.lua
--  Animations de fin de cast et hooks pour effets futurs
--
--  Le fade est géré manuellement via un OnUpdate dédié
--  plutôt qu'avec AnimationGroup, pour éviter les snaps
--  d'alpha lors d'un Stop() sur un AG en cours.
-- ============================================================

SCB.Animations = {}

-- Durées (secondes)
local COMPLETE_FADE_DURATION  = 0.65
local FAIL_SHAKE_INTERVAL     = 0.04
local FAIL_SHAKE_COUNT        = 4
local FAIL_SHAKE_AMOUNT       = 3
local FAIL_FADE_DURATION      = 0.50

-- Frame dédié au fade — tourne en permanence, léger
local fadeFrame   = CreateFrame("Frame")
fadeFrame:Show()  -- doit être visible pour que OnUpdate tourne en permanence
local _fadeActive = false
local _fadeDone   = nil
local _fadeTarget = nil
local _fadeAlpha  = 1
local _fadeSpeed  = 0

-- Phase du fade : "hold", "fade", "recast_flash"
local _fadePhase    = "fade"
local _fadeHold     = 0
local _fadeHoldFill = nil
local _fadeHoldCol  = nil

local COMPLETE_HOLD_DURATION = 0.25
local RECAST_FLASH_DURATION  = 0.30
local _recastFlash  = false
local _recastTimer  = 0
local RECAST_FLASH_DURATION = 0.30
local PUSHBACK_FLASH_DURATION = 0.25
local PUSHBACK_FLASH_COLOR    = { 1.0, 0.25, 0.15 }  -- rouge-orangé (coup reçu)
local _pushbackFlash  = false
local _pushbackTimer  = 0
local _pushbackFill   = nil  -- texture résolue (fillMask ou texFill standard)
local HIGHLIGHT_COLORS = {
    frost      = { 0.7, 0.95, 1.0  },
    fire       = { 1.0, 0.6,  0.15 },
    lava       = { 1.0, 0.5,  0.05 },  -- orange lave
    inferno    = { 1.0, 0.40, 0.02 },  -- orange brûlant
    felfire    = { 0.15, 1.0, 0.15 },  -- vert fluo felfire
    frostfire  = { 0.6, 0.85, 1.0  },
    earth      = { 0.9, 0.75, 0.45 },
    shadow     = { 0.6, 0.2,  0.9  },
    nature     = { 0.3, 1.0,  0.25 },
    herbalism  = { 0.3, 1.0,  0.25 },  -- même vert que Nature
    mining     = { 0.8, 0.65, 0.35 },  -- brun-or rocailleux
    fishing    = { 0.35, 0.80, 1.0  },  -- bleu cyan eau
    arcane     = { 0.7, 0.3,  1.0  },
    arcaneum   = { 0.62, 0.40, 1.0  },
    holy       = { 1.0, 0.95, 0.5  },
    thunder    = { 0.6, 0.8,  1.0  },
    aim        = { 1.0, 0.15, 0.05 },  -- rouge chasseur
    alliance   = { 0.2, 0.5,  1.0  },
    horde      = { 1.0, 0.15, 0.05 },
    metal      = { 0.95, 0.82, 0.58 },
    honey_icon = { 1.0,  0.82, 0.30 },
    default    = { 1.0, 1.0,  0.85 },
}
local HIGHLIGHT_DURATION = 0.18

fadeFrame:SetScript("OnUpdate", function(self_frame, dt)  -- renommé self_frame pour éviter conflit
    -- Recast flash : pulse couleur sur le fill, sans toucher à l'alpha
    if _recastFlash then
        _recastTimer = _recastTimer + dt
        local t = _recastTimer / RECAST_FLASH_DURATION
        local school = SCB.Bar and (SCB.Bar.currentSchoolKey or "default")
        local fill = SCB.Bar and SCB.Bar.texFill
        if t >= 1 then
            _recastFlash = false
            if fill then fill:SetVertexColor(1, 1, 1) end
        else
            if fill then
                local intensity = math.sin(t * math.pi)
                local col = HIGHLIGHT_COLORS[school] or HIGHLIGHT_COLORS.default
                fill:SetVertexColor(
                    1 - (1 - col[1]) * intensity,
                    1 - (1 - col[2]) * intensity,
                    1 - (1 - col[3]) * intensity)
            end
        end
    end

    -- Pushback flash : bref flash rouge sur le fill pour signaler le recul
    if _pushbackFlash then
        _pushbackTimer = _pushbackTimer + dt
        local t = _pushbackTimer / PUSHBACK_FLASH_DURATION
        if t >= 1 then
            _pushbackFlash = false
            if _pushbackFill then
                _pushbackFill:SetVertexColor(1, 1, 1)
                _pushbackFill = nil
            end
        else
            local intensity = math.sin(t * math.pi)
            if _pushbackFill then
                local c = PUSHBACK_FLASH_COLOR
                _pushbackFill:SetVertexColor(
                    1 - (1 - c[1]) * intensity,
                    1 - (1 - c[2]) * intensity,
                    1 - (1 - c[3]) * intensity)
            end
        end
    end

    if not _fadeActive or not _fadeTarget then return end

    if _fadePhase == "hold" then
        _fadeHold = _fadeHold - dt
        local t = 1 - (_fadeHold / COMPLETE_HOLD_DURATION)  -- 0→1 pendant le hold
        -- Cloche : fade-in sur 40%, hold, fade-out sur 40%
        local intensity
        if t < 0.4 then
            intensity = t / 0.4
        elseif t < 0.6 then
            intensity = 1
        else
            intensity = (1 - t) / 0.4
        end
        if _fadeHoldFill then
            local col = _fadeHoldCol or {1, 1, 0.85}
            _fadeHoldFill:SetVertexColor(
                1 - (1 - col[1]) * intensity,
                1 - (1 - col[2]) * intensity,
                1 - (1 - col[3]) * intensity)
        end
        if _fadeHold <= 0 then
            if _fadeHoldFill then
                _fadeHoldFill:SetVertexColor(1, 1, 1)
                _fadeHoldFill = nil
                _fadeHoldCol  = nil
            end
            _fadePhase = "fade"
        else
            _fadeTarget:SetAlpha(1)
        end
        return
    end

    -- Phase "fade"
    _fadeAlpha = _fadeAlpha - dt * _fadeSpeed
    if _fadeAlpha <= 0 then
        _fadeAlpha  = 0
        _fadeActive = false
        _fadeTarget:SetAlpha(0)
        -- Remettre texBG à alpha normal (sera caché par le wrapper de toute façon)
        if SCB.Bar and SCB.Bar.texBG then SCB.Bar.texBG:SetAlpha(1) end
        _fadeTarget = nil
        if _fadeDone then _fadeDone() end
        return
    end
    _fadeTarget:SetAlpha(_fadeAlpha)
    -- BG fast fade : pour les écoles où le BG est trop visible en fin de cast
    if SCB.Bar and SCB.Bar.texBG then
        local school = SCB.Bar.currentSchool
        if school and school.bgFastFade then
            -- Le BG disparaît 2x plus vite que le reste
            local bgAlpha = math.max(0, (_fadeAlpha - 0.5) * 2)
            SCB.Bar.texBG:SetAlpha(bgAlpha)
        end
    end
end)

local function StartFade(frame, duration, onDone)
    _fadeTarget = frame
    _fadeAlpha  = frame:GetAlpha()
    _fadeSpeed  = _fadeAlpha / duration
    _fadeDone   = onDone
    _fadeActive = true
end

local function CancelFade()
    if _fadeActive and _fadeTarget then
        _fadeTarget:SetAlpha(1)
    end
    if _fadeHoldFill then
        _fadeHoldFill:SetVertexColor(1, 1, 1)
        _fadeHoldFill = nil
        _fadeHoldCol  = nil
    end
    _recastFlash = false
    _pushbackFlash = false
    if _pushbackFill then
        _pushbackFill:SetVertexColor(1, 1, 1)
        _pushbackFill = nil
    end
    if SCB.Bar then
        if SCB.Bar.texFill      then SCB.Bar.texFill:SetVertexColor(1, 1, 1)      end
        if SCB.Bar.texFillRight then SCB.Bar.texFillRight:SetVertexColor(1, 1, 1) end
    end
    _fadeActive = false
    _fadePhase  = "fade"
    _fadeHold   = 0
    _fadeDone   = nil
    _fadeTarget = nil
end

-- ============================================================
--  API publique
-- ============================================================

function SCB.Animations:Cancel(frame)
    CancelFade()
    -- Remet frameInner à alpha plein au cas où
    if SCB.Bar and SCB.Bar.frameInner then
        SCB.Bar.frameInner:SetAlpha(1)
    end
    local anchor = SCB.Config:Get("anchor")
    local x      = SCB.Config:Get("x")
    local y      = SCB.Config:Get("y")
    frame:ClearAllPoints()
    frame:SetPoint(anchor, UIParent, anchor, x, y)
    frame:SetAlpha(1)
    -- Ne pas faire Show() ici — StartCast le fera après avoir tout préparé
end

function SCB.Animations:FlashRecast()
    _recastTimer = 0
    _recastFlash = true
end

function SCB.Animations:PlayComplete(frame, gen, onDone)
    -- Si un nouveau cast a démarré depuis, on abandonne silencieusement
    if gen ~= SCB.Bar.castGeneration then
        if onDone then onDone() end
        return
    end

    CancelFade()
    frame:SetAlpha(1)

    local school     = SCB.Bar.currentSchoolKey or "default"
    local col        = HIGHLIGHT_COLORS[school] or HIGHLIGHT_COLORS.default
    local schoolData = SCB.Schools and SCB.Schools.data and SCB.Schools.data[school]
    local noHold     = schoolData and schoolData.noCompletionHold

    if not noHold then
        -- Stocke fill et couleur — le OnUpdate les anime progressivement
        local currentSchool = SCB.Schools and SCB.Schools.data[school]
        local fill
        if currentSchool and currentSchool.fillMask then
            -- Fill custom (Arcane etc.) : récupérer la couche principale via FX
            local fx = SCB.FX and SCB.FX[school]
            fill = fx and fx.texFillA or SCB.Bar.texFill
        else
            fill = SCB.Bar.texFill
        end
        if fill then
            _fadeHoldFill = fill
            _fadeHoldCol  = col
        end
        _fadePhase = "hold"
        _fadeHold  = COMPLETE_HOLD_DURATION
    else
        -- Pas de hold : fade immédiat
        _fadePhase = "fade"
        _fadeHold  = 0
    end

    -- Hold court puis disparition via fade rapide
    _fadeTarget = frame
    _fadeAlpha  = 1
    _fadeSpeed  = 1 / COMPLETE_FADE_DURATION
    _fadeDone   = onDone
    _fadeActive = true
end

-- ============================================================
--  CAST INTERROMPU / ÉCHOUÉ : shake + fade out
-- ============================================================

function SCB.Animations:PlayFail(frame, onDone)
    CancelFade()

    local anchor = SCB.Config:Get("anchor")
    local origX  = SCB.Config:Get("x")
    local origY  = SCB.Config:Get("y")
    local shakeCount = 0

    frame:SetAlpha(1)
    StartFade(frame, FAIL_FADE_DURATION, function()
        frame:ClearAllPoints()
        frame:SetPoint(anchor, UIParent, anchor, origX, origY)
        if onDone then onDone() end
    end)

    local function doShake()
        if not SCB.Bar.isFading then return end

        shakeCount = shakeCount + 1
        if shakeCount > FAIL_SHAKE_COUNT then
            frame:ClearAllPoints()
            frame:SetPoint(anchor, UIParent, anchor, origX, origY)
            return
        end

        local offsetX = (shakeCount % 2 == 0) and FAIL_SHAKE_AMOUNT or -FAIL_SHAKE_AMOUNT
        frame:ClearAllPoints()
        frame:SetPoint(anchor, UIParent, anchor, origX + offsetX, origY)
        C_Timer.After(FAIL_SHAKE_INTERVAL, doShake)
    end

    doShake()
end

-- ============================================================
--  PUSHBACK — API publique
-- ============================================================

function SCB.Animations:PlayPushback(frame)
    -- Résoudre la bonne texture fill
    local school = SCB.Bar and SCB.Bar.currentSchoolKey or "default"
    local currentSchool = SCB.Schools and SCB.Schools.data[school]
    if currentSchool and currentSchool.fillMask then
        local fx = SCB.FX and SCB.FX[school]
        _pushbackFill = (fx and fx.texFillA) or (SCB.Bar and SCB.Bar.texFill)
    else
        _pushbackFill = SCB.Bar and SCB.Bar.texFill
    end
    _pushbackTimer = 0
    _pushbackFlash = true
end

-- ============================================================
--  HOOKS FUTURS (stubs documentés)
-- ============================================================

--[[
    SCB.Particles:TriggerExplosion(school)
    SCB.Particles:TriggerFail(school)
    SCB.Particles:TriggerIdle(school)
    SCB.Particles:StopIdle()
]]
