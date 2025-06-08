import 'CoreLibs/graphics'
import 'CoreLibs/sprites'

import 'libraries/CustomDialogue/state'
State.reset() -- Reset state at the beginning

-- Import the DialogueManager before other modules that might use it
local DialogueManager = import 'libraries/DialogueManager'
-- Expose it globally so other modules can access it
_G.DialogueManager = DialogueManager

-- Now import other modules
import "libraries/Chapter"
import "libraries/ButtonManager"
import "libraries/SkillCheck"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- Import chapter system
local ChapterManager = import 'libraries/ChapterManager'

-- Initialize graphics
gfx.setBackgroundColor(gfx.kColorWhite)

-- Initialize the DialogueManager (with optional language support)
DialogueManager:init({'pl'}) -- You can add more languages, e.g. {"pl", "en", "de"}

-- Initialize chapter system
ChapterManager:init()
ChapterManager:changeChapter('prologue')

function playdate.update()
    ChapterManager:update()
    pd.drawFPS(0,0)
end