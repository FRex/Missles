local utils = require 'utils'
local const = require 'const'

local lib = {}
local meta = {__index = lib}

function lib.Game()
    local ret = setmetatable({}, meta)
    ret.missles = {}
    ret.explosions = {}
    ret.bases = {
        {x = 100, y = 500, ammo = 5},
        {x = 400, y = 500, ammo = 5},
        {x = 700, y = 500, ammo = 5},
    }
    return ret
end

function lib:getNearestWorkingBase(x, y)
    local dist, ret = 10^10, nil
    for _, b in ipairs(self.bases) do
        local d = utils.distance(b.x, b.y, x, y)
        if b.ammo > 0 and d < dist then
            dist, ret = d, b
        end
    end
    return ret
end

local function Missle(x, y, gx, gy, s)
    return {sx=x, sy=y, x=x, y=y, gx=gx, gy=gy, speed=s}
end

function lib:fireMissleAt(x, y)
    local base = self:getNearestWorkingBase(x, y)
    if not base then return false end
    base.ammo = base.ammo - 1
    table.insert(self.missles, Missle(base.x, base.y, x, y, 1))
    return true
end

function lib:update()
    for _, m in ipairs(self.missles) do
        local len = utils.distance(m.gx, m.gy, m.sx, m.sy)
        assert(len1 == len, 'lens')
        m.x = m.x + vx * m.speed / len
        m.y = m.y + vy * m.speed / len
        local dcurfromstart = utils.distance(m.x, m.y, m.sx, m.sy)
        local dstartfromgoal = utils.distance(m.sx, m.sy, m.gx, m.gy)
        if dcurfromstart > dstartfromgoal then
            m.exploded = true
            table.insert(self.explosions, {x=m.gx, y=m.gy, frames=0})
        end
    end

    for _, e in ipairs(self.explosions) do
        e.frames = e.frames + 1
    end

    utils.removeif(self.missles, function(m) return m.exploded end)
    utils.removeif(self.explosions, function(e) return e.frames > const.explosionmaxframes end)
end

return lib
