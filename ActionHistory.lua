-- SuperiorAnimator/src/ActionHistory.lua

local ActionHistory = {}
ActionHistory.__index = ActionHistory

function ActionHistory.new(uiElements, config)
	local self = setmetatable({}, ActionHistory)

	self.undoStack = {}
	self.redoStack = {}
	self.MAX_HISTORY = 100 -- Batasi jumlah riwayat untuk menghemat memori
	self.ui = uiElements
	self.config = config

	return self
end

function ActionHistory:updateButtonStates()
	local canUndo = #self.undoStack > 0
	local canRedo = #self.redoStack > 0
	self.ui.undoButton.TextColor3 = canUndo and self.config.Colors.TextPrimary or self.config.Colors.TextDisabled
	self.ui.redoButton.TextColor3 = canRedo and self.config.Colors.TextPrimary or self.config.Colors.TextDisabled
end

function ActionHistory:register(action)
	-- 'action' harus berupa tabel dengan fungsi 'undo' dan 'redo'
	table.insert(self.undoStack, action)

	-- Hapus riwayat tertua jika melebihi batas
	if #self.undoStack > self.MAX_HISTORY then
		table.remove(self.undoStack, 1)
	end

	-- Setiap tindakan baru akan menghapus riwayat redo
	for i = #self.redoStack, 1, -1 do
		table.remove(self.redoStack, i)
	end

	self:updateButtonStates()
end

function ActionHistory:undo()
	if #self.undoStack == 0 then
		print("Tidak ada tindakan untuk diurungkan.")
		return
	end

	local action = table.remove(self.undoStack)
	if action and action.undo then
		pcall(action.undo) -- Gunakan pcall untuk keamanan
		table.insert(self.redoStack, action)
		self:updateButtonStates()
		print("Tindakan diurungkan.")
	end
end

function ActionHistory:redo()
	if #self.redoStack == 0 then
		print("Tidak ada tindakan untuk diulangi.")
		return
	end

	local action = table.remove(self.redoStack)
	if action and action.redo then
		pcall(action.redo) -- Gunakan pcall untuk keamanan
		table.insert(self.undoStack, action)
		self:updateButtonStates()
		print("Tindakan diulangi.")
	end
end

return ActionHistory
