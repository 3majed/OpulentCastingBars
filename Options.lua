-- ============================================================
--  Opulent Casting Bars — Options.lua
--  3 onglets : General | Appearance | Text
-- ============================================================

SCB.Options = {}

function SCB.Options:Create()
    local panel = CreateFrame("Frame")
    panel.name = "Opulent Casting Bars"

    local title = panel:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
    title:SetPoint("TOPLEFT",16,-16) ; title:SetText("Opulent Casting Bars")

    local subtitle = panel:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-4)
    subtitle:SetText("v"..SCB.VERSION.."  —  Per-school magic casting bars")

    -- ============================================================
    --  ONGLETS
    -- ============================================================
    local TAB_NAMES = {"General","Appearance","Text"}
    local tabs, contents = {}, {}

    local function SelectTab(idx)
        for i=1,#tabs do
            local active=(i==idx)
            tabs[i]:SetNormalFontObject(active and "GameFontNormalLarge" or "GameFontNormal")
            tabs[i]:SetHighlightFontObject(active and "GameFontNormalLarge" or "GameFontHighlight")
            if contents[i] then
                if active then contents[i]:Show() else contents[i]:Hide() end
            end
        end
    end

    for i,name in ipairs(TAB_NAMES) do
        local btn=CreateFrame("Button",nil,panel)
        btn:SetSize(110,30)
        if i==1 then btn:SetPoint("TOPLEFT",subtitle,"BOTTOMLEFT",0,-10)
        else          btn:SetPoint("LEFT",tabs[i-1],"RIGHT",4,0) end
        btn:SetNormalFontObject("GameFontNormal")
        btn:SetHighlightFontObject("GameFontHighlight")
        btn:SetText(name)
        btn:SetScript("OnClick",function() SelectTab(i) end)
        tabs[i]=btn
        local c=CreateFrame("Frame",nil,panel)
        c:SetPoint("TOPLEFT",tabs[1],"BOTTOMLEFT",0,-10)
        c:SetPoint("BOTTOMRIGHT",panel,"BOTTOMRIGHT",-10,50)
        c:Hide() ; contents[i]=c
    end

    -- ============================================================
    --  HELPERS
    -- ============================================================
    local _slN=0
    local function MakeSlider(parent,label,minV,maxV,value,step,yOff)
        _slN=_slN+1
        local sl=CreateFrame("Slider","SCBSlider".._slN,parent,
                             BackdropTemplateMixin and "BackdropTemplate" or nil)
        sl:SetOrientation("HORIZONTAL") ; sl:SetPoint("TOPLEFT",20,yOff)
        sl:SetMinMaxValues(minV,maxV) ; sl:SetValue(value)
        sl:SetValueStep(step) ; sl:SetObeyStepOnDrag(true)
        sl:SetWidth(300) ; sl:SetHeight(17)
        if sl.SetBackdrop then
            sl:SetBackdrop({bgFile="Interface\\Buttons\\UI-SliderBar-Background",
                edgeFile="Interface\\Buttons\\UI-SliderBar-Border",
                tile=true,tileSize=8,edgeSize=8,
                insets={left=3,right=3,top=6,bottom=6}})
        end
        local th=sl:CreateTexture(nil,"OVERLAY")
        th:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
        th:SetSize(32,32) ; sl:SetThumbTexture(th)
        local lb=sl:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
        lb:SetPoint("BOTTOM",sl,"TOP",0,2) ; lb:SetText(label) ; sl.Label=lb
        local lo=sl:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
        lo:SetPoint("TOPLEFT",sl,"BOTTOMLEFT",2,3) ; sl.Low=lo
        local hi=sl:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
        hi:SetPoint("TOPRIGHT",sl,"BOTTOMRIGHT",-2,3) ; sl.High=hi
        return sl
    end

    -- Checkbox PROPRE : construit à la main, sans template WoW
    -- Évite les artefacts visuels du $parentText de CheckButtonTemplate
    local _cbN=0
    local function MakeCheck(parent, label, yOff, checked)
        _cbN=_cbN+1
        local btn=CreateFrame("CheckButton","SCBChk".._cbN,parent)
        btn:SetSize(20,20)
        btn:SetPoint("TOPLEFT",20,yOff)

        -- Fond normal
        local norm=btn:CreateTexture(nil,"BACKGROUND")
        norm:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
        norm:SetAllPoints()
        btn:SetNormalTexture(norm)
        -- Hover
        local hl=btn:CreateTexture(nil,"HIGHLIGHT")
        hl:SetTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
        hl:SetAllPoints() ; hl:SetBlendMode("ADD")
        btn:SetHighlightTexture(hl)
        -- Checked
        local chk=btn:CreateTexture(nil,"ARTWORK")
        chk:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        chk:SetAllPoints()
        btn:SetCheckedTexture(chk)
        -- Disabled checked
        local dis=btn:CreateTexture(nil,"ARTWORK")
        dis:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
        dis:SetAllPoints()
        btn:SetDisabledCheckedTexture(dis)

        -- Label à droite du bouton
        local fs=btn:CreateFontString(nil,"OVERLAY","GameFontHighlight")
        fs:SetPoint("LEFT",btn,"RIGHT",4,0)
        fs:SetText(label)
        btn.labelText=fs

        btn:SetChecked(checked)
        return btn
    end

    local function MakeSectionLabel(parent,text,yOff)
        local fs=parent:CreateFontString(nil,"ARTWORK","GameFontNormal")
        fs:SetPoint("TOPLEFT",14,yOff) ; fs:SetText(text) ; return fs
    end

    -- Radio button PROPRE : même approche sans template
    local _rbN=0
    local function MakeRadio(parent, label, xOff, yOff)
        _rbN=_rbN+1
        local btn=CreateFrame("CheckButton","SCBRad".._rbN,parent)
        btn:SetSize(20,20)
        btn:SetPoint("TOPLEFT",xOff,yOff)

        local norm=btn:CreateTexture(nil,"BACKGROUND")
        norm:SetTexture("Interface\\Buttons\\UI-RadioButton")
        norm:SetTexCoord(0,0.25,0,1) ; norm:SetAllPoints()
        btn:SetNormalTexture(norm)

        local hl=btn:CreateTexture(nil,"HIGHLIGHT")
        hl:SetTexture("Interface\\Buttons\\UI-RadioButton")
        hl:SetTexCoord(0.5,0.75,0,1) ; hl:SetAllPoints() ; hl:SetBlendMode("ADD")
        btn:SetHighlightTexture(hl)

        local chk=btn:CreateTexture(nil,"ARTWORK")
        chk:SetTexture("Interface\\Buttons\\UI-RadioButton")
        chk:SetTexCoord(0.25,0.5,0,1) ; chk:SetAllPoints()
        btn:SetCheckedTexture(chk)

        local fs=btn:CreateFontString(nil,"OVERLAY","GameFontHighlight")
        fs:SetPoint("LEFT",btn,"RIGHT",4,0)
        fs:SetText(label)
        btn.labelText=fs

        return btn
    end

    local function MakeRadioGroup(parent,options,currentKey,xStart,yOff,spacing,onSelect)
        local radios={}
        for i,opt in ipairs(options) do
            local rb=MakeRadio(parent,opt.label,xStart+(i-1)*spacing,yOff)
            rb:SetChecked(opt.key==currentKey)
            rb.optKey=opt.key
            rb:SetScript("OnClick",function(self)
                for _,r in ipairs(radios) do r:SetChecked(false) end
                self:SetChecked(true) ; onSelect(self.optKey)
            end)
            radios[i]=rb
        end
        return radios
    end

    -- Dropdown générique
    local function MakeDropdown(parent, options, currentKey, xOff, yOff, width, onChange, onPreview)
        local ITEM_HEIGHT=22
        local MAX_VISIBLE_ITEMS=12

        local function GetLabel(k)
            for _,o in ipairs(options) do if o.key==k then return o.label end end
            return k
        end
        local btn=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
        btn:SetSize(width,24) ; btn:SetPoint("TOPLEFT",xOff,yOff)
        btn:SetText(GetLabel(currentKey))

        local menu=CreateFrame("Frame",nil,parent,BackdropTemplateMixin and "BackdropTemplate" or nil)
        local needsScroll=#options>MAX_VISIBLE_ITEMS
        local visibleCount=needsScroll and MAX_VISIBLE_ITEMS or #options
        menu:SetSize(width,visibleCount*ITEM_HEIGHT+4)
        menu:SetPoint("TOPLEFT",btn,"BOTTOMLEFT",0,0)
        menu:SetFrameLevel(btn:GetFrameLevel()+20)
        if menu.SetBackdrop then
            menu:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
                tile=true,tileSize=16,edgeSize=8,
                insets={left=2,right=2,top=2,bottom=2}})
            menu:SetBackdropColor(0.08,0.08,0.08,0.96)
        end
        menu:Hide()

        local listParent=menu
        if needsScroll then
            local scroll=CreateFrame("ScrollFrame",nil,menu,"UIPanelScrollFrameTemplate")
            scroll:SetPoint("TOPLEFT",menu,"TOPLEFT",2,-2)
            scroll:SetPoint("BOTTOMRIGHT",menu,"BOTTOMRIGHT",-26,2)
            scroll:EnableMouseWheel(true)

            local scrollChild=CreateFrame("Frame",nil,scroll)
            scrollChild:SetSize(width-30,#options*ITEM_HEIGHT)
            scroll:SetScrollChild(scrollChild)

            scroll:SetScript("OnMouseWheel",function(self,delta)
                local step=ITEM_HEIGHT*2
                local y=self:GetVerticalScroll()-(delta*step)
                if y<0 then y=0 end
                local max=math.max(0,scrollChild:GetHeight()-self:GetHeight())
                if y>max then y=max end
                self:SetVerticalScroll(y)
            end)
            listParent=scrollChild
        end

        for i,opt in ipairs(options) do
            local item=CreateFrame("Button",nil,listParent)
            item:SetSize((needsScroll and (width-34) or (width-4)),20)
            item:SetPoint("TOPLEFT",listParent,"TOPLEFT",2,-(i-1)*ITEM_HEIGHT-2)
            item:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight","ADD")
            local fs=item:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
            fs:SetPoint("LEFT",item,"LEFT",6,0) ; fs:SetText(opt.label)
            item:SetScript("OnClick",function()
                btn:SetText(opt.label)
                menu:Hide()
                onChange(opt.key)
                if onPreview then onPreview(opt.key) end
            end)
        end
        btn:SetScript("OnClick",function()
            if not btn:IsEnabled() then return end
            if menu:IsShown() then menu:Hide() else menu:Show() end
        end)
        menu:SetScript("OnLeave",function()
            C_Timer.After(0.15,function()
                if menu:IsShown() and not menu:IsMouseOver()
                   and not btn:IsMouseOver() then menu:Hide() end
            end)
        end)
        btn._menu=menu
        btn._getLabel=GetLabel
        btn._options=options
        return btn
    end

    -- ============================================================
    --  BOUTONS FIXES
    -- ============================================================
    local testBtn=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
    testBtn:SetPoint("BOTTOMLEFT",20,16) ; testBtn:SetSize(150,25)
    testBtn:SetText("Test Cast  (5s)")
    testBtn:SetScript("OnClick",function()
        local school=SCB.Config:Get("defaultSchool") or "neutral"
        -- Couper le cast en cours si actif, puis appliquer la police avant de relancer
        if SCB.Bar.isActive or SCB.Bar.isFading then
            SCB.Bar:StopCast(false)
        end
        -- Forcer la taille et l'échelle depuis la config pour que le test bar
        -- reflète toujours les réglages actuels (largeur, échelle).
        SCB.Bar:Resize(SCB.Config:Get("barWidth"), SCB.Config:Get("barHeight"))
        SCB.Bar.frame:SetScale(SCB.Config:Get("scale") or 0.8)
        SCB.Bar:ApplyTextPrefs()
        SCB.Bar.frame:SetFrameStrata("TOOLTIP")
        SCB.Bar:StartCast("Test Cast",5,school)
        SCB.Bar.frame:SetScript("OnHide",function(self)
            self:SetFrameStrata(SCB.Config:Get("barStrata") or "MEDIUM") ; self:SetScript("OnHide",nil)
        end)
    end)

    local resetBtn=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
    resetBtn:SetPoint("LEFT",testBtn,"RIGHT",10,0) ; resetBtn:SetSize(150,25)
    resetBtn:SetText("Reset Defaults")

    -- ============================================================
    --  TAB 1 : GENERAL
    -- ============================================================
    do
        local c,yOf=contents[1],-20

        local scaleVal=SCB.Config:Get("scale") or 0.8
        local scaleSl=MakeSlider(c,string.format("Bar Scale: %.2f",scaleVal),0.5,2.0,scaleVal,0.05,yOf)
        scaleSl.Low:SetText("0.5") ; scaleSl.High:SetText("2.0")
        scaleSl:SetScript("OnValueChanged",function(self,v)
            v=math.floor(v/0.05+0.5)*0.05
            self.Label:SetText(string.format("Bar Scale: %.2f",v))
            SCB.Config:Set("scale",v) ; SCB.Bar.frame:SetScale(v)
        end)
        c.scaleSl=scaleSl ; yOf=yOf-50

        local wVal=SCB.Config:Get("barWidth")
        local widthSl=MakeSlider(c,string.format("Bar Width: %d px",wVal),200,700,wVal,10,yOf)
        widthSl.Low:SetText("200") ; widthSl.High:SetText("700")
        widthSl:SetScript("OnValueChanged",function(self,v)
            v=math.floor(v/10+0.5)*10
            self.Label:SetText(string.format("Bar Width: %d px",v))
            SCB.Bar:Resize(v,SCB.Config:Get("barHeight"))
        end)
        c.widthSl=widthSl ; yOf=yOf-50

        local lockCb=MakeCheck(c,"Lock bar position",yOf,SCB.Config:Get("locked"))
        lockCb:SetScript("OnClick",function(self)
            local v=self:GetChecked() ; SCB.Config:Set("locked",v)
            SCB.Bar.frame:EnableMouse(not v)
        end)
        c.lockCb=lockCb ; yOf=yOf-30

        local hideBlizzCb=MakeCheck(c,"Hide default Blizzard cast bar",yOf,SCB.Config:Get("hideBlizzardBar"))
        hideBlizzCb:SetScript("OnClick",function(self)
            local v=self:GetChecked() ; SCB.Config:Set("hideBlizzardBar",v)
            SCB.ApplyHideBlizzardBar(v)
        end)
        c.hideBlizzCb=hideBlizzCb ; yOf=yOf-30

        local empowerKeepCb=MakeCheck(c,"Keep default UI for Empowered spells",yOf,SCB.Config:Get("empowerKeepDefault"))
        empowerKeepCb:SetScript("OnClick",function(self)
            local v=self:GetChecked()
            SCB.Config:Set("empowerKeepDefault",v)
            if v then
                -- La préservation de la barre Blizzard nécessite un ReloadUI.
                -- L'effet sur la barre OCB (ne pas démarrer pour Empower) est immédiat.
                print("|cff00CCFFOpulent Casting Bars|r — |cffffff00Reload UI required|r for Blizzard empower bar to show.")
            elseif SCB.Config:Get("hideBlizzardBar") then
                -- En désactivant l'option, les events EMPOWER doivent être tués
                -- sur PlayerCastingBarFrame (ils avaient été préservés au login).
                -- Sinon OCB + Blizzard s'affichent simultanément sur les sorts Empowered.
                local f = _G["PlayerCastingBarFrame"]
                if f then
                    f:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_START")
                    f:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
                    f:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_INTERRUPTED")
                    f:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
                end
            end
        end)
        c.empowerKeepCb=empowerKeepCb ; yOf=yOf-36

        local strataOptions = {
            {key="BACKGROUND", label="Background"},
            {key="LOW",        label="Low"},
            {key="MEDIUM",     label="Medium"},
            {key="HIGH",       label="High"},
            {key="DIALOG",     label="Dialog"},
            {key="FULLSCREEN", label="Fullscreen"},
            {key="FULLSCREEN_DIALOG", label="Fullscreen Dialog"},
            {key="TOOLTIP",    label="Tooltip"},
        }
        local strataLbl=c:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
        strataLbl:SetPoint("TOPLEFT",20,yOf)
        strataLbl:SetText("Bar strata:") ; yOf=yOf-20

        local strataDrop=MakeDropdown(c, strataOptions,
            SCB.Config:Get("barStrata") or "MEDIUM",
            20,yOf,170,
            function(key)
                SCB.Config:Set("barStrata",key)
                SCB.Bar.frame:SetFrameStrata(key)
                if SCB.Bar.frameInner then SCB.Bar.frameInner:SetFrameStrata(key) end
            end)
        c.strataDrop=strataDrop ; yOf=yOf-42

        local pxVal=SCB.Config:Get("x") or 0
        local posXSl=MakeSlider(c,string.format("Position X: %d",pxVal),-800,800,pxVal,1,yOf)
        posXSl.Low:SetText("-800") ; posXSl.High:SetText("800")
        posXSl:SetScript("OnValueChanged",function(self,v)
            v=math.floor(v+0.5) ; self.Label:SetText(string.format("Position X: %d",v))
            SCB.Config:Set("x",v) ; SCB.Bar.frame:ClearAllPoints()
            SCB.Bar.frame:SetPoint(SCB.Config:Get("anchor"),UIParent,
                                   SCB.Config:Get("anchor"),v,SCB.Config:Get("y"))
        end)
        c.posXSl=posXSl ; yOf=yOf-50

        local pyVal=SCB.Config:Get("y") or -250
        local posYSl=MakeSlider(c,string.format("Position Y: %d",pyVal),-600,600,pyVal,1,yOf)
        posYSl.Low:SetText("-600") ; posYSl.High:SetText("800")
        posYSl:SetScript("OnValueChanged",function(self,v)
            v=math.floor(v+0.5) ; self.Label:SetText(string.format("Position Y: %d",v))
            SCB.Config:Set("y",v) ; SCB.Bar.frame:ClearAllPoints()
            SCB.Bar.frame:SetPoint(SCB.Config:Get("anchor"),UIParent,
                                   SCB.Config:Get("anchor"),SCB.Config:Get("x"),v)
        end)
        c.posYSl=posYSl
    end

    -- ============================================================
    --  TAB 2 : APPEARANCE
    -- ============================================================
    do
        local c,yOf=contents[2],-16

        -- Liste des styles — barres neutres en tête, puis ordre alphabétique
        local styleOptions={
            -- ---- Barres neutres / génériques --------------------------
            {key="neutral",       label="Neutral"},
            {key="neutral2",      label="Neutral 2"},
            {key="neutral3",      label="Neutral 3"},
            {key="metal",         label="Neutral - Metal"},
            {key="metal_icon",    label="Metal Icon"},
            {key="engrenages",    label="Engrenages"},
            {key="honey_icon",    label="Honey - Icons"},
            {key="mossystone_icon",label="Mossy Stone - Icons"},
            {key="mossystone",    label="Mossy Stone"},
            {key="viking",        label="Viking Icon"},
            {key="alliance",      label="Alliance"},
            {key="horde",         label="Horde"},
            {key="bronze",        label="Bronze"},
            -- ---- Reste par ordre alphabétique -------------------------
            {key="aim",           label="Aim"},
            {key="arcane",        label="Arcane"},
            {key="arcaneum",      label="Arcaneum"},
            {key="arctic",        label="Arctic"},
            {key="chaos",         label="Chaos"},
            {key="chiji",         label="Chi'ji"},
            {key="earth",         label="Earth"},
            {key="felfire",       label="Felfire"},
            {key="fire",          label="Fire"},
            {key="fishing",       label="Fishing"},
            {key="frost",         label="Frost"},
            {key="frostfire",     label="Frostfire"},
            {key="herbalism",     label="Herbalism"},
            {key="holy",          label="Holy"},
            {key="inferno",       label="Inferno"},
            {key="lava",          label="Lava"},
            {key="lumber",        label="Lumber"},
            {key="mining",        label="Mining"},
            {key="mistweaver",    label="Mistweaver"},
            {key="moon",          label="Moon"},
            {key="nature",        label="Nature"},
            {key="paladin",       label="Paladin"},
            {key="sacred",        label="Sacred"},
            {key="shadow",        label="Shadow"},
            {key="skinning",      label="Skinning"},
            {key="thunder",       label="Thunder"},
            {key="void",          label="Void"},
            {key="water",         label="Water"},
            {key="fists",         label="Fists of Fury"},
        }

        -- ---- Miniature preview (BG + Fill masqué + Frame uniquement) ----
        local pvBorder=CreateFrame("Frame",nil,c,BackdropTemplateMixin and "BackdropTemplate" or nil)
        pvBorder:SetSize(230,120) ; pvBorder:SetPoint("TOPRIGHT",c,"TOPRIGHT",-20,-16)
        if pvBorder.SetBackdrop then
            pvBorder:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
                tile=true,tileSize=32,edgeSize=16,insets={left=5,right=5,top=5,bottom=5}})
        end
        local pvLbl=pvBorder:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
        pvLbl:SetPoint("TOP",pvBorder,"TOP",0,-8) ; pvLbl:SetText("Preview")

        local pvInner=CreateFrame("Frame",nil,pvBorder)
        pvInner:SetSize(200,100) ; pvInner:SetPoint("CENTER",pvBorder,"CENTER",0,-4)
        pvInner:SetScale(0.50)

        local pvBG   =pvInner:CreateTexture(nil,"BACKGROUND") ; pvBG:SetAllPoints()
        local pvFill =pvInner:CreateTexture(nil,"ARTWORK")     ; pvFill:SetAllPoints()
        local pvMask =pvInner:CreateMaskTexture()
        pvMask:SetTexture("Interface\\BUTTONS\\WHITE8X8","CLAMPTOBLACKADDITIVE","CLAMPTOBLACKADDITIVE")
        pvMask:SetPoint("TOPLEFT",pvInner,"TOPLEFT")
        pvMask:SetPoint("BOTTOMLEFT",pvInner,"BOTTOMLEFT")
        pvMask:SetWidth(1) ; pvFill:AddMaskTexture(pvMask)
        local pvFrame=pvInner:CreateTexture(nil,"OVERLAY") ; pvFrame:SetAllPoints()

        local pvTimer=0 ; local pvDur=3.0 ; local pvActive=false

        local function PreviewApply(key)
            local s=SCB.Schools and SCB.Schools:Get(key)
            if not s then return end
            pvBG:SetTexture(s.bg) ; pvBG:SetAlpha(1)
            pvFill:SetTexture(s.fill) ; pvFill:SetAlpha(1)
            local fTex=(s.frames and s.frames[1]) or s.frame
            pvFrame:SetTexture(fTex) ; pvFrame:SetAlpha(fTex and 1 or 0)
        end

        local function PreviewStart(key)
            pvTimer=0 ; pvActive=true ; pvMask:SetWidth(1) ; PreviewApply(key)
        end

        pvInner:SetScript("OnUpdate",function(_,dt)
            if not pvActive then return end
            pvTimer=pvTimer+dt
            local p=math.min(pvTimer/pvDur,1)
            pvMask:SetWidth(math.max(200*p,1))
            if p>=1 then pvActive=false end
        end)

        -- ---- Section : mode de sélection ----
        MakeSectionLabel(c,"Bar style selection",yOf) ; yOf=yOf-26

        -- Deux checkboxes en mode radio : Auto vs Fixe
        local useDetectCb=MakeCheck(c,"Automatic — choose bar by spell school  (recommended)",
                                    yOf, SCB.Config:Get("useSchoolDetection"))
        yOf=yOf-30
        local useFixedCb=MakeCheck(c,"Fixed — use the same bar style for all spells",
                                   yOf, not SCB.Config:Get("useSchoolDetection"))
        yOf=yOf-34

        -- Dropdown "Fixed style"
        local fixedDropLbl=c:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
        fixedDropLbl:SetPoint("TOPLEFT",36,yOf)
        fixedDropLbl:SetText("Bar to use for all spells :") ; yOf=yOf-20

        local fixedDrop=MakeDropdown(c,styleOptions,
            SCB.Config:Get("defaultSchool") or "neutral",
            36,yOf,185,
            function(key) SCB.Config:Set("defaultSchool",key) end,
            PreviewStart)
        yOf=yOf-38

        -- Séparateur visuel
        local sep=c:CreateTexture(nil,"BACKGROUND")
        sep:SetColorTexture(0.4,0.4,0.4,0.5) ; sep:SetSize(380,1)
        sep:SetPoint("TOPLEFT",14,yOf) ; yOf=yOf-14

        -- Dropdown "Default school bar" (mode Auto)
        local autoDefLbl=c:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
        autoDefLbl:SetPoint("TOPLEFT",36,yOf)
        autoDefLbl:SetText("Default bar when school is unknown :") ; yOf=yOf-20

        local autoDefDrop=MakeDropdown(c,styleOptions,
            SCB.Config:Get("defaultSchool") or "neutral",
            36,yOf,185,
            function(key) SCB.Config:Set("defaultSchool",key) end,
            PreviewStart)

        -- Fonction pour mettre à jour l'état visuel selon le mode
        local function RefreshModeUI()
            local isAuto=SCB.Config:Get("useSchoolDetection")
            fixedDrop:SetEnabled(not isAuto)
            autoDefDrop:SetEnabled(isAuto)
            -- Labels en gris si inactif
            fixedDropLbl:SetTextColor(isAuto and 0.5 or 1, isAuto and 0.5 or 1, isAuto and 0.5 or 1)
            autoDefLbl:SetTextColor(isAuto and 1 or 0.5, isAuto and 1 or 0.5, isAuto and 1 or 0.5)
        end

        RefreshModeUI()

        useDetectCb:SetScript("OnClick",function(self)
            SCB.Config:Set("useSchoolDetection",true)
            useDetectCb:SetChecked(true) ; useFixedCb:SetChecked(false)
            RefreshModeUI()
        end)
        useFixedCb:SetScript("OnClick",function(self)
            SCB.Config:Set("useSchoolDetection",false)
            useDetectCb:SetChecked(false) ; useFixedCb:SetChecked(true)
            RefreshModeUI()
        end)

        PreviewStart(SCB.Config:Get("defaultSchool") or "neutral")

        c.useDetectCb  = useDetectCb
        c.useFixedCb   = useFixedCb
        c.fixedDrop    = fixedDrop
        c.autoDefDrop  = autoDefDrop
        c.previewStart = PreviewStart
        c.refreshMode  = RefreshModeUI
    end

    -- ============================================================
    --  TAB 3 : TEXT — avec ScrollFrame pour tout afficher
    -- ============================================================
    do
        local tabFrame = contents[3]

        local sf = CreateFrame("ScrollFrame", nil, tabFrame, "UIPanelScrollFrameTemplate")
        sf:SetPoint("TOPLEFT",  tabFrame, "TOPLEFT",  0,  0)
        sf:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", -26, 0)

        local c = CreateFrame("Frame", nil, sf)
        c:SetSize(380, 1200)
        sf:SetScrollChild(c)
        tabFrame._scrollChild = c

        local yOf = -16
        local alignOpts = {{key="LEFT",label="Left"},{key="CENTER",label="Center"},{key="RIGHT",label="Right"}}

        -- ---- Font & Style ----------------------------------------
        MakeSectionLabel(c,"- Font & Style -",yOf) ; yOf=yOf-22

        -- OCB bundled fonts (LSM names as keys so resolveFace can fetch via LSM)
        local FONTS = {
            { key="DEFAULT",           label="Kenyan Coffee (default)" },
            { key="BLIZZARD",          label="Blizzard (Friz Quadrata)" },
            { key="Gaegu",             label="Gaegu" },
            { key="Teko",              label="Teko" },
            { key="Titan One",         label="Titan One" },
            { key="Yanone Kaffeesatz", label="Yanone Kaffeesatz" },
            { key="Expressway",        label="Expressway" },
            { key="Nexa",              label="Nexa" },
            { key="Casual Memories",   label="Casual Memories" },
            { key="Alte Haas Grotesk", label="Alte Haas Grotesk" },
            { key="Steelfish",         label="Steelfish" },
            { key="GAME_CHINESE",      label="Chinese (ARKai — zhCN/zhTW)" },
        }
        -- Append any additional fonts registered with LibSharedMedia by other addons
        local _ocbLSM = LibStub and LibStub("LibSharedMedia-3.0", true)
        if _ocbLSM then
            local _ocbFontSet = {}
            for _, f in ipairs(FONTS) do _ocbFontSet[f.key] = true end
            _ocbFontSet["Kenyan Coffee"] = true  -- registered but shown as DEFAULT
            local _lsmList = _ocbLSM:List(_ocbLSM.MediaType.FONT)
            if _lsmList then
                for _, name in ipairs(_lsmList) do
                    if not _ocbFontSet[name] then
                        -- Only add fonts whose source addon is actually loaded;
                        -- noDefault=true so a missing key doesn't return the
                        -- fallback path and masquerade as a valid entry.
                        local path = _ocbLSM:Fetch(_ocbLSM.MediaType.FONT, name, true)
                        if path then
                            table.insert(FONTS, { key=name, label=name })
                        end
                    end
                end
            end
        end

        local fontLbl = c:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
        fontLbl:SetPoint("TOPLEFT",14,yOf) ; fontLbl:SetText("Font:") ; yOf=yOf-20

        local curFontKey = SCB.Config:Get("fontFace") or "DEFAULT"
        local fontDrop = MakeDropdown(c, FONTS, curFontKey, 20, yOf, 210,
            function(k)
                SCB.Config:Set("fontFace", k)
                -- Couper le test en cours pour forcer rechargement de la police
                if SCB.Bar.isActive or SCB.Bar.isFading then
                    SCB.Bar:StopCast(false)
                end
                -- DEFAULT = Kenyan Coffee taille 13
                if k == "DEFAULT" then
                    SCB.Config:Set("textNameSize",  13)
                    SCB.Config:Set("textTimerSize", 13)
                    if c.nameSizeSl  then c.nameSizeSl:SetValue(13)  end
                    if c.timerSizeSl then c.timerSizeSl:SetValue(13) end
                end
                SCB.Bar:ApplyTextPrefs()
            end)
        c.fontDrop = fontDrop ; yOf=yOf-36

        local outlineCb = MakeCheck(c, "Text outline", yOf, SCB.Config:Get("textOutline") or false)
        outlineCb:SetScript("OnClick", function(self)
            SCB.Config:Set("textOutline", self:GetChecked())
            SCB.Bar:ApplyTextPrefs()
        end)
        c.outlineCb = outlineCb ; yOf=yOf-28

        local centeredCb = MakeCheck(c, "Center both (name | timer)", yOf, SCB.Config:Get("textCentered") or false)
        centeredCb:SetScript("OnClick", function(self)
            SCB.Config:Set("textCentered", self:GetChecked())
            SCB.Bar:ApplyTextPrefs()
        end)
        c.centeredCb = centeredCb ; yOf=yOf-36

        -- ---- Spell Name ------------------------------------------
        MakeSectionLabel(c,"- Spell Name -",yOf) ; yOf=yOf-22

        local showNameCb = MakeCheck(c,"Show spell name",yOf,SCB.Config:Get("textNameShow"))
        showNameCb:SetScript("OnClick",function(self)
            local v=self:GetChecked()
            SCB.Config:Set("textNameShow",v) ; SCB.Config:Set("showSpellName",v)
            SCB.Bar.spellNameText:SetShown(v)
            SCB.Bar:ApplyTextPrefs()
        end)
        c.showNameCb = showNameCb ; yOf=yOf-30

        local truncateCb = MakeCheck(c,"Truncate spell names longer than 30 characters",yOf,SCB.Config:Get("textNameTruncate"))
        truncateCb:SetScript("OnClick",function(self)
            SCB.Config:Set("textNameTruncate", self:GetChecked())
            SCB.Bar:ApplyTextPrefs()
        end)
        c.truncateCb = truncateCb ; yOf=yOf-30

        local nameSize = SCB.Config:Get("textNameSize") or 13
        local nameSizeSl = MakeSlider(c,string.format("Size: %d",nameSize),7,22,nameSize,1,yOf)
        nameSizeSl.Low:SetText("7") ; nameSizeSl.High:SetText("22")
        nameSizeSl:SetScript("OnValueChanged",function(self,v)
            v=math.floor(v+0.5) ; self.Label:SetText(string.format("Size: %d",v))
            SCB.Config:Set("textNameSize",v)
            SCB.Bar:ApplyTextPrefs()
        end)
        c.nameSizeSl = nameSizeSl ; yOf=yOf-48

        local naLbl = c:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
        naLbl:SetPoint("TOPLEFT",20,yOf) ; naLbl:SetText("Alignment:") ; yOf=yOf-20
        c.nameAlignRadios = MakeRadioGroup(c,alignOpts,
            SCB.Config:Get("textNameAlign") or "LEFT",20,yOf,90,
            function(k) SCB.Config:Set("textNameAlign",k) ; SCB.Bar:ApplyTextPrefs() end)
        yOf=yOf-36

        -- ---- Timer -----------------------------------------------
        MakeSectionLabel(c,"- Timer -",yOf) ; yOf=yOf-22

        local showTimerCb = MakeCheck(c,"Show cast timer",yOf,SCB.Config:Get("textTimerShow"))
        showTimerCb:SetScript("OnClick",function(self)
            local v=self:GetChecked()
            SCB.Config:Set("textTimerShow",v) ; SCB.Config:Set("showCastTime",v)
            SCB.Bar.castTimerText:SetShown(v)
        end)
        c.showTimerCb = showTimerCb ; yOf=yOf-30

        local timerSize = SCB.Config:Get("textTimerSize") or 13
        local timerSizeSl = MakeSlider(c,string.format("Size: %d",timerSize),7,22,timerSize,1,yOf)
        timerSizeSl.Low:SetText("7") ; timerSizeSl.High:SetText("22")
        timerSizeSl:SetScript("OnValueChanged",function(self,v)
            v=math.floor(v+0.5) ; self.Label:SetText(string.format("Size: %d",v))
            SCB.Config:Set("textTimerSize",v)
            SCB.Bar:ApplyTextPrefs()
        end)
        c.timerSizeSl = timerSizeSl ; yOf=yOf-48

        local taLbl = c:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
        taLbl:SetPoint("TOPLEFT",20,yOf) ; taLbl:SetText("Alignment:") ; yOf=yOf-20
        c.timerAlignRadios = MakeRadioGroup(c,alignOpts,
            SCB.Config:Get("textTimerAlign") or "RIGHT",20,yOf,90,
            function(k) SCB.Config:Set("textTimerAlign",k) ; SCB.Bar:ApplyTextPrefs() end)
        yOf=yOf-36

        -- ---- Text Position ---------------------------------------
        MakeSectionLabel(c,"- Text Position -",yOf) ; yOf=yOf-22

        MakeSectionLabel(c,"Spell Name",yOf) ; yOf=yOf-20

        local namePosXVal = SCB.Config:Get("textNamePosX") or 0
        local namePosXSl = MakeSlider(c,string.format("X offset: %d",namePosXVal),-80,80,namePosXVal,1,yOf)
        namePosXSl.Low:SetText("-80") ; namePosXSl.High:SetText("+80")
        namePosXSl:SetScript("OnValueChanged",function(self,v)
            v=math.floor(v+0.5) ; self.Label:SetText(string.format("X offset: %d",v))
            SCB.Config:Set("textNamePosX",v) ; SCB.Bar:ApplyTextPrefs()
        end)
        c.namePosXSl = namePosXSl ; yOf=yOf-48

        local namePosYVal = SCB.Config:Get("textNamePosY") or 0
        local namePosYSl = MakeSlider(c,string.format("Y offset: %d",namePosYVal),-40,40,namePosYVal,1,yOf)
        namePosYSl.Low:SetText("-40") ; namePosYSl.High:SetText("+40")
        namePosYSl:SetScript("OnValueChanged",function(self,v)
            v=math.floor(v+0.5) ; self.Label:SetText(string.format("Y offset: %d",v))
            SCB.Config:Set("textNamePosY",v) ; SCB.Bar:ApplyTextPrefs()
        end)
        c.namePosYSl = namePosYSl ; yOf=yOf-48

        MakeSectionLabel(c,"Timer",yOf) ; yOf=yOf-20

        local timerPosXVal = SCB.Config:Get("textTimerPosX") or 0
        local timerPosXSl = MakeSlider(c,string.format("X offset: %d",timerPosXVal),-80,80,timerPosXVal,1,yOf)
        timerPosXSl.Low:SetText("-80") ; timerPosXSl.High:SetText("+80")
        timerPosXSl:SetScript("OnValueChanged",function(self,v)
            v=math.floor(v+0.5) ; self.Label:SetText(string.format("X offset: %d",v))
            SCB.Config:Set("textTimerPosX",v) ; SCB.Bar:ApplyTextPrefs()
        end)
        c.timerPosXSl = timerPosXSl ; yOf=yOf-48

        local timerPosYVal = SCB.Config:Get("textTimerPosY") or 0
        local timerPosYSl = MakeSlider(c,string.format("Y offset: %d",timerPosYVal),-40,40,timerPosYVal,1,yOf)
        timerPosYSl.Low:SetText("-40") ; timerPosYSl.High:SetText("+40")
        timerPosYSl:SetScript("OnValueChanged",function(self,v)
            v=math.floor(v+0.5) ; self.Label:SetText(string.format("Y offset: %d",v))
            SCB.Config:Set("textTimerPosY",v) ; SCB.Bar:ApplyTextPrefs()
        end)
        c.timerPosYSl = timerPosYSl ; yOf=yOf-48

        -- ---- Text Color ------------------------------------------
        MakeSectionLabel(c,"- Text Color -",yOf) ; yOf=yOf-22

        -- Swatches prédéfinies
        local SWATCHES = {
            {r=1.0, g=1.0, b=1.0,  label="White"},
            {r=1.0, g=0.85,b=0.0,  label="Yellow"},
            {r=0.4, g=0.8, b=1.0,  label="Blue"},
            {r=0.4, g=1.0, b=0.4,  label="Green"},
            {r=1.0, g=0.4, b=0.4,  label="Red"},
            {r=1.0, g=0.6, b=0.1,  label="Orange"},
            {r=0.8, g=0.5, b=1.0,  label="Purple"},
            {r=0.6, g=0.6, b=0.6,  label="Grey"},
        }

        local swLbl = c:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
        swLbl:SetPoint("TOPLEFT",14,yOf) ; swLbl:SetText("Preset colors:") ; yOf=yOf-20

        -- Fonction appliquant la couleur custom aux deux textes
        local function applyCustomColor(r,g,b)
            SCB.Config:Set("textCustomColor", {r=r,g=g,b=b})
            SCB.Config:Set("textNameColor",  "custom")
            SCB.Config:Set("textTimerColor", "custom")
            SCB.Bar:ApplyTextPrefs()
        end

        -- Créer les swatches sur 2 rangées de 4
        local swSize = 22
        local swGap  = 4
        for i, sw in ipairs(SWATCHES) do
            local col = CreateFrame("Button", nil, c)
            col:SetSize(swSize, swSize)
            local row = math.floor((i-1)/4)
            local col_idx = (i-1) % 4
            col:SetPoint("TOPLEFT", 20 + col_idx*(swSize+swGap), yOf - row*(swSize+swGap))
            -- Bordure en BACKGROUND en premier → bg coloré par-dessus dans le même layer
            local border = col:CreateTexture(nil,"BACKGROUND")
            border:SetPoint("TOPLEFT",-1,1) ; border:SetPoint("BOTTOMRIGHT",1,-1)
            border:SetColorTexture(0.3,0.3,0.3)
            local bg = col:CreateTexture(nil,"BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(sw.r, sw.g, sw.b)
            local hl = col:CreateTexture(nil,"HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetColorTexture(1,1,1,0.3)
            col:SetScript("OnClick", function()
                applyCustomColor(sw.r, sw.g, sw.b)
                -- Mettre à jour l'apercu hex
                if c.hexBox then
                    c.hexBox:SetText(string.format("%02X%02X%02X",
                        math.floor(sw.r*255), math.floor(sw.g*255), math.floor(sw.b*255)))
                end
            end)
            col:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText(sw.label, sw.r, sw.g, sw.b)
                GameTooltip:Show()
            end)
            col:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        yOf = yOf - 2*(swSize+swGap) - 8

        -- Saisie hex manuelle
        local hexLbl = c:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
        hexLbl:SetPoint("TOPLEFT",14,yOf) ; hexLbl:SetText("Hex color:") ; yOf=yOf-20

        local hexBox = CreateFrame("EditBox", nil, c, "InputBoxTemplate")
        hexBox:SetSize(90,22) ; hexBox:SetPoint("TOPLEFT",20,yOf)
        hexBox:SetMaxLetters(6) ; hexBox:SetAutoFocus(false)
        -- Valeur initiale depuis config
        local savedCol = SCB.Config:Get("textCustomColor")
        if savedCol then
            hexBox:SetText(string.format("%02X%02X%02X",
                math.floor((savedCol.r or 1)*255),
                math.floor((savedCol.g or 1)*255),
                math.floor((savedCol.b or 1)*255)))
        else
            hexBox:SetText("FFFFFF")
        end
        c.hexBox = hexBox

        -- Apercu de la couleur saisie
        local hexPreview = c:CreateTexture(nil,"ARTWORK")
        hexPreview:SetSize(22,22) ; hexPreview:SetPoint("LEFT",hexBox,"RIGHT",6,0)
        hexPreview:SetColorTexture(1,1,1)

        local function parseHex(hex)
            hex = hex:gsub("#",""):upper()
            if #hex ~= 6 then return nil end
            local r = tonumber(hex:sub(1,2),16)
            local g = tonumber(hex:sub(3,4),16)
            local b = tonumber(hex:sub(5,6),16)
            if r and g and b then
                return r/255, g/255, b/255
            end
        end

        hexBox:SetScript("OnTextChanged", function(self)
            local r,g,b = parseHex(self:GetText())
            if r then hexPreview:SetColorTexture(r,g,b) end
        end)
        hexBox:SetScript("OnEnterPressed", function(self)
            local r,g,b = parseHex(self:GetText())
            if r then
                applyCustomColor(r,g,b)
                hexPreview:SetColorTexture(r,g,b)
            end
            self:ClearFocus()
        end)
        hexBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

        -- Bouton Apply
        local applyBtn = CreateFrame("Button",nil,c,"UIPanelButtonTemplate")
        applyBtn:SetSize(60,22) ; applyBtn:SetPoint("LEFT",hexPreview,"RIGHT",6,0)
        applyBtn:SetText("Apply")
        applyBtn:SetScript("OnClick", function()
            local r,g,b = parseHex(hexBox:GetText())
            if r then
                applyCustomColor(r,g,b)
                hexPreview:SetColorTexture(r,g,b)
            end
        end)
        yOf=yOf-36
    end

    -- ============================================================
    --  SEPARATE SUB-PANEL: THEME ASSIGNMENTS
    -- ============================================================
    local themePanel = CreateFrame("Frame")
    themePanel.name = "Theme Assignments"
    themePanel.parent = panel.name
    do
        local sf = CreateFrame("ScrollFrame", nil, themePanel, "UIPanelScrollFrameTemplate")
        sf:SetPoint("TOPLEFT", themePanel, "TOPLEFT", 0, 0)
        sf:SetPoint("BOTTOMRIGHT", themePanel, "BOTTOMRIGHT", -26, 0)

        local p = CreateFrame("Frame", nil, sf)
        p:SetSize(740, 900)
        sf:SetScrollChild(p)
        themePanel._scrollChild = p

        local titleFS = p:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
        titleFS:SetPoint("TOPLEFT",16,-16)
        titleFS:SetText("Theme Assignments")

        local helpFS = p:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
        helpFS:SetPoint("TOPLEFT",titleFS,"BOTTOMLEFT",0,-6)
        helpFS:SetText("Map each school to a theme. Custom assignments override automatic school visuals.")

        -- styleOptions : liste des thèmes utilisable pour les dropdowns
        -- schoolStyleOptions inclut l'option "Aucun" (pas d'override) en tête
        local styleOptions={
            {key="neutral",  label="Neutral"},   {key="neutral2", label="Neutral 2"},
            {key="neutral3", label="Neutral 3"}, {key="metal",    label="Neutral - Metal"},
            {key="metal_icon", label="Metal Icon"},
            {key="engrenages", label="Engrenages"},
            {key="honey_icon", label="Honey - Icons"},
            {key="mossystone_icon", label="Mossy Stone - Icons"},
            {key="mossystone", label="Mossy Stone"},
            {key="viking",   label="Viking Icon"},
            {key="bronze",   label="Bronze"},
            {key="aim",      label="Aim"},
            {key="arcane",   label="Arcane"},    {key="arcaneum", label="Arcaneum"},
            {key="arctic",   label="Arctic"},
            {key="chaos",    label="Chaos"},
            {key="chiji",    label="Chi'ji"},
            {key="earth",    label="Earth"},
            {key="felfire",  label="Felfire"},
            {key="fire",     label="Fire"},
            {key="fishing",  label="Fishing"},
            {key="frost",    label="Frost"},     {key="frostfire",label="Frostfire"},
            {key="herbalism",label="Herbalism"},
            {key="holy",     label="Holy"},
            {key="inferno",  label="Inferno"},
            {key="lava",     label="Lava"},
            {key="lumber",   label="Lumber"},
            {key="mining",   label="Mining"},
            {key="mistweaver",label="Mistweaver"},
            {key="moon",     label="Moon"},
            {key="nature",   label="Nature"},
            {key="paladin",  label="Paladin"},
            {key="sacred",   label="Sacred"},
            {key="shadow",   label="Shadow"},
            {key="skinning", label="Skinning"},
            {key="thunder",  label="Thunder"},
            {key="void",     label="Void"},
            {key="water",    label="Water"},
            {key="alliance", label="Alliance"},  {key="horde",    label="Horde"},
            {key="fists",    label="Fists of Fury"},
        }
        -- schoolStyleOptions : même liste avec "None" et "Blizzard UI" en tête
        local schoolStyleOptions = {}
        schoolStyleOptions[1] = {key="none",     label="— None (no override) —"}
        schoolStyleOptions[2] = {key="blizzard", label="— Blizzard UI —"}
        for _, o in ipairs(styleOptions) do
            schoolStyleOptions[#schoolStyleOptions+1] = o
        end

        local schoolRows = {
            {key="inferno",   label="Fire",         icon="Spell_Fire_FireBolt02"},
            {key="arctic",    label="Frost",        icon="Spell_Frost_FrostBolt02"},
            {key="arcaneum",  label="Arcane",       icon="Spell_Arcane_Blink"},
            {key="nature",    label="Nature",       icon="Spell_Nature_Lightning"},
            {key="shadow",    label="Shadow",       icon="Spell_Shadow_ShadowBolt"},
            {key="paladin",   label="Paladin",      icon="spell_holy_avenginewrath"},
            {key="sacred",    label="Sacred",       icon="Spell_Holy_HolyBolt"},
            {key="earth",     label="Earth",        icon="Spell_Nature_StrengthOfEarthTotem02"},
            {key="thunder",   label="Thunder",      icon="Spell_Nature_ChainLightning"},
            {key="moon",      label="Arcane Druid", icon="Spell_Nature_StarFall"},
            {key="mistweaver",label="Mistweaver",   iconFull=SCB.TEX_PATH.."mistweaver\\Mistweaver_Logo"},
            {key="void",      label="Void",         icon="Spell_Shadow_BlackPlague"},
            {key="chaos",     label="Chaos",        icon="Ability_Warlock_ChaosBolt"},
            {key="felfire",   label="Felfire",      icon="Spell_Fire_FelFire"},
            {key="frostfire", label="Frostfire",    iconFull=SCB.TEX_PATH.."frostfire\\Logo_Frostfire"},
            {key="bronze",    label="Bronze",       icon="INV_Misc_EngGizmos_03", warning=true},
            {key="misc",      label="Misc",         icon="INV_Misc_QuestionMark"},
            {key="fishing",   label="Fishing",      icon="Trade_Fishing"},
            {key="mining",    label="Mining",       icon="Trade_Mining"},
            {key="herbalism", label="Herbalism",    icon="Trade_Herbalism"},
            {key="skinning",  label="Skinning",     icon="INV_Misc_Pelt_Wolf_01"},
            {key="water",     label="Water",        icon="Spell_Frost_SummonWaterElemental"},
        }

        local function StartPreview(key)
            if SCB.Bar.isActive or SCB.Bar.isFading then
                SCB.Bar:StopCast(false)
            end
            SCB.Bar.frame:SetFrameStrata("TOOLTIP")
            SCB.Bar:StartCast("Preview",3,key)
            SCB.Bar.frame:SetScript("OnHide",function(self)
                self:SetFrameStrata(SCB.Config:Get("barStrata") or "MEDIUM") ; self:SetScript("OnHide",nil)
            end)
        end

        local function MakeEyeButton(parent, anchorTo)
            local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
            b:SetSize(24,24)
            b:SetPoint("LEFT",anchorTo,"RIGHT",6,0)
            local tex=b:CreateTexture(nil,"ARTWORK")
            tex:SetTexture(SCB.TEX_PATH.."Eye.tga")
            tex:SetSize(14,14)
            tex:SetPoint("CENTER")
            b._icon=tex
            return b
        end

        local yOf = -56
        local assignCb = MakeCheck(p,"Use custom assignments",yOf,SCB.Config:Get("useThemeAssignments") or false)
        yOf = yOf - 34

        local hint = p:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT",20,yOf)
        hint:SetText("When enabled, these mappings override other school settings.")
        yOf = yOf - 24

        local rowWidgets = {}
        local rowH = 30
        local colX = {20, 360}

        local function ThemeForRow(key)
            local map = SCB.Config:Get("themeAssignments") or {}
            local v = map[key]
            -- "none" = explicit no-override → behave like unset (natural fallback)
            if v == "none" then v = nil end
            if not v then
                if key == "misc" then
                    v = map.misc or (SCB.Config:Get("defaultSchool") or "neutral")
                else
                    v = key
                end
            end
            return v
        end

        for i,row in ipairs(schoolRows) do
            local col = ((i - 1) % 2) + 1
            local idx = math.floor((i - 1) / 2)
            local rowY = yOf - idx * rowH

            local holder = CreateFrame("Frame",nil,p)
            holder:SetSize(320,24)
            holder:SetPoint("TOPLEFT",colX[col],rowY)

            local ico=holder:CreateTexture(nil,"ARTWORK")
            ico:SetSize(14,14)
            ico:SetPoint("LEFT",holder,"LEFT",0,0)
            ico:SetTexture(row.iconFull or ("Interface\\Icons\\"..(row.icon or "INV_Misc_QuestionMark")))

            local lbl=holder:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
            lbl:SetPoint("LEFT",ico,"RIGHT",4,0)
            lbl:SetWidth(94)
            lbl:SetJustifyH("LEFT")
            lbl:SetText(row.label)

            if row.warning then
                local w=CreateFrame("Button",nil,holder)
                w:SetSize(14,14)
                w:SetPoint("LEFT",lbl,"LEFT",lbl:GetStringWidth()+2,0)
                local wtxt=w:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
                wtxt:SetPoint("CENTER")
                wtxt:SetText("|cffffcc00!|r")
                w:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self,"ANCHOR_TOP")
                    GameTooltip:SetText("Empowered spells only display correctly on Bronze themes.")
                    GameTooltip:Show()
                end)
                w:SetScript("OnLeave", function() GameTooltip:Hide() end)
            end

            -- Valeur initiale : lire la config brute (peut être "none")
            local function rawAssignedKey(key)
                local map = SCB.Config:Get("themeAssignments") or {}
                return map[key] or "none"
            end
            local dd=MakeDropdown(holder,schoolStyleOptions,rawAssignedKey(row.key),102,2,128,function(style)
                local map = SCB.Config:Get("themeAssignments") or {}
                map[row.key]=style
                SCB.Config:Set("themeAssignments",map)
                -- Si "Blizzard UI" est sélectionné alors que le mode dynamique
                -- n'est pas actif (login sans assignment "blizzard"), un ReloadUI est nécessaire.
                if style == "blizzard" and not SCB._blizzardDynamic then
                    print("|cff00CCFFOpulent Casting Bars|r — |cffffff00ReloadUI required|r"
                          .." for the Blizzard bar to appear for this school.")
                end
            end)

            local eye=MakeEyeButton(holder,dd)
            eye:SetScript("OnClick",function()
                StartPreview(ThemeForRow(row.key))
            end)

            rowWidgets[#rowWidgets+1]={key=row.key,label=lbl,drop=dd,eye=eye}
        end

        local rowsBottom = yOf - math.ceil(#schoolRows / 2) * rowH - 12
        MakeSectionLabel(p,"Advanced: Spell ID overrides",rowsBottom)
        rowsBottom = rowsBottom - 26

        local editSpellID=nil
        local spellIdBox=CreateFrame("EditBox",nil,p,"InputBoxTemplate")
        spellIdBox:SetSize(110,24)
        spellIdBox:SetPoint("TOPLEFT",20,rowsBottom)
        spellIdBox:SetAutoFocus(false)
        spellIdBox:SetNumeric(true)

        local spellIdNameLbl = p:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        spellIdNameLbl:SetPoint("TOPLEFT",20,rowsBottom-28)
        spellIdNameLbl:SetText("")
        spellIdBox:SetScript("OnTextChanged", function(self)
            local sid = tonumber(self:GetText())
            if sid and sid > 0 and C_Spell and C_Spell.GetSpellName then
                local name = C_Spell.GetSpellName(sid)
                spellIdNameLbl:SetText(name and ("|cff00ff00"..name.."|r") or "|cffff4444Not found|r")
            else
                spellIdNameLbl:SetText("")
            end
        end)

        local spellThemeKey="neutral"
        local spellThemeDrop=MakeDropdown(p,styleOptions,spellThemeKey,140,rowsBottom+2,170,function(k) spellThemeKey=k end)

        local saveBtn=CreateFrame("Button",nil,p,"UIPanelButtonTemplate")
        saveBtn:SetSize(90,24)
        saveBtn:SetPoint("LEFT",spellThemeDrop,"RIGHT",8,0)
        saveBtn:SetText("Add")

        local cancelBtn=CreateFrame("Button",nil,p,"UIPanelButtonTemplate")
        cancelBtn:SetSize(70,24)
        cancelBtn:SetPoint("LEFT",saveBtn,"RIGHT",6,0)
        cancelBtn:SetText("Cancel")
        cancelBtn:Hide()

        local statusFS = p:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
        statusFS:SetPoint("TOPLEFT",20,rowsBottom-48)
        statusFS:SetText("Add a Spell ID and assign a cast bar theme.")

        local listAnchorY = rowsBottom - 72
        local selectedSpellID = nil
        local spellRows = {}

        local listTitle = p:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
        listTitle:SetPoint("TOPLEFT",20,listAnchorY + 10)
        listTitle:SetText("Saved Spell ID overrides")

        local listBorder = CreateFrame("Frame", nil, p, BackdropTemplateMixin and "BackdropTemplate" or nil)
        listBorder:SetSize(330, 172)
        listBorder:SetPoint("TOPLEFT", 20, listAnchorY - 12)
        if listBorder.SetBackdrop then
            listBorder:SetBackdrop({
                bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
                tile=true,tileSize=16,edgeSize=8,
                insets={left=2,right=2,top=2,bottom=2}
            })
            listBorder:SetBackdropColor(0.06,0.06,0.06,0.95)
        end

        local listFrame = CreateFrame("ScrollFrame", nil, listBorder, "UIPanelScrollFrameTemplate")
        listFrame:SetPoint("TOPLEFT", listBorder, "TOPLEFT", 4, -4)
        listFrame:SetPoint("BOTTOMRIGHT", listBorder, "BOTTOMRIGHT", -26, 4)
        local listChild = CreateFrame("Frame", nil, listFrame)
        listChild:SetSize(322, 1)
        listFrame:SetScrollChild(listChild)

        local emptyListText = listBorder:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
        emptyListText:SetPoint("CENTER")
        emptyListText:SetText("No Spell ID overrides yet.")

        local actionAnchor = CreateFrame("Frame", nil, p)
        actionAnchor:SetPoint("TOPLEFT", listBorder, "TOPRIGHT", 12, 0)
        actionAnchor:SetSize(1,1)

        local listEditBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        listEditBtn:SetSize(90,24)
        listEditBtn:SetPoint("TOPLEFT", actionAnchor, "TOPLEFT", 0, 0)
        listEditBtn:SetText("Edit")

        local listPreviewBtn = MakeEyeButton(p, listEditBtn)
        listPreviewBtn:SetPoint("TOPLEFT", listEditBtn, "BOTTOMLEFT", 0, -6)

        local listRemoveBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        listRemoveBtn:SetSize(90,24)
        listRemoveBtn:SetPoint("TOPLEFT", listPreviewBtn, "BOTTOMLEFT", 0, -6)
        listRemoveBtn:SetText("Remove")

        local function BuildSpellRows()
            local src = SCB.Config:Get("spellThemeOverrides") or {}
            local out = {}
            for spellID,theme in pairs(src) do
                local sid = tonumber(spellID)
                if sid then
                    local name = nil
                    if C_Spell and C_Spell.GetSpellName then
                        name = C_Spell.GetSpellName(sid)
                    end
                    if not name and GetSpellInfo then
                        name = GetSpellInfo(sid)
                    end
                    if not name then
                        name = "(name unavailable until cached)"
                    end
                    out[#out+1] = {spellID=sid, theme=theme, spellName=name}
                end
            end
            table.sort(out,function(a,b) return (a.spellID or 0) < (b.spellID or 0) end)
            return out
        end

        local function ResetEditor()
            editSpellID=nil
            selectedSpellID=nil
            spellIdBox:SetText("")
            spellThemeKey="neutral"
            spellThemeDrop:SetText(spellThemeDrop._getLabel("neutral"))
            saveBtn:SetText("Add")
            cancelBtn:Hide()
        end

        local function SelectSpellOverride(spellID)
            selectedSpellID = spellID
            for _, row in ipairs(spellRows) do
                local active = (row.spellID == spellID)
                row._selBg:SetAlpha(active and 0.22 or 0)
                row.id:SetTextColor(active and 0.3 or 1, active and 1 or 1, active and 0.5 or 1)
            end
            local enabled = SCB.Config:Get("useThemeAssignments") or false
            listEditBtn:SetEnabled(enabled and selectedSpellID ~= nil)
            listPreviewBtn:SetEnabled(enabled and selectedSpellID ~= nil)
            listRemoveBtn:SetEnabled(enabled and selectedSpellID ~= nil)
        end

        local function RefreshSpellList()
            for _,fr in ipairs(spellRows) do fr:Hide() end
            local rows = BuildSpellRows()
            local cursorY = -2
            emptyListText:SetShown(#rows == 0)
            for i,row in ipairs(rows) do
                local fr = spellRows[i]
                if not fr then
                    fr=CreateFrame("Button",nil,listChild)
                    fr:SetSize(322,20)
                    fr.id=fr:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
                    fr.id:SetPoint("LEFT",fr,"LEFT",6,0)
                    fr.id:SetWidth(90)
                    fr.id:SetJustifyH("LEFT")
                    fr.theme=fr:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
                    fr.theme:SetPoint("LEFT",fr.id,"RIGHT",8,0)
                    fr.theme:SetWidth(100)
                    fr.theme:SetJustifyH("LEFT")
                    fr.name=fr:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
                    fr.name:SetPoint("LEFT",fr.theme,"RIGHT",8,0)
                    fr.name:SetWidth(100)
                    fr.name:SetJustifyH("LEFT")
                    fr._selBg = fr:CreateTexture(nil,"BACKGROUND")
                    fr._selBg:SetAllPoints()
                    fr._selBg:SetColorTexture(0.2,0.7,0.3,0.25)
                    fr._selBg:SetAlpha(0)
                    fr:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight","ADD")
                    fr:SetScript("OnClick", function(self)
                        SelectSpellOverride(self.spellID)
                    end)

                    spellRows[i]=fr
                end
                fr:SetPoint("TOPLEFT",2,cursorY)
                fr.spellID=row.spellID
                fr.themeKey=row.theme
                fr.id:SetText(tostring(row.spellID))
                fr.theme:SetText(spellThemeDrop._getLabel(row.theme))
                fr.name:SetText(row.spellName or "")
                fr:Show()
                cursorY = cursorY - 21
            end
            listChild:SetHeight(math.max(1, (#rows * 21) + 6))
            if selectedSpellID then
                SelectSpellOverride(selectedSpellID)
            end
            p:SetHeight(math.max(900, 780 + (#rows * 18)))
        end

        listEditBtn:SetScript("OnClick", function()
            if not selectedSpellID then return end
            local src = SCB.Config:Get("spellThemeOverrides") or {}
            local theme = src[selectedSpellID]
            if not theme then return end
            editSpellID=selectedSpellID
            spellIdBox:SetText(tostring(selectedSpellID))
            spellThemeKey=theme
            spellThemeDrop:SetText(spellThemeDrop._getLabel(theme))
            saveBtn:SetText("Save")
            cancelBtn:Show()
        end)

        listPreviewBtn:SetScript("OnClick", function()
            if not selectedSpellID then return end
            local src = SCB.Config:Get("spellThemeOverrides") or {}
            local theme = src[selectedSpellID]
            if theme then StartPreview(theme) end
        end)

        listRemoveBtn:SetScript("OnClick", function()
            if not selectedSpellID then return end
            OCBSpellOverrides.Remove(selectedSpellID)
            if editSpellID == selectedSpellID then ResetEditor() end
            selectedSpellID = nil
            RefreshSpellList()
        end)

        saveBtn:SetScript("OnClick", function()
            local spellID = tonumber(spellIdBox:GetText() or "")
            if not spellID or spellID <= 0 then
                statusFS:SetText("Invalid Spell ID.")
                return
            end
            if OCBSpellOverrides.Set(spellID, spellThemeKey) then
                statusFS:SetText(editSpellID and "Spell override updated." or "Spell override added.")
                ResetEditor()
                selectedSpellID = spellID
                RefreshSpellList()
            else
                statusFS:SetText("Could not save override.")
            end
        end)
        cancelBtn:SetScript("OnClick", function() ResetEditor() end)

        local function RefreshThemeAssignmentsUI()
            local enabled = SCB.Config:Get("useThemeAssignments") or false
            for _,row in ipairs(rowWidgets) do
                row.label:SetTextColor(enabled and 1 or 0.5, enabled and 1 or 0.5, enabled and 1 or 0.5)
                row.drop:SetEnabled(enabled)
                row.eye:SetEnabled(enabled)
                -- Afficher la valeur brute (peut être "none")
                local rawMap = SCB.Config:Get("themeAssignments") or {}
                local rawVal = rawMap[row.key] or "none"
                row.drop:SetText(row.drop._getLabel(rawVal))
            end
            spellIdBox:SetEnabled(enabled)
            spellThemeDrop:SetEnabled(enabled)
            saveBtn:SetEnabled(enabled)
            cancelBtn:SetEnabled(enabled)
            for _,fr in ipairs(spellRows) do
                fr:SetEnabled(enabled)
            end
            listEditBtn:SetEnabled(enabled and selectedSpellID ~= nil)
            listPreviewBtn:SetEnabled(enabled and selectedSpellID ~= nil)
            listRemoveBtn:SetEnabled(enabled and selectedSpellID ~= nil)
        end

        assignCb:SetScript("OnClick", function(self)
            SCB.Config:Set("useThemeAssignments", self:GetChecked() and true or false)
            RefreshThemeAssignmentsUI()
        end)

        -- OnShow does not fire reliably for Settings sub-panels (the frame
        -- stays parented/shown inside the canvas).  Detect visibility
        -- transitions via OnUpdate instead.  OnHide resets the flag when a
        -- parent is hidden (navigating away), so the next OnUpdate re-fires.
        local wasVisible = false
        themePanel:SetScript("OnUpdate", function(self)
            local vis = self:IsVisible()
            if vis and not wasVisible then
                assignCb:SetChecked(SCB.Config:Get("useThemeAssignments") or false)
                RefreshSpellList()
                RefreshThemeAssignmentsUI()
            end
            wasVisible = vis
        end)
        themePanel:SetScript("OnHide", function()
            wasVisible = false
        end)

        -- Expose on themePanel so RefreshThemeAssignments (outside this block) can find them.
        themePanel.assignCb = assignCb
        themePanel.RefreshSpellList = RefreshSpellList
        themePanel.RefreshThemeAssignmentsUI = RefreshThemeAssignmentsUI
    end

    -- ============================================================
    --  SHARED UI SYNC  (used by Reset and by Profiles on switch)
    -- ============================================================
    -- SyncWidgetsFromConfig: updates only the Options panel UI widgets to match the
    -- current config.  Bar-apply (scale, position, etc.) is intentionally NOT done
    -- here so that Profiles.ApplyLive() doesn't double-apply when it calls this.
    local function SyncWidgetsFromConfig()
        -- General tab widgets
        local g=contents[1]
        g.scaleSl:SetValue(SCB.Config:Get("scale"))
        g.widthSl:SetValue(SCB.Config:Get("barWidth"))
        g.lockCb:SetChecked(SCB.Config:Get("locked"))
        g.hideBlizzCb:SetChecked(SCB.Config:Get("hideBlizzardBar"))
        if g.empowerKeepCb then g.empowerKeepCb:SetChecked(SCB.Config:Get("empowerKeepDefault")) end
        g.strataDrop:SetText(g.strataDrop._getLabel(SCB.Config:Get("barStrata") or "MEDIUM"))
        g.posXSl:SetValue(SCB.Config:Get("x"))
        g.posYSl:SetValue(SCB.Config:Get("y"))

        -- Appearance tab widgets
        local a=contents[2]
        local useDetect=SCB.Config:Get("useSchoolDetection")
        a.useDetectCb:SetChecked(useDetect)
        a.useFixedCb:SetChecked(not useDetect)
        a.refreshMode()
        local ds=SCB.Config:Get("defaultSchool") or "neutral"
        local lbl=ds:sub(1,1):upper()..ds:sub(2)
        a.fixedDrop:SetText(lbl) ; a.autoDefDrop:SetText(lbl)
        if a.previewStart then a.previewStart(ds) end

        -- Text tab widgets
        local t=contents[3]._scrollChild or contents[3]
        t.showNameCb:SetChecked(SCB.Config:Get("textNameShow"))
        t.truncateCb:SetChecked(SCB.Config:Get("textNameTruncate"))
        t.nameSizeSl:SetValue(SCB.Config:Get("textNameSize") or 13)
        t.showTimerCb:SetChecked(SCB.Config:Get("textTimerShow"))
        t.timerSizeSl:SetValue(SCB.Config:Get("textTimerSize") or 13)
        t.outlineCb:SetChecked(SCB.Config:Get("textOutline") or false)
        t.centeredCb:SetChecked(SCB.Config:Get("textCentered") or false)
        t.fontDrop:SetText(t.fontDrop._getLabel(SCB.Config:Get("fontFace") or "DEFAULT"))
        local function syncRadios(radios,curKey)
            for _,r in ipairs(radios) do r:SetChecked(r.optKey==curKey) end
        end
        syncRadios(t.nameAlignRadios,  SCB.Config:Get("textNameAlign"))
        syncRadios(t.timerAlignRadios, SCB.Config:Get("textTimerAlign"))
        -- Text position sliders
        if t.namePosXSl  then t.namePosXSl:SetValue(SCB.Config:Get("textNamePosX")  or 0) end
        if t.namePosYSl  then t.namePosYSl:SetValue(SCB.Config:Get("textNamePosY")  or 0) end
        if t.timerPosXSl then t.timerPosXSl:SetValue(SCB.Config:Get("textTimerPosX") or 0) end
        if t.timerPosYSl then t.timerPosYSl:SetValue(SCB.Config:Get("textTimerPosY") or 0) end
        -- Hex color box
        if t.hexBox then
            local col=SCB.Config:Get("textCustomColor")
            if col then
                t.hexBox:SetText(string.format("%02X%02X%02X",
                    math.floor((col.r or 1)*255),
                    math.floor((col.g or 1)*255),
                    math.floor((col.b or 1)*255)))
            else
                t.hexBox:SetText("FFFFFF")
            end
        end

        if SCB.Options.RefreshThemeAssignments then SCB.Options.RefreshThemeAssignments() end
    end
    -- Expose for Profiles.lua to call after a profile switch
    SCB.Options.RefreshFromConfig = SyncWidgetsFromConfig
    SCB.Options.RefreshThemeAssignments = function()
        if themePanel and themePanel.assignCb then
            themePanel.assignCb:SetChecked(SCB.Config:Get("useThemeAssignments") or false)
        end
        if themePanel and themePanel.RefreshSpellList then themePanel.RefreshSpellList() end
        if themePanel and themePanel.RefreshThemeAssignmentsUI then themePanel.RefreshThemeAssignmentsUI() end
    end

    -- ============================================================
    --  RESET
    -- ============================================================
    resetBtn:SetScript("OnClick",function()
        SCB.Config:Reset()
        -- Apply bar-side effects (not done by SyncWidgetsFromConfig)
        SCB.Bar.frame:SetScale(SCB.Config:Get("scale"))
        SCB.Bar:Resize(SCB.Config:Get("barWidth"),SCB.Config:Get("barHeight"))
        SCB.Bar.frame:ClearAllPoints()
        SCB.Bar.frame:SetPoint(SCB.Config:Get("anchor"),UIParent,SCB.Config:Get("anchor"),
                               SCB.Config:Get("x"),SCB.Config:Get("y"))
        SCB.Bar.frame:EnableMouse(not SCB.Config:Get("locked"))
        SCB.Bar.frame:SetFrameStrata(SCB.Config:Get("barStrata") or "MEDIUM")
        if SCB.Bar.frameInner then SCB.Bar.frameInner:SetFrameStrata(SCB.Config:Get("barStrata") or "MEDIUM") end
        SCB.ApplyHideBlizzardBar(SCB.Config:Get("hideBlizzardBar"))
        SCB.Bar:ApplyTextPrefs()
        SyncWidgetsFromConfig()
        if SCB.Options.RefreshThemeAssignments then SCB.Options.RefreshThemeAssignments() end
        print("|cff00CCFFOpulent Casting Bars|r — Settings reset to defaults.")
    end)

    SelectTab(1)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local cat=Settings.RegisterCanvasLayoutCategory(panel,panel.name)
        Settings.RegisterAddOnCategory(cat)
        SCB.Options.category=cat
        local subcat=Settings.RegisterCanvasLayoutSubcategory(cat,themePanel,themePanel.name)
        Settings.RegisterAddOnCategory(subcat)
        SCB.Options.themeAssignmentsCategory=subcat
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
        InterfaceOptions_AddCategory(themePanel)
    end
    self.panel=panel
    self.themePanel=themePanel
end

function SCB.Options:Toggle()
    if Settings and Settings.OpenToCategory and SCB.Options.category then
        Settings.OpenToCategory(SCB.Options.category:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(self.panel)
        InterfaceOptionsFrame_OpenToCategory(self.panel)
    end
end
