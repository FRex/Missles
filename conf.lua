function love.conf(t)
    t.window.width = 800
    t.window.height = 600
    t.window.title = 'Missles'

    t.console = false

    t.modules.joystick = false
    t.modules.physics = false
    t.modules.touch = false
    t.modules.video = false
    t.modules.thread = false
end
