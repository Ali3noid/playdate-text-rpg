local SkillCheck = {
	-- Atrybuty i ich pule umiejętności
	attributes = {
		strength = {
			value = 0,  -- -2 do +2
			skills = {
				athletics = 0,      -- podnoszenie, skakanie, wspinanie
				melee = 0,         -- walka wręcz
				intimidation = 0,   -- zastraszanie
				resistance = 0      -- odporność na obrażenia i trudy
			}
		},
		dexterity = {
			value = 0,
			skills = {
				stealth = 0,        -- skradanie
				ranged = 0,         -- broń dystansowa
				acrobatics = 0,     -- akrobacje
				thievery = 0        -- kradzież kieszonkowa, otwieranie zamków
			}
		},
		intelligence = {
			value = 0,
			skills = {
				knowledge = 0,      -- wiedza ogólna
				investigation = 0,  -- rozwiązywanie zagadek
				medicine = 0,       -- leczenie
				crafting = 0        -- tworzenie przedmiotów
			}
		},
		charisma = {
			value = 0,
			skills = {
				persuasion = 0,     -- przekonywanie
				deception = 0,      -- kłamanie
				performance = 0,    -- występy
				leadership = 0      -- przewodzenie
			}
		}
	},

	difficulty = {
		very_easy = 6,
		easy = 7,
		medium = 8,
		hard = 9,
		very_hard = 10
	},

	reroll_tokens = 3,
	level = 1,
	skill_points_per_level = 1
}

function SkillCheck:roll2d6()
	local roll1 = math.random(1, 6)
	local roll2 = math.random(1, 6)
	return roll1 + roll2, {roll1, roll2}
end

function SkillCheck:getModifier(attribute, skill)
	local attr = self.attributes[attribute]
	local attributeBonus = attr.value
	local skillValue = attr.skills[skill] or 0
	return attributeBonus + skillValue
end

function SkillCheck:check(attribute, skill, dc)
	local modifier = self:getModifier(attribute, skill)
	local roll, dice_rolls = self:roll2d6()
	local total = roll + modifier
	local can_reroll = self.reroll_tokens > 0
	
	return total >= dc, roll, total, can_reroll, dice_rolls
end

function SkillCheck:setAttribute(attribute, value)
	if self.attributes[attribute] then
		self.attributes[attribute].value = math.max(-2, math.min(2, value))
	end
end

function SkillCheck:setSkill(attribute, skill, value)
	if self.attributes[attribute] and self.attributes[attribute].skills[skill] then
		self.attributes[attribute].skills[skill] = math.max(0, math.min(3, value))
	end
end

function SkillCheck:levelUp()
	self.level = self.level + 1
	return self.skill_points_per_level
end

function SkillCheck:getSkillsForAttribute(attribute)
	if self.attributes[attribute] then
		local result = {}
		for skill, value in pairs(self.attributes[attribute].skills) do
			result[skill] = value
		end
		return result
	end
	return nil
end

function SkillCheck:formatSkillCheck(attribute, skill)
	local attr = self.attributes[attribute]
	local skillValue = attr.skills[skill]
	local attrMod = attr.value >= 0 and "+" .. attr.value or attr.value
	local skillMod = skillValue >= 0 and "+" .. skillValue or skillValue
	
	return string.format("%s(%s) %s(%s)", 
		attribute:upper(), attrMod,
		skill, skillMod
	)
end

return SkillCheck