local love = require 'love'
local utils = require 'utils'

local explosionmaxframes = 60
local missles = {}
local explosions = {}
local bases = {
    {x = 100, y = 500, ammo = 5},
    {x = 400, y = 500, ammo = 5},
    {x = 700, y = 500, ammo = 5},
}

function love.update(dt)
    for _, m in ipairs(missles) do
        local vx, vy = m.gx - m.sx, m.gy - m.sy
        local len = math.sqrt(vx^2 + vy^2)
        m.x = m.x + vx * m.speed / len
        m.y = m.y + vy * m.speed / len
        local dcurfromstart = utils.distance(m.x, m.y, m.sx, m.sy)
        local dstartfromgoal = utils.distance(m.sx, m.sy, m.gx, m.gy)
        if dcurfromstart > dstartfromgoal then
            m.exploded = true
            table.insert(explosions, {x=m.gx, y=m.gy, frames=0})
        end
    end

    for _, e in ipairs(explosions) do
        e.frames = e.frames + 1
    end

    utils.removeif(missles, function(m) return m.exploded end)
    utils.removeif(explosions, function(e) return e.frames > explosionmaxframes end)
end

local function Missle(x, y, gx, gy, s)
    return {sx=x, sy=y, x=x, y=y, gx=gx, gy=gy, speed=s}
end

local function addMissle(x, y, gx, gy, s)
    table.insert(missles, Missle(x, y, gx, gy, s))
end

local function getNearestWorkingBase(x, y)
    local dist, ret = 10^10, nil
    for _, b in ipairs(bases) do
        local d = utils.distance(b.x, b.y, x, y)
        if b.ammo > 0 and d < dist then
            dist = d
            ret = b
        end
    end
    return ret
end

local function fireMissleAt(x, y)
    local base = getNearestWorkingBase(x, y)
    if not base then return end
    base.ammo = base.ammo - 1
    addMissle(base.x, base.y, x, y, 1)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        fireMissleAt(x, y)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if scancode == 'space' then
        fireMissleAt(love.mouse.getPosition())
    end
end

function love.draw()
    for _, base in ipairs(bases) do
        love.graphics.setColor(0x0, 0xff, 0x0)
        local bw = 50
        love.graphics.rectangle('fill', base.x - bw / 2, base.y, bw, 30)
        love.graphics.setColor(0xff, 0x0, 0x0)
        love.graphics.print(base.ammo, base.x - bw / 2, base.y, 0, 2, 2)
    end

    for _, m in ipairs(missles) do
        love.graphics.setColor(0xff, 0xff, 0xff)
        love.graphics.line(m.sx, m.sy, m.x, m.y)
    end

    for _, e in ipairs(explosions) do
        local g = explosionmaxframes - e.frames
        love.graphics.setColor(0xff, 0xff, 0xff, g)
        love.graphics.circle('fill', e.x, e.y, 50)
    end
end
