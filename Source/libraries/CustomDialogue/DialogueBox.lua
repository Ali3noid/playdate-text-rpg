local pd = playdate
local gfx = pd.graphics

local config = import "libraries/CustomDialogue/config"
local state = State

class('DialogueBox').extends()

function DialogueBox:init(userConfig)
	self.config = table.shallowcopy(config.DEFAULT_CONFIG)
	for k, v in pairs(userConfig or {}) do
		self.config[k] = v
	end

	self.text = ""
	self.visibleChars = 0
	self.isComplete = false
	self.speed = self.config.speed

	self.scrollPosition = 0
	self.maxScrollPosition = 0
	self.lineHeight = 16
end

function DialogueBox:setText(text)
	self.text = text
	self.visibleChars = 0
	self.isComplete = false
	self.scrollPosition = 0

	-- Oblicz maxScrollPosition dla nowego tekstu
	local textHeight = self:calculateTextHeight(text)
	self.maxScrollPosition = math.max(0, textHeight - (self.config.height - self.config.padding * 2))

	table.insert(state.history, text)
	state.currentIndex = #state.history
end

function DialogueBox:calculateTextHeight(text)
	local width = self.config.width - (self.config.padding * 2)
	local textWidth, textHeight = gfx.getTextSizeForMaxWidth(text, width)
	return textHeight
end

function DialogueBox:update()
	-- Aktualizacja prędkości na podstawie przycisku A
	local currentSpeed = self.speed
	if pd.buttonIsPressed(pd.kButtonA) then
		currentSpeed = self.speed * 3
	end

	-- Animacja tekstu
	if not self.isComplete then
		-- Aktualizuj widoczne znaki
		self.visibleChars = math.min(self.visibleChars + currentSpeed, #self.text)
		self.isComplete = self.visibleChars >= #self.text

		-- Oblicz wysokość aktualnie widocznego tekstu
		local visibleText = self.text:sub(1, math.floor(self.visibleChars))
		local currentTextHeight = self:calculateTextHeight(visibleText)

		-- Sprawdź czy tekst przekroczył wysokość okna
		local displayHeight = self.config.height - (self.config.padding * 2)
		if currentTextHeight > displayHeight then
			-- Automatycznie przewiń, aby pokazać nowy tekst
			self.scrollPosition = math.max(0, currentTextHeight - displayHeight)
		end
	end

	-- Scrollowanie tekstu korbą
	local change = pd.getCrankChange()
	if math.abs(change) > 0 and self.isComplete then
		local scrollChange = change * 2
		self.scrollPosition = math.max(0,
			math.min(self.maxScrollPosition,
				self.scrollPosition + scrollChange))
	end
end

function DialogueBox:draw()
	if state.isChoiceActive then
		return -- Nie rysuj dialogu gdy popup jest aktywny
	end
		-- Tło
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(self.config.x, self.config.y, self.config.width, self.config.height)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRect(self.config.x, self.config.y, self.config.width, self.config.height)

	-- Debug info
	local visibleText = self.text:sub(1, math.floor(self.visibleChars))
	local currentTextHeight = self:calculateTextHeight(visibleText)
	local displayHeight = self.config.height - (self.config.padding * 2)

	-- Wypisz informacje debugowe na ekranie
	-- print("Liczba znaków:", #visibleText)
	-- print("Wysokość tekstu:", currentTextHeight)
	-- print("Wysokość wyświetlania:", displayHeight)
	-- print("Pozycja scroll:", self.scrollPosition)
	-- print("Max scroll:", self.maxScrollPosition)
	-- print("Liczba linii:", select(2, string.gsub(visibleText, "\n", "")) + 1)

	-- Ustawienie clipping region dla tekstu
	gfx.setClipRect(
		self.config.x + self.config.padding,
		self.config.y + self.config.padding,
		self.config.width - (self.config.padding * 2),
		self.config.height - (self.config.padding * 2)
	)

	-- Debug - zobaczmy jaka jest rzeczywista wysokość rysowania tekstu
	local textHeight = self.config.height * 2 -- sprawdźmy czy to nie za mało
	
	-- Tekst
	gfx.drawTextInRect(
		visibleText,
		self.config.x + self.config.padding,
		self.config.y + self.config.padding - self.scrollPosition,
		self.config.width - (self.config.padding * 2),
		textHeight * 5
	)

	-- Usuwamy clipping
	gfx.clearClipRect()

	-- Pokazujemy wskaźnik przewijania tekstu jeśli jest więcej treści
	if self.maxScrollPosition > 0 and self.isComplete then
		gfx.drawText("↕", 
			self.config.x + self.config.width - 40,
			self.config.y + self.config.height - 20
		)
	end
end

function DialogueBox:setSpeed(speed)
	self.speed = speed
end

function DialogueBox:getSpeed()
	return self.speed
end

function DialogueBox:appendText(newText)
	-- Zachowaj poprzedni tekst
	local currentText = self.text
	
	-- Połącz teksty
	self.text = currentText .. "\n\n" .. newText
	
	-- Resetuj licznik widocznych znaków do długości poprzedniego tekstu
	self.visibleChars = #currentText
	self.isComplete = false
	
	-- Przelicz maxScrollPosition dla nowego tekstu
	local textHeight = self:calculateTextHeight(self.text)
	self.maxScrollPosition = math.max(0, textHeight - (self.config.height - self.config.padding * 2))
	
	-- Dodaj tylko nowy tekst do historii
	table.insert(state.history, newText)
	state.currentIndex = #state.history
end

return DialogueBox