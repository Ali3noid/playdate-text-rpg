import "libraries/CustomDialogue/state"
import "libraries/CustomDialogue/init"
import "libraries/ButtonManager"

local pd <const> = playdate
local gfx <const> = pd.graphics
 
class('Chapter').extends()

function Chapter:init(chapterData)
	self.id = chapterData.id
	self.title = chapterData.title
	self.dialogue = nil
	self.buttonManager = nil
	self.state = {
		textComplete = false
	}
end

function Chapter:enter()
	-- Override this in specific chapters
	print("Entering chapter:", self.title)
end

function Chapter:exit()
	-- Override this in specific chapters
	print("Exiting chapter:", self.title)
end

function Chapter:update()
	-- Override this in specific chapters
end

function Chapter:setupDialogue()
	-- Initialize dialogue system
	self.dialogue = CustomDialogue:init({
		width = 380,
		height = 180,
		x = 10,
		y = 10,
		speed = 0.5
	})

	return self.dialogue
end

function Chapter:setupButtons()
	self.buttonManager = ButtonManager()

	return self.buttonManager
end