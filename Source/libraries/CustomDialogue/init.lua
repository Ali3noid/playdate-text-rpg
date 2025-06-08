-- Import necessary modules
-- First import the state so it's available to other modules
import "libraries/CustomDialogue/state"

-- Import the DialogueBox and ChoicePopup classes directly
local DialogueBox = import "libraries/CustomDialogue/DialogueBox"
-- For ChoicePopup, we need to make sure it's properly defined
local ChoicePopupModule = import "libraries/CustomDialogue/ChoicePopup"

-- Verify imports worked
if not DialogueBox then
	print("ERROR: Failed to import DialogueBox")
end

-- Access the State object
local state = State

-- Define the main module
CustomDialogue = {}
local dialogueBox = nil

function CustomDialogue:init(config)
	dialogueBox = DialogueBox(config)
	return {
		say = function(text)
			if dialogueBox then
				dialogueBox:setText(text)
			end
		end,
		showChoice = function(choices, callback)
			print("showChoice called with choices:", table.concat(choices, ", "))
			state.isChoiceActive = true
			print("Creating ChoicePopup...")

			-- Check if the class is available
			if _G.ChoicePopup then
				local popup = _G.ChoicePopup(choices, function(choice)
					print("Choice callback triggered with choice:", choice)
					state.isChoiceActive = false
					if dialogueBox then
						dialogueBox:appendText("> " .. choice)
					end
					if callback then
						callback(choice)
					end
				end)

				if not popup then
					print("WARNING: ChoicePopup creation failed")
					state.isChoiceActive = false
					if callback then
						callback(choices[1]) -- Default to first choice
					end
				end
			else
				print("ERROR: ChoicePopup class not found in global scope")
				state.isChoiceActive = false
				if callback then
					callback(choices[1]) -- Default to first choice
				end
			end
		end,
		isTextComplete = function()
			return dialogueBox and dialogueBox.isComplete
		end,
		update = function()
			if dialogueBox and not state.isChoiceActive then
				dialogueBox:update()
				dialogueBox:draw()
			end
		end
	}
end

return CustomDialogue