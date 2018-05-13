local Lsd  = require("litespeed")

local a = Lsd(100, 0)

function love.draw()
   a.angle  = a.angle + love.timer.getDelta()
   a.length = 100 + math.sin(love.timer.getTime() * 10) * 50

   love.graphics.line(200, 200, 200 + a.x, 200 + a.y)
end