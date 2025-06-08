import "libraries/Chapter"
import "libraries/ButtonManager"

local pd <const> = playdate
local gfx <const> = pd.graphics
local state = State

class('Prologue').extends(Chapter)

function Prologue:init()
	Prologue.super.init(self, {
		id = "prologue",
		title = "The Beginning"
	})
	
	-- Stan prologu
	self.state = {
		textComplete = false,
		hasMap = false,
		hasAdvice = false,
		hasTorch = false,
		gold = 5,
		gameState = "intro" -- intro, preparations, journey, return, end
	}
end

function Prologue:enter()
	-- Set up dialogue system first
	self:setupDialogue()
	self:setupButtons()
	
	-- Check if DialogueManager exists
	if DialogueManager then
		-- Pobierz tekst z DialogueManager
		local welcomeText = DialogueManager:getText("prologue", "welcome", 
			"Witaj wedrowcze. Twoja przygoda zaczyna sie w malej wiosce Debina.")
		
		-- Start prologu
		self.dialogue.say(welcomeText)
	else
		print("Warning: DialogueManager not initialized")
		-- Fallback text if DialogueManager isn't available
		self.dialogue.say("Witaj wedrowcze. Twoja przygoda zaczyna sie w malej wiosce Debina.")
	end
end

function Prologue:update()
	if not self.dialogue then
		self:setupDialogue()
	end
	
	if self.buttonManager then
		self.buttonManager:handleInput()
	end
	
	gfx.sprite.update()
	self.dialogue.update()
	
	-- Sprawdź czy zakończono wyświetlanie tekstu i czy nie jesteśmy w trakcie wyboru
	if pd.buttonJustPressed(pd.kButtonA) and 
	   not self.state.textComplete and 
	   self.dialogue.isTextComplete() and
	   not state.isChoiceActive then
		
		-- Obsługa dialogów w zależności od stanu gry
		if self.state.gameState == "intro" then
			-- Rozpocznij rozmowę z sołtysem
			local adventureText = DialogueManager and 
				DialogueManager:getText("prologue", "adventure_start") or
				"Soltys wioski prosi cie o pomoc. \"Potrzebujemy kogos odwaznego, kto uda sie do lasu i zbierze czerwone kwiaty ciernitrudu, ktore rosna w glebi lasu. To wazny skladnik lekarstw. Jestes zainteresowany?\""
			
			self.dialogue.say(adventureText)
			self.state.textComplete = true
			
			-- Pokaż wybór
			local choices = DialogueManager and 
				DialogueManager:getChoices("prologue", "choices_main_quest") or
				{"Chetnie pomoge", "Potrzebuje wiecej informacji", "To zbyt niebezpieczne"}
				
			self.dialogue.showChoice(choices, function(choice)
				if choice == choices[1] then  -- "Chętnie pomogę"
					local acceptText = DialogueManager and
						DialogueManager:getText("prologue", "accept") or
						"\"Dziekuje! To dla nas bardzo wazne. Nie kazdy mialby odwage zapuszczac sie do lasu.\""
					
					self.dialogue.say(acceptText)
					self.state.gameState = "preparations"
				elseif choice == choices[2] then  -- "Potrzebuję więcej informacji"
					local moreInfoText = DialogueManager and
						DialogueManager:getText("prologue", "more_info") or
						"\"Las bywa niebezpieczny. Sciezki sa zagmatwane, a po zmroku pojawia sie mgla. Czerwone kwiaty ciernitrudu rosna na malej polanie niedaleko starego debu. Zielarka zwykle zabierala mape, ale moglbys tez sprobowac zapytac mysliwego o wskazowki.\""
					
					self.dialogue.say(moreInfoText)
					self.state.gameState = "intro"
				else  -- "To zbyt niebezpieczne"
					local declineText = DialogueManager and
						DialogueManager:getText("prologue", "decline_retry") or
						"\"Rozumiem twoje obawy. Las bywa zdradliwy. Moze jednak przemyslisz swoja decyzje? Wioska naprawde potrzebuje pomocy.\""
					
					self.dialogue.say(declineText)
					
					-- Daj drugą szansę
					local reconsiderChoices = DialogueManager and
						DialogueManager:getChoices("prologue", "choices_reconsider") or
						{"Dobrze, pomoge wiosce", "Definitywnie odmawiam"}
						
					self.dialogue.showChoice(reconsiderChoices, function(reconsiderChoice)
						if reconsiderChoice == reconsiderChoices[1] then  -- "Dobrze, pomogę wiosce"
							local acceptAfterText = DialogueManager and
								DialogueManager:getText("prologue", "accept_after_reconsider") or
								"\"Dziekuje! Twoja pomoc jest nieoceniona.\""
								
							self.dialogue.say(acceptAfterText)
							self.state.gameState = "preparations"
						else  -- "Definitywnie odmawiam"
							local declineFinalText = DialogueManager and
								DialogueManager:getText("prologue", "decline_final") or
								"\"Szkoda, ale rozumiem. Moze znajdziemy innego smialka.\" - konczy rozmowe soltys. Wyglada na to, ze nie jestes zainteresowany ta przygoda. Moze nastepnym razem..."
								
							self.dialogue.say(declineFinalText)
							self.state.gameState = "end"
						end
					end)
				end
				self.state.textComplete = false
			end)
			
		-- Rest of the game states logic follows...
		-- For brevity, I've only included the intro state, but the same pattern would apply to the rest
		end
	end
end

return Prologue