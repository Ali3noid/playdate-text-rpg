local ChapterManager = {
	currentChapter = nil,
	chapters = {},
	chapterHistory = {}
}

class('ChapterManager').extends()

function ChapterManager:init()
	-- Import all chapters
	self.chapters = {
		prologue = import "chapters/Prologue"
	}
end

function ChapterManager:changeChapter(chapterId)
	if self.currentChapter then
		self.currentChapter:exit()
		table.insert(self.chapterHistory, self.currentChapter.id)
	end

	local ChapterClass = self.chapters[chapterId]
	if ChapterClass then
		self.currentChapter = ChapterClass()
		self.currentChapter:enter()
	else
		error("Chapter " .. chapterId .. " not found!")
	end
end

function ChapterManager:update()
	if self.currentChapter then
		self.currentChapter:update()
	end
end

function ChapterManager:getCurrentChapter()
	return self.currentChapter
end

function ChapterManager:getHistory()
	return self.chapterHistory
end

return ChapterManager