-- ============================================================
--  Sleek Casting Bars — UVScroll.lua
--  Défilement UV de la texture Fill (scroll pur)
--
--  Le masque de progression est géré séparément dans Bar.lua
--  via texMask:SetWidth(). UVScroll ne fait que faire défiler
--  la texture horizontalement en boucle.
-- ============================================================

SCB.UVScroll = {}

SCB.UVScroll.tex    = nil
SCB.UVScroll.offset = 0

function SCB.UVScroll:Bind(texture)
    self.tex    = texture
    self.offset = 0
end

-- Avance le scroll
-- elapsed : secondes depuis le dernier tick
-- speed   : unités UV/seconde
-- dir     : 1 (droite) ou -1 (gauche)
function SCB.UVScroll:Update(elapsed, speed, dir)
    if not self.tex then return end
    self.offset = (self.offset + elapsed * speed * dir) % 1
    local o = self.offset
    -- SetTexCoord 8-point : décale la texture horizontalement
    self.tex:SetTexCoord(o, 0,  o, 1,  o+1, 0,  o+1, 1)
end

-- Reset (appelé au StartCast et après StopCast)
function SCB.UVScroll:Reset()
    self.offset = 0
    if self.tex then
        self.tex:SetTexCoord(0, 0,  0, 1,  1, 0,  1, 1)
    end
end
