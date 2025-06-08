State = {
	history = {},
	currentIndex = 1,
	isScrolling = false,
	crankPosition = 0,
	isChoiceActive = false
}

function State.reset()
	State.history = {}
	State.currentIndex = 1
	State.isScrolling = false
	State.crankPosition = 0
	State.isChoiceActive = false
end
