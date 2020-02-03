function love.load()
	colors = {{255,0,0}, {0,0,0}, {255,255,0}, {0,0,0}, {0,255,0}, {0,0,0}, {0,255,255}, {0,0,0}, {0,0,255}, {0,0,0}, {255,0,255}, {0,0,0}}
	index = 1
	fullscreen = false
	time = 0
	mode = "detect"
end

function love.mousepressed()
	love.mouse.setVisible(not love.mouse.isVisible())
end

function love.keypressed(key)
	if key == "f11" then
		fullscreen = not fullscreen
		love.window.setFullscreen(fullscreen)
	elseif key == "space" then
		if mode == "detect" then
			mode = "resurect"
			time = 0
		else
			mode = "detect"
			time = 0
		end
	end
end

function love.update(dt)
	time = time + dt
	if mode ~= "detect" and time > 0.2 then
		index = index + 1
		if index > #colors then
			index = 1
		end
		time = time - 0.2
	end
end

function love.draw()
	if mode == "detect" then
		local g = math.cos(time)/2 + 0.5
		love.graphics.clear(g,g,g)
	else
		love.graphics.clear(colors[index])
	end
end
