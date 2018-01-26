local utils = require 'utils'
local const = require 'const'

local lib = {}
local meta = {__index = lib}

function lib.Game()
    local ret = setmetatable({}, meta)
    ret.missles = {}
    ret.explosions = {}
    local gl = const.groundlevel - const.baseheight / 2
    ret.bases = {
        {x = 100, y = gl, ammo = 5, ok = true},
        {x = 400, y = gl, ammo = 5, ok = true},
        {x = 700, y = gl, ammo = 5, ok = true},
    }
    local gl = const.groundlevel - const.townheight / 2
    ret.towns = {
        {x = 175, y = gl, ok = true},
        {x = 250, y = gl, ok = true},
        {x = 325, y = gl, ok = true},
        --middle base is here
        {x = 475, y = gl, ok = true},
        {x = 550, y = gl, ok = true},
        {x = 625, y = gl, ok = true},
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

local function Missle(x, y, gx, gy, s)
    return {sx=x, sy=y, x=x, y=y, gx=gx, gy=gy, speed=s, ok = true}
end

function lib:fireMissleAt(x, y)
    local base = self:getNearestWorkingBase(x, y)
    if not base then return false end
    base.ammo = base.ammo - 1
    table.insert(self.missles, Missle(base.x, base.y - const.baseheight / 2, x, y, const.misslespeed))
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

function lib:fireEnemyMissle()
    local targets = filterok(self.towns, {})
    targets = filterok(self.bases, targets)
    if #targets == 0 then return end
    local t = targets[math.random(1, #targets)]
    table.insert(self.missles, Missle(math.random(0, 800), 0, t.x, t.y, const.misslespeed))
end

function lib:destroyStuffInCircle(x, y, r)
    for _, c in ipairs{self.bases, self.towns, self.missles} do
        for _, o in ipairs(c) do
            if utils.distance(o.x, o.y, x, y) < r then
                o.ok = false
            end
        end
    end
end

function lib:update()
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
end

return lib
