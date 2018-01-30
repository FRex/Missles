local love = require 'love'
math.random, math.randomseed = love.math.random, nil
local utils = require 'utils'
local game = require'game'
local const = require 'const'

local g
local state = const.initialstate
if state ~= 'menu' then
    g = game.Game()
end

local fontsize = 24
local font = love.graphics.newFont(const.fontfilename, fontsize)
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

    if not g.lost then
        love.graphics.setColor(0x0, 0x7f, 0x0, 0x7f)
        local x, y = love.mouse.getPosition()
        local b = g:getNearestWorkingBase(x, y)
        if b then
            love.graphics.line(b.x, b.y - const.baseheight / 2, x, y)
            love.graphics.circle('fill', x, y, const.explosionradius)
        end
    end

    love.graphics.setColor(0x33, 0x24, 0x1f)
    love.graphics.rectangle('fill', 0, const.groundlevel, 800, 10^5)
    love.graphics.setColor(0xff, 0xff, 0xff)

    local texts
    if g.lost then
        texts = {"It's over.", 'You lost.', g.score .. ' points.'}
    else
        texts = {'Level: ' .. g.level, 'Score: ' .. g.score}
    end
    love.graphics.print(table.concat(texts, '\n'), 0, const.groundlevel)
end

local pausecallback = {}
function pausecallback.update() end

function pausecallback.mousepressed(x, y, button)
    if button == 1 then
        state = 'game'
    end

    if button == 2 then
        state = 'menu'
        g = nil
    end
end

function pausecallback.keypressed(key, scancode, isrepeat)
    if scancode == 'escape' then
        state = 'menu'
        g = nil
    end

    if scancode == 'space' then
        state = 'game'
    end
end

function pausecallback.draw()
    local msg = [[

Game paused!

LMB or Space to go back to game.
RMB or Escape to go back to main menu.
]]
    love.graphics.printf(msg, 0, 0, 800, 'center')
end

local menucallback = {}
function menucallback.update() end

function menucallback.mousepressed(x, y, button)
    if button == 1 then
        state = 'game'
        g = game.Game()
    end

    if buttons == 2 then
        love.event.push('quit')
    end
end

function menucallback.keypressed(key, scancode, isrepeat)
    if scancode == 'space' then
        state = 'game'
        g = game.Game()
    end

    if scancode == 'escape' then
        love.event.push('quit')
    end
end

function menucallback.draw()
    local msg = [[

Missles in Lua made using LÖVE, SLAM and sfxr!


LMB or Space to start a new game.
RMB or Escape to quit.


In-game controls:
Mouse movement to aim.
LMB or Space to shoot a missle.
RMB or Escape to pause.




Game made by FRex
for
GameDev.net 2018 New Year Challenge: Missile Command

Source code: https://github.com/FRex/Missles
]]
    love.graphics.printf(msg, 0, 0, 800, 'center')
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
