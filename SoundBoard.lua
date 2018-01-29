local love = require 'love'
local lib = {}

local filenames = {
    "missle",
}

local sources = {}

for _, v in ipairs(filenames) do
    local fname = ("snd/%s.wav"):format(v)
    print(fname)
    --sources[v] = love.audio.newSource(fname, 'static')
end

local function printf(fmt, ...)
    io.stdout:write(fmt:format(...))
end

function lib.play(name)
    printf('Sound "%s" played\n', name)
end

return lib
