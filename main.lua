local love = require 'love'
math.random, math.randomseed = love.math.random, nil
local utils = require 'utils'
local game = require'game'
local const = require 'const'

local g = game.Game()
local state = 'game'
local font = love.graphics.newFont(const.fontfilename, 24)
love.graphics.setFont(font)


local gamecallback = {}
function gamecallback.update()
    g:update()
end

function gamecallback.mousepressed(x, y, button)
    if button == 1 then
        g:fireMissleAt(x, y)
    end

    if button == 2 then
        state = 'pause'
    end
end

function gamecallback.keypressed(key, scancode, isrepeat)
    if scancode == 'space' then
        g:fireMissleAt(love.mouse.getPosition())
    end

    if scancode == 'escape' then
        state = 'pause'
    end

    if const.dev and scancode == 'e' then
        g:fireEnemyMissle()
    end
end

function gamecallback.draw()
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
            love.graphics.print(base.ammo, base.x - bw / 2, base.y - bh / 2)
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

    for _, m in ipairs(g.missles) do
        if m.enemy then
            love.graphics.setColor(0xff, 0x0, 0x0)
        else
            love.graphics.setColor(0x00, 0xff, 0x0)
            love.graphics.circle('line', m.gx, m.gy, 5)
        end
        love.graphics.line(m.sx, m.sy, m.x, m.y)
    end

    for _, e in ipairs(g.explosions) do
        local g = const.explosionmaxframes - e.frames
        love.graphics.setColor(0xff, 0xff, 0xff, g)
        love.graphics.circle('fill', e.x, e.y, const.explosionradius)
    end

    love.graphics.setColor(0x0, 0x7f, 0x0, 0x7f)
    local x, y = love.mouse.getPosition()
    local b = g:getNearestWorkingBase(x, y)
    if b then
        love.graphics.line(b.x, b.y - const.baseheight / 2, x, y)
        love.graphics.circle('fill', x, y, const.explosionradius)
    end

    love.graphics.setColor(0x33, 0x24, 0x1f)
    love.graphics.rectangle('fill', 0, const.groundlevel, 800, 10^5)
    love.graphics.setColor(0xff, 0xff, 0xff)
    love.graphics.print('Level: ' .. g.level, 0, const.groundlevel)
end

local pausecallback = {}
function pausecallback.update()

end

function pausecallback.mousepressed(x, y, button)

end

function pausecallback.keypressed(key, scancode, isrepeat)

end

function pausecallback.draw()

end

local menucallback = {}
function menucallback.update()

end

function menucallback.mousepressed(x, y, button)

end

function menucallback.keypressed(key, scancode, isrepeat)

end

function menucallback.draw()

end

local callbacks = {
    game = gamecallback,
    pause = pausecallback,
    menu = menucallback,
}

local timesaved = 0
function love.update(dt)
    timesaved = timesaved + dt
    local steptime = 1 / 60
    while timesaved >= steptime do
        timesaved = timesaved - steptime
        callbacks[state].update(dt)
    end
end

function love.mousepressed(x, y, button)
    callbacks[state].mousepressed(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
    callbacks[state].keypressed(key, scancode, isrepeat)
end

function love.draw()
    callbacks[state].draw()
end
