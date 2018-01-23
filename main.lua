local love = require 'love'
local utils = require 'utils'
local game = require'game'

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
end

function love.draw()
    for _, base in ipairs(g.bases) do
        love.graphics.setColor(0x0, 0xff, 0x0)
        local bw = 50
        love.graphics.rectangle('fill', base.x - bw / 2, base.y, bw, 30)
        love.graphics.setColor(0xff, 0x0, 0x0)
        love.graphics.print(base.ammo, base.x - bw / 2, base.y, 0, 2, 2)
    end

    for _, m in ipairs(g.missles) do
        love.graphics.setColor(0xff, 0xff, 0xff)
        love.graphics.line(m.sx, m.sy, m.x, m.y)
    end

    for _, e in ipairs(g.explosions) do
        local g = explosionmaxframes - e.frames
        love.graphics.setColor(0xff, 0xff, 0xff, g)
        love.graphics.circle('fill', e.x, e.y, 50)
    end
end
