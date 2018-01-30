local love = require 'love'
local slam = require 'slam'
local lib = {}

local filenames = {"missle", "explosion", "levelup"}

local sources = {}

for _, v in ipairs(filenames) do
    local fname = ("snd/%s.wav"):format(v)
    sources[v] = love.audio.newSource(fname, 'static')
end

local function printf(fmt, ...)
    io.stdout:write(fmt:format(...))
end

function lib.play(name)
    if not sources[name] then return end
    love.audio.play(sources[name])
end

return lib
