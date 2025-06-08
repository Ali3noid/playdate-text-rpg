local SkillCheck = import "libraries/SkillCheck"

class('Hero').extends()

function Hero:init(name)
	self.name = name
	self.level = 1
	self.xp = 0
	self.xp_to_level = 100
	
	-- Podstawowe statystyki
	self.hp = 10
	self.max_hp = 10
	self.reroll_tokens = 3
	
	-- Atrybuty i umiejętności
	self.attributes = {
		strength = {
			value = 0,
			skills = {
				athletics = 0,
				melee = 0,
				intimidation = 0,
				resistance = 0
			}
		},
		dexterity = {
			value = 0,
			skills = {
				stealth = 0,
				ranged = 0,
				acrobatics = 0,
				thievery = 0
			}
		},
		intelligence = {
			value = 0,
			skills = {
				knowledge = 0,
				investigation = 0,
				medicine = 0,
				crafting = 0
			}
		},
		charisma = {
			value = 0,
			skills = {
				persuasion = 0,
				deception = 0,
				performance = 0,
				leadership = 0
			}
		}
	}
	
	-- Ekwipunek i przedmioty
	self.inventory = {
		equipment = {
			head = nil,
			body = nil,
			hands = nil,
			feet = nil,
			weapon = nil,
			offhand = nil
		},
		items = {},
		gold = 0
	}
	
	-- Status effects
	self.effects = {}
end

-- System rozwoju postaci
function Hero:addXP(amount)
	self.xp = self.xp + amount
	if self.xp >= self.xp_to_level then
		self:levelUp()
	end
end

function Hero:levelUp()
	self.level = self.level + 1
	self.xp = self.xp - self.xp_to_level
	self.xp_to_level = self.xp_to_level + 50
	self.max_hp = self.max_hp + 2
	self.hp = self.max_hp
	return true
end

-- Zarządzanie atrybutami i umiejętnościami
function Hero:setAttribute(attribute, value)
	if self.attributes[attribute] then
		self.attributes[attribute].value = math.max(-2, math.min(2, value))
	end
end

function Hero:setSkill(attribute, skill, value)
	if self.attributes[attribute] and self.attributes[attribute].skills[skill] then
		self.attributes[attribute].skills[skill] = math.max(0, math.min(3, value))
	end
end

function Hero:getModifier(attribute, skill)
	local attr = self.attributes[attribute]
	if not attr or not attr.skills[skill] then return 0 end
	return attr.value + attr.skills[skill]
end

-- System testów umiejętności
function Hero:skillCheck(attribute, skill, dc)
	local roll, dice = SkillCheck:roll2d6()
	local modifier = self:getModifier(attribute, skill)
	local total = roll + modifier
	local success = total >= dc
	
	return {
		success = success,
		roll = roll,
		dice = dice,
		modifier = modifier,
		total = total,
		can_reroll = self.reroll_tokens > 0
	}
end

-- Zarządzanie ekwipunkiem
function Hero:addItem(item)
	table.insert(self.inventory.items, item)
end

function Hero:removeItem(itemIndex)
	if itemIndex <= #self.inventory.items then
		return table.remove(self.inventory.items, itemIndex)
	end
	return nil
end

function Hero:equip(slot, item)
	if self.inventory.equipment[slot] then
		local old_item = self.inventory.equipment[slot]
		self.inventory.equipment[slot] = item
		return old_item
	end
	return nil
end

function Hero:unequip(slot)
	if self.inventory.equipment[slot] then
		local item = self.inventory.equipment[slot]
		self.inventory.equipment[slot] = nil
		return item
	end
	return nil
end

-- Status effects
function Hero:addEffect(effect)
	table.insert(self.effects, effect)
end

function Hero:removeEffect(effectIndex)
	if effectIndex <= #self.effects then
		return table.remove(self.effects, effectIndex)
	end
	return nil
end

-- HP Management
function Hero:heal(amount)
	self.hp = math.min(self.hp + amount, self.max_hp)
end

function Hero:damage(amount)
	self.hp = math.max(0, self.hp - amount)
	return self.hp <= 0
end

-- Reroll tokens
function Hero:useRerollToken()
	if self.reroll_tokens > 0 then
		self.reroll_tokens = self.reroll_tokens - 1
		return true
	end
	return false
end

function Hero:addRerollToken(amount)
	self.reroll_tokens = self.reroll_tokens + (amount or 1)
end

-- Character info
function Hero:getStatus()
	return {
		name = self.name,
		level = self.level,
		xp = self.xp,
		xp_to_level = self.xp_to_level,
		hp = self.hp,
		max_hp = self.max_hp,
		gold = self.inventory.gold,
		reroll_tokens = self.reroll_tokens
	}
end

return Hero