local pd = playdate
local gfx = pd.graphics

class('ButtonManager').extends()

function ButtonManager:init()
	self.buttons = {
		{text = "Character", x = 80, y = 200, action = function() print("Character") end},
		{text = "Skills", x = 200, y = 200, action = function() print("Skills") end},
		{text = "Options", x = 320, y = 200, action = function() print("Options") end}
	}
	self.buttonSprites = {}
	self:createButtons()
end

function ButtonManager:createButtons()
	for _, button in ipairs(self.buttons) do
		local sprite = self:createButtonSprite(button.text, button.x, button.y)
		table.insert(self.buttonSprites, {
			sprite = sprite,
			action = button.action,
			bounds = {
				x1 = button.x - 50,
				x2 = button.x + 50,
				y1 = button.y - 15,
				y2 = button.y + 15
			}
		})
	end
end

function ButtonManager:createButtonSprite(text, x, y)
	local buttonWidth = 100
	local buttonHeight = 30
	local button = gfx.sprite.new()
	local buttonImage = gfx.image.new(buttonWidth, buttonHeight)
	
	gfx.pushContext(buttonImage)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(0, 0, buttonWidth, buttonHeight, 4)
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRoundRect(0, 0, buttonWidth, buttonHeight, 4)
		local font = gfx.getFont()
		local textWidth = font:getTextWidth(text)
		gfx.drawText(text, (buttonWidth - textWidth) / 2, 8)
	gfx.popContext()
	
	button:setImage(buttonImage)
	button:moveTo(x, y)
	button:add()
	return button
end

function ButtonManager:setVisible(visible)
	for _, button in ipairs(self.buttonSprites) do
		button.sprite:setVisible(visible)
	end
end

function ButtonManager:handleInput()
	if pd.buttonJustPressed(pd.kButtonB) then
		local x = pd.getCrankPosition()
		local y = 200  -- stała pozycja Y dla przycisków
		
		for _, button in ipairs(self.buttonSprites) do
			if x >= button.bounds.x1 and x <= button.bounds.x2 and
			   y >= button.bounds.y1 and y <= button.bounds.y2 then
				button.action()
				break
			end
		end
	end
end

return ButtonManager

