local utils = require 'utils'
local const = require 'const'
local SoundBoard = require'SoundBoard'

local lib = {}
local meta = {__index = lib}

function lib.Game()
    local ret = setmetatable({}, meta)
    ret.missles = {}
    ret.tick = 0
    ret.level = 1
    ret.missleBuildup = {amount = 0, buildup = 1 / 180, levelspeedup = 1 / 1800}
    ret.explosions = {}
    ret.lost = false
    ret.score = 0
    local gl = const.groundlevel - const.baseheight / 2
    ret.bases = {
        {x = 100, y = gl, ammo = 5, ok = true, isbase = true},
        {x = 400, y = gl, ammo = 5, ok = true, isbase = true},
        {x = 700, y = gl, ammo = 5, ok = true, isbase = true},
    }

    local gl = const.groundlevel - const.townheight / 2
    ret.towns = {
        {x = 175, y = gl, ok = true, istown = true},
        {x = 250, y = gl, ok = true, istown = true},
        {x = 325, y = gl, ok = true, istown = true},
        --middle base is here
        {x = 475, y = gl, ok = true, istown = true},
        {x = 550, y = gl, ok = true, istown = true},
        {x = 625, y = gl, ok = true, istown = true},
    }

    return ret
end

function lib:getNearestWorkingBase(x, y)
    local dist, ret = 10^10, nil
    for _, b in ipairs(self.bases) do
        local d = utils.distance(b.x, b.y, x, y)
        if b.ammo > 0 and d < dist and b.ok then
            dist, ret = d, b
        end
    end
    return ret
end

local function Missle(x, y, gx, gy, s, en)
    return {sx=x, sy=y, x=x, y=y, gx=gx, gy=gy, speed=s, ok = true, enemy = en}
end

function lib:fireMissleAt(x, y)
    if self.lost then return false end
    local base = self:getNearestWorkingBase(x, y)
    if not base then return false end
    base.ammo = base.ammo - 1
    table.insert(self.missles, Missle(base.x, base.y - const.baseheight / 2, x, y, const.misslespeed, false))
    SoundBoard.play('missle')
    return true
end

local function filterok(tab, out)
    for i, v in ipairs(tab) do
        if v.ok then
            table.insert(out, v)
        end
    end
    return out
end

local function filternotok(tab, out)
    for i, v in ipairs(tab) do
        if not v.ok then
            table.insert(out, v)
        end
    end
    return out
end

function lib:fireEnemyMissle()
    local targets = filterok(self.towns, {})
    targets = filterok(self.bases, targets)
    if #targets == 0 then return end
    local t = targets[math.random(1, #targets)]
    local r = math.random(-const.misslexrand, const.misslexrand)
    table.insert(self.missles, Missle(math.random(0, 800), 0, t.x + r, t.y, const.enemymisslespeed, true))
end

function lib:destroyStuffInCircle(x, y, r)
    for _, c in ipairs{self.bases, self.towns, self.missles} do
        for _, o in ipairs(c) do
            if o.ok and utils.distance(o.x, o.y, x, y) < r then
                if o.enemy then self:addScore(10) end
                if o.isbase then self:addScore(-50) end
                if o.istown then self:addScore(-100) end
                o.ok = false
            end
        end
    end
end

local ticksperlevel = 20 * 60

local function randomelem(tab)
    if #tab == 0 then return nil end
    return tab[math.random(1, #tab)]
end

function lib:addScore(amount)
    if self.lost then return end
    self.score = math.max(0, self.score + amount)
end

function lib:update()
    self.tick = self.tick + 1
    local emb = self.missleBuildup
    emb.amount = emb.amount + emb.buildup
    while emb.amount >= 1 do
        emb.amount = emb.amount - 1
        self:fireEnemyMissle()
        local b = randomelem(filterok(self.bases, {}))
        if not self.lost and b then
            b.ammo = b.ammo + 1
        end
    end

    if not self.lost and self.tick % ticksperlevel == 0 then
        self.level = self.level + 1
        emb.buildup = emb.buildup + emb.levelspeedup
        local t = randomelem(filternotok(self.towns, {}))
        local b1 = randomelem(filterok(self.bases, {}))
        local b2 = randomelem(filternotok(self.bases, {}))
        if t then
            t.ok = true
            t.ammo = 5
        end

        if b1 then
            b1.ammo = b1.ammo + 5
        end

        if b2 then
            b2.ok = true
        end
    end

    for _, m in ipairs(self.missles) do
        local vx, vy = m.gx - m.sx, m.gy - m.sy
        local len = math.sqrt(vx^2 + vy^2)
        m.x = m.x + vx * m.speed / len
        m.y = m.y + vy * m.speed / len
        local dcurfromstart = utils.distance(m.x, m.y, m.sx, m.sy)
        local dstartfromgoal = utils.distance(m.sx, m.sy, m.gx, m.gy)
        if dcurfromstart > dstartfromgoal then
            m.ok = false
            table.insert(self.explosions, {x=m.gx, y=m.gy, frames=0})
            self:destroyStuffInCircle(m.gx, m.gy, const.explosionradius)
        end
    end

    for _, e in ipairs(self.explosions) do
        e.frames = e.frames + 1
    end

    utils.removeif(self.missles, function(m) return not m.ok end)
    utils.removeif(self.explosions, function(e) return e.frames > const.explosionmaxframes end)

    local townsokcount = #filterok(self.towns, {})
    if townsokcount == 0 then
        self.lost = true
    end
end

return lib
