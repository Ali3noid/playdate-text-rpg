local pd = playdate
local gfx = pd.graphics

-- Define as a global class to be accessible from other modules
class('ChoicePopup').extends(gfx.sprite)

function ChoicePopup:init(choices, callback)
	ChoicePopup.super.init(self)
	
	self.choices = choices
	self.callback = callback
	self.selectedIndex = 1
	self.font = gfx.getFont()
	self.canSelect = false
	self.buttonReleased = false
	
	-- Zwiększmy rozmiar dla lepszej widoczności
	local width = 350
	local height = (#choices * 25) + 40
	
	self.image = gfx.image.new(width, height)
	self:setImage(self.image)
	-- Wycentrujmy popup na ekranie (Playdate ma rozdzielczość 400x240)
	self:moveTo(200, 120)
	self:setZIndex(2000) -- Zwiększmy z-index
	self:add()
	
	print("ChoicePopup created and added to display")
	self:redraw()
	
	return self
end

function ChoicePopup:redraw()
	print("Redrawing ChoicePopup")
	local width, height = self.image:getSize()
	
	-- Wyczyść cały ekran przed rysowaniem popupu
	gfx.pushContext(self.image)
		-- Wyraźne tło
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, width, height)
		
		-- Gruba ramka
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRect(0, 0, width-1, height-1)
		gfx.drawRect(1, 1, width-3, height-3)
		gfx.drawRect(2, 2, width-5, height-5)
		
		-- Rysujemy opcje z większym kontrastem
		for i, choice in ipairs(self.choices) do
			local y = (i-1) * 25 + 20
			if i == self.selectedIndex then
				-- Wyraźne tło dla wybranej opcji
				gfx.fillRect(5, y-2, width-10, 20)
				gfx.setImageDrawMode(gfx.kDrawModeInverted)
				gfx.drawText(choice, width/2 - self.font:getTextWidth(choice)/2, y)
			else
				gfx.setImageDrawMode(gfx.kDrawModeCopy)
				gfx.drawText(choice, width/2 - self.font:getTextWidth(choice)/2, y)
			end
		end
	gfx.popContext()
	
	self:markDirty()
	print("ChoicePopup redrawn with dimensions:", width, "x", height)
end

function ChoicePopup:update()
	-- Czekamy na puszczenie przycisku A przed umożliwieniem wyboru
	if not self.buttonReleased and not pd.buttonIsPressed(pd.kButtonA) then
		self.buttonReleased = true
		self.canSelect = true
	end
	
	if not self.canSelect then return end
	
	if pd.buttonJustPressed(pd.kButtonUp) then
		print("Up pressed")
		self.selectedIndex = math.max(1, self.selectedIndex - 1)
		self:redraw()
	elseif pd.buttonJustPressed(pd.kButtonDown) then
		print("Down pressed")
		self.selectedIndex = math.min(#self.choices, self.selectedIndex + 1)
		self:redraw()
	elseif pd.buttonJustPressed(pd.kButtonA) then
		print("A pressed in popup")
		self.callback(self.choices[self.selectedIndex])
		self:remove()
	end
end

-- Make the class available globally
_G.ChoicePopup = ChoicePopup

-- Also return it for direct imports
return ChoicePopup