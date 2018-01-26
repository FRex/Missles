local love = require 'love'
local utils = require 'utils'
local game = require'game'
local const = require 'const'

local g = game.Game()

function love.update(dt)
    g:update()
end

function love.mousepressed(x, y, button)
    if button == 1 then
        g:fireMissleAt(x, y)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if scancode == 'space' then
        g:fireMissleAt(love.mouse.getPosition())
    end

    if scancode == 'e' then
        g:fireEnemyMissle()
    end
end

function love.draw()
    for _, base in ipairs(g.bases) do
        if base.ok then
            love.graphics.setColor(0x0, 0xff, 0x0)
        else
            love.graphics.setColor(0xff, 0x0, 0x0)
        end
        local bw, bh = 50, const.baseheight
        love.graphics.rectangle('fill', base.x - bw / 2, base.y - bh / 2, bw, bh)
        love.graphics.setColor(0xff, 0x0, 0x0)
        if base.ok then
            love.graphics.print(base.ammo, base.x - bw / 2, base.y - bh / 2, 0, 2, 2)
        end
    end

    for _, town in ipairs(g.towns) do
        if town.ok then
            love.graphics.setColor(0x0, 0x0, 0xff)
        else
            love.graphics.setColor(0xff, 0x0, 0x0)
        end

        local tw, th = const.townwidth, const.townheight
        love.graphics.rectangle('fill', town.x - tw / 2, town.y - th / 2, tw, th)
    end

    love.graphics.setColor(0x33, 0x24, 0x1f)
    love.graphics.rectangle('fill', 0, const.groundlevel, 800, 10^5)

    for _, m in ipairs(g.missles) do
        love.graphics.setColor(0xff, 0xff, 0xff)
        love.graphics.line(m.sx, m.sy, m.x, m.y)
    end

    for _, e in ipairs(g.explosions) do
        local g = const.explosionmaxframes - e.frames
        love.graphics.setColor(0xff, 0xff, 0xff, g)
        love.graphics.circle('fill', e.x, e.y, const.explosionradius)
    end

    love.graphics.setColor(0x7f, 0x0, 0x0, 0x7f)
    local x, y = love.mouse.getPosition()
    love.graphics.circle('fill', x, y, const.explosionradius)
end
