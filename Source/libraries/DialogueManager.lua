local pd = playdate

-- Główny obiekt menedżera dialogów
local DialogueManager = {
	languages = {"pl"},  -- Domyślnie tylko polski
	currentLanguage = "pl",
	dialogues = {}  -- Tabela przechowująca załadowane dialogi
}

-- Inicjalizacja menedżera dialogów
function DialogueManager:init(languages)
	if languages then
		self.languages = languages
	end
	self.currentLanguage = self.languages[1]

	print("DialogueManager initialized with languages:", table.concat(self.languages, ", "))

	-- Załaduj dialogi dla każdego języka
	for _, lang in ipairs(self.languages) do
		self:loadDialogues(lang)
	end

	-- Hardcoded dialogues as fallback
	-- This is used when the JSON file can't be loaded
	self.dialogues["pl"] = self.dialogues["pl"] or {}
	self.dialogues["pl"]["prologue"] = self.dialogues["pl"]["prologue"] or self:getHardcodedDialogue("pl", "prologue")

	print("Loaded hardcoded dialogues for chapter: prologue in language: pl")
end

-- Pobieranie tekstu dialogu
function DialogueManager:getText(chapter, key, default)
	if not self.dialogues[self.currentLanguage] then
		return default or key
	end

	if not self.dialogues[self.currentLanguage][chapter] then
		return default or key
	end
	
return self.dialogues[self.currentLanguage][chapter][key] or default or key
end

-- Pobieranie listy opcji wyboru
function DialogueManager:getChoices(chapter, key)
	local choices = self:getText(chapter, key)
	if type(choices) == "table" then
		return choices
	else
		-- Fallback na wypadek błędu
		return {"OK"}
	end
end

-- Zmiana języka
function DialogueManager:setLanguage(lang)
	if table.indexOfElement(self.languages, lang) then
		self.currentLanguage = lang
		return true
	end
	return false
end

-- Załadowanie dialogów z pliku JSON
function DialogueManager:loadDialogues(lang)
	self.dialogues[lang] = self.dialogues[lang] or {}

	-- Spróbuj załadować każdy rozdział gry
	local chapters = {"prologue"}  -- Lista rozdziałów do załadowania

	for _, chapter in ipairs(chapters) do
		local path = "assets/dialogues/" .. lang .. "/" .. chapter .. ".json"

		-- Spróbuj odczytać plik
		local file = pd.file.open(path)
		if file then
			local content = file:read(99999)  -- Odczytaj cały plik
			file:close()

			-- Parsuj JSON
			local success, dialogue = pcall(json.decode, content)
			if success then
				self.dialogues[lang][chapter] = dialogue
			else
				print("Error parsing dialogue file:", path)
			end
		else
			print("Error reading dialogue file:", path)
		end
	end
end

-- Hardcoded dialogues as fallback
function DialogueManager:getHardcodedDialogue(lang, chapter)
	if lang == "pl" and chapter == "prologue" then
		return {
			welcome = "Witaj wedrowcze. Twoja przygoda zaczyna sie w malej wiosce Debina, polozonej na skraju Wielkiego Lasu. Mieszkancy wioski borykaja sie z problemem - ich zapasy lekarstw koncza sie, a zielarka, ktora zwykle zbierala ziola w lesie, jest chora.",
			adventure_start = "Soltys wioski prosi cie o pomoc. \"Potrzebujemy kogos odwaznego, kto uda sie do lasu i zbierze czerwone kwiaty ciernitrudu, ktore rosna w glebi lasu. To wazny skladnik lekarstw. Jestes zainteresowany?\"",
			choices_main_quest = {
				"Chetnie pomoge", 
				"Potrzebuje wiecej informacji", 
				"To zbyt niebezpieczne"
			},
			accept = "\"Dziekuje! To dla nas bardzo wazne. Nie kazdy mialby odwage zapuszczac sie do lasu.\"",
			more_info = "\"Las bywa niebezpieczny. Sciezki sa zagmatwane, a po zmroku pojawia sie mgla. Czerwone kwiaty ciernitrudu rosna na malej polanie niedaleko starego debu. Zielarka zwykle zabierala mape, ale moglbys tez sprobowac zapytac mysliwego o wskazowki.\"",
			decline_retry = "\"Rozumiem twoje obawy. Las bywa zdradliwy. Moze jednak przemyslisz swoja decyzje? Wioska naprawde potrzebuje pomocy.\"",
			choices_reconsider = {
				"Dobrze, pomoge wiosce", 
				"Definitywnie odmawiam"
			},
			accept_after_reconsider = "\"Dziekuje! Twoja pomoc jest nieoceniona.\"",
			decline_final = "\"Szkoda, ale rozumiem. Moze znajdziemy innego smialka.\" - konczy rozmowe soltys. Wyglada na to, ze nie jestes zainteresowany ta przygoda. Moze nastepnym razem..."
		}
	end

	return {}  -- Pusty słownik dla niezdefiniowanych rozdziałów
end

return DialogueManager