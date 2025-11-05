-- SuperiorAnimator/src/UIManager.lua

local UIManager = {}

local function getIconForProperty(propName)
	local propType = propName and propName:lower() or ""
	if propType:find("color") then
		return "rbxassetid://121985538" -- Color wheel icon
	elseif propType:find("position") then
		return "rbxassetid://121985566" -- Position icon
	elseif propType:find("size") then
		return "rbxassetid://121985583" -- Size icon
	elseif propType:find("rotation") or propType:find("orientation") then
		return "rbxassetid://121985596" -- Rotation icon
	elseif propType:find("transparency") then
		return "rbxassetid://121985610" -- Transparency icon
	else
		return ""
	end
end
UIManager.getIconForProperty = getIconForProperty


function UIManager.create(parentWidget, Config)
	-- Fungsi ini HANYA membuat dan mengembalikan elemen-elemen UI.
	-- Semua logika perilaku (event) akan dihubungkan di luar fungsi ini.

	-- === STRUKTUR UI ===
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = Config.Colors.MainBackground
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = parentWidget

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = mainFrame

	local function addCorner(parent)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = parent
	end

	-- TOP BAR --
	local topBarFrame = Instance.new("Frame")
	topBarFrame.Name = "TopBar"
	topBarFrame.Size = UDim2.new(1, 0, 0, 36)
	topBarFrame.BackgroundColor3 = Config.Colors.TopBarBackground
	topBarFrame.BorderSizePixel = 0
	topBarFrame.Parent = mainFrame

	local buttonContainer = Instance.new("Frame")
	buttonContainer.Name = "ButtonContainer"
	buttonContainer.Size = UDim2.new(0, 1110, 1, 0) -- Fixed size to contain all buttons
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = topBarFrame

	local topBarLayout = Instance.new("UIListLayout")
	topBarLayout.FillDirection = Enum.FillDirection.Horizontal
	topBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	topBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	topBarLayout.Padding = UDim.new(0, 5)
	topBarLayout.Parent = buttonContainer

	local saveButton = Instance.new("TextButton")
	saveButton.Name = "SaveButton"
	saveButton.Size = UDim2.new(0, 50, 0, 28)
	saveButton.Text = "💾"
	saveButton.BackgroundColor3 = Config.Colors.ButtonPrimary
	saveButton.TextColor3 = Config.Colors.TextPrimary
	saveButton.Font = Enum.Font.SourceSansBold
	saveButton.TextSize = 14
	saveButton.LayoutOrder = 1
	saveButton.Parent = buttonContainer
	addCorner(saveButton)

	local loadButton = Instance.new("TextButton")
	loadButton.Name = "LoadButton"
	loadButton.Size = UDim2.new(0, 50, 0, 28)
	loadButton.Text = "📂"
	loadButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	loadButton.TextColor3 = Config.Colors.TextPrimary
	loadButton.Font = Enum.Font.SourceSansBold
	loadButton.TextSize = 14
	loadButton.LayoutOrder = 2
	loadButton.Parent = buttonContainer
	addCorner(loadButton)

	local exportButton = Instance.new("TextButton")
	exportButton.Name = "ExportButton"
	exportButton.Size = UDim2.new(0, 60, 0, 28)
	exportButton.Text = "📤"
	exportButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	exportButton.TextColor3 = Config.Colors.TextPrimary
	exportButton.Font = Enum.Font.SourceSansBold
	exportButton.TextSize = 14
	exportButton.LayoutOrder = 3
	exportButton.Parent = buttonContainer
	addCorner(exportButton)

	local clearAllButton = Instance.new("TextButton")
	clearAllButton.Name = "ClearAllButton"
	clearAllButton.Size = UDim2.new(0, 50, 0, 28)
	clearAllButton.Text = "🗑️"
	clearAllButton.BackgroundColor3 = Config.Colors.ButtonDanger
	clearAllButton.TextColor3 = Config.Colors.TextPrimary
	clearAllButton.Font = Enum.Font.SourceSansBold
	clearAllButton.TextSize = 14
	clearAllButton.LayoutOrder = 4
	clearAllButton.Parent = buttonContainer
	addCorner(clearAllButton)

	local separator1 = Instance.new("Frame")
	separator1.Size = UDim2.new(0, 1, 0, 28)
	separator1.BackgroundColor3 = Config.Colors.Separator
	separator1.LayoutOrder = 5
	separator1.Parent = buttonContainer

	local undoButton = Instance.new("TextButton")
	undoButton.Name = "UndoButton"
	undoButton.Size = UDim2.new(0, 50, 0, 28)
	undoButton.Text = "↩️"
	undoButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	undoButton.TextColor3 = Config.Colors.TextDisabled -- Dimulai sebagai nonaktif
	undoButton.Font = Enum.Font.SourceSansBold
	undoButton.TextSize = 14
	undoButton.LayoutOrder = 6
	undoButton.Parent = buttonContainer
	addCorner(undoButton)

	local redoButton = Instance.new("TextButton")
	redoButton.Name = "RedoButton"
	redoButton.Size = UDim2.new(0, 50, 0, 28)
	redoButton.Text = "↪️"
	redoButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	redoButton.TextColor3 = Config.Colors.TextDisabled -- Dimulai sebagai nonaktif
	redoButton.Font = Enum.Font.SourceSansBold
	redoButton.TextSize = 14
	redoButton.LayoutOrder = 7
	redoButton.Parent = buttonContainer
	addCorner(redoButton)

	local separator2 = Instance.new("Frame")
	separator2.Size = UDim2.new(0, 1, 0, 28)
	separator2.BackgroundColor3 = Config.Colors.Separator
	separator2.LayoutOrder = 8
	separator2.Parent = buttonContainer

	local playButton = Instance.new("TextButton")
	playButton.Name = "PlayButton"
	playButton.Size = UDim2.new(0, 50, 0, 28)
	playButton.Text = "▶️"
	playButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	playButton.TextColor3 = Config.Colors.TextPrimary
	playButton.Font = Enum.Font.SourceSansBold
	playButton.TextSize = 14
	playButton.LayoutOrder = 9
	playButton.Parent = buttonContainer
	addCorner(playButton)

	local stopButton = Instance.new("TextButton")
	stopButton.Name = "StopButton"
	stopButton.Size = UDim2.new(0, 50, 0, 28)
	stopButton.Text = "⏹️"
	stopButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	stopButton.TextColor3 = Config.Colors.TextPrimary
	stopButton.Font = Enum.Font.SourceSansBold
	stopButton.TextSize = 14
	stopButton.LayoutOrder = 10
	stopButton.Parent = buttonContainer
	addCorner(stopButton)

	local speedDropdown = Instance.new("TextButton")
	speedDropdown.Name = "SpeedDropdown"
	speedDropdown.Size = UDim2.new(0, 60, 0, 28)
	speedDropdown.Text = "1x"
	speedDropdown.BackgroundColor3 = Config.Colors.ButtonSecondary
	speedDropdown.TextColor3 = Config.Colors.TextPrimary
	speedDropdown.Font = Enum.Font.SourceSansBold
	speedDropdown.TextSize = 14
	speedDropdown.LayoutOrder = 11
	speedDropdown.Parent = buttonContainer
	addCorner(speedDropdown)

	local loopButton = Instance.new("TextButton")
	loopButton.Name = "LoopButton"
	loopButton.Size = UDim2.new(0, 28, 0, 28)
	loopButton.Text = "🔁" -- Loop symbol
	loopButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	loopButton.TextColor3 = Config.Colors.TextPrimary
	loopButton.Font = Enum.Font.SourceSansBold
	loopButton.TextSize = 16
	loopButton.LayoutOrder = 12
	loopButton.Parent = buttonContainer
	addCorner(loopButton)

	local zoomOutButton = Instance.new("TextButton")
	zoomOutButton.Name = "ZoomOutButton"
	zoomOutButton.Size = UDim2.new(0, 28, 0, 28)
	zoomOutButton.Text = "-"
	zoomOutButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	zoomOutButton.TextColor3 = Config.Colors.TextPrimary
	zoomOutButton.Font = Enum.Font.SourceSansBold
	zoomOutButton.TextSize = 20
	zoomOutButton.LayoutOrder = 13
	zoomOutButton.Parent = buttonContainer
	addCorner(zoomOutButton)

	local zoomInButton = Instance.new("TextButton")
	zoomInButton.Name = "ZoomInButton"
	zoomInButton.Size = UDim2.new(0, 28, 0, 28)
	zoomInButton.Text = "+"
	zoomInButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	zoomInButton.TextColor3 = Config.Colors.TextPrimary
	zoomInButton.Font = Enum.Font.SourceSansBold
	zoomInButton.TextSize = 20
	zoomInButton.LayoutOrder = 14
	zoomInButton.Parent = buttonContainer
	addCorner(zoomInButton)

	local timelineLengthLabel = Instance.new("TextLabel")
	timelineLengthLabel.Name = "TimelineLengthLabel"
	timelineLengthLabel.Size = UDim2.new(0, 100, 0, 28)
	timelineLengthLabel.Text = "Panjang Timeline:"
	timelineLengthLabel.Font = Enum.Font.SourceSans
	timelineLengthLabel.TextSize = 14
	timelineLengthLabel.TextColor3 = Config.Colors.TextMuted
	timelineLengthLabel.BackgroundTransparency = 1
	timelineLengthLabel.TextXAlignment = Enum.TextXAlignment.Right
	timelineLengthLabel.LayoutOrder = 15
	timelineLengthLabel.Parent = buttonContainer

	local timelineLengthInput = Instance.new("TextBox")
	timelineLengthInput.Name = "TimelineLengthInput"
	timelineLengthInput.Size = UDim2.new(0, 60, 0, 28)
	timelineLengthInput.Text = "240"
	timelineLengthInput.Font = Enum.Font.SourceSans
	timelineLengthInput.TextSize = 14
	timelineLengthInput.BackgroundColor3 = Config.Colors.InputBackground
	timelineLengthInput.TextColor3 = Config.Colors.TextPrimary
	timelineLengthInput.LayoutOrder = 16
	timelineLengthInput.Parent = buttonContainer
	addCorner(timelineLengthInput)

	local separator3 = Instance.new("Frame")
	separator3.Size = UDim2.new(0, 1, 0, 28)
	separator3.BackgroundColor3 = Config.Colors.Separator
	separator3.LayoutOrder = 17
	separator3.Parent = buttonContainer

	local addObjectButton = Instance.new("TextButton")
	addObjectButton.Name = "AddObjectButton"
	addObjectButton.Size = UDim2.new(0, 100, 0, 28)
	addObjectButton.Text = "Tambah Objek"
	addObjectButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	addObjectButton.TextColor3 = Config.Colors.TextPrimary
	addObjectButton.Font = Enum.Font.SourceSansBold
	addObjectButton.TextSize = 14
	addObjectButton.LayoutOrder = 18
	addObjectButton.Parent = buttonContainer
	addCorner(addObjectButton)

	local addCameraButton = Instance.new("TextButton")
	addCameraButton.Name = "AddCameraButton"
	addCameraButton.Size = UDim2.new(0, 100, 0, 28)
	addCameraButton.Text = "Add Camera"
	addCameraButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	addCameraButton.TextColor3 = Config.Colors.TextPrimary
	addCameraButton.Font = Enum.Font.SourceSansBold
	addCameraButton.TextSize = 14
	addCameraButton.LayoutOrder = 19
	addCameraButton.Parent = buttonContainer
	addCorner(addCameraButton)

	local cameraLockButton = Instance.new("TextButton")
	cameraLockButton.Name = "CameraLockButton"
	cameraLockButton.Size = UDim2.new(0, 28, 0, 28)
	cameraLockButton.Text = "📹"
	cameraLockButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	cameraLockButton.TextColor3 = Config.Colors.TextPrimary
	cameraLockButton.Font = Enum.Font.SourceSansBold
	cameraLockButton.TextSize = 16
	cameraLockButton.LayoutOrder = 20
	cameraLockButton.Parent = buttonContainer
	addCorner(cameraLockButton)

	local addKeyframeButton = Instance.new("TextButton")
	addKeyframeButton.Name = "AddKeyframeButton"
	addKeyframeButton.Size = UDim2.new(0, 28, 0, 28)
	addKeyframeButton.Text = "+"
	addKeyframeButton.Font = Enum.Font.SourceSansBold
	addKeyframeButton.TextSize = 24
	addKeyframeButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	addKeyframeButton.TextColor3 = Config.Colors.TextPrimary
	addKeyframeButton.LayoutOrder = 21
	addKeyframeButton.Parent = buttonContainer
	addCorner(addKeyframeButton)

	local autoKeyButton = Instance.new("TextButton")
	autoKeyButton.Name = "AutoKeyButton"
	autoKeyButton.Size = UDim2.new(0, 50, 0, 28)
	autoKeyButton.Text = "Auto"
	autoKeyButton.BackgroundColor3 = Config.Colors.ButtonSecondary -- Warna default (non-aktif)
	autoKeyButton.TextColor3 = Config.Colors.TextPrimary
	autoKeyButton.Font = Enum.Font.SourceSansBold
	autoKeyButton.TextSize = 14
	autoKeyButton.LayoutOrder = 22
	autoKeyButton.Parent = buttonContainer
	addCorner(autoKeyButton)

	local separator4 = Instance.new("Frame")
	separator4.Size = UDim2.new(0, 1, 0, 28)
	separator4.BackgroundColor3 = Config.Colors.Separator
	separator4.LayoutOrder = 23
	separator4.Parent = buttonContainer

	local viewToggleButton = Instance.new("TextButton")
	viewToggleButton.Name = "ViewToggleButton"
	viewToggleButton.Size = UDim2.new(0, 120, 0, 28)
	viewToggleButton.Text = "Graph Editor"
	viewToggleButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	viewToggleButton.TextColor3 = Config.Colors.TextPrimary
	viewToggleButton.Font = Enum.Font.SourceSansBold
	viewToggleButton.TextSize = 14
	viewToggleButton.LayoutOrder = 25
	viewToggleButton.Parent = buttonContainer
	addCorner(viewToggleButton)

	local selectedObjectLabel = Instance.new("TextLabel")
	selectedObjectLabel.Name = "SelectedObjectLabel"
	selectedObjectLabel.AnchorPoint = Vector2.new(1, 0.5)
	selectedObjectLabel.Position = UDim2.new(1, -10, 0.5, 0)
	selectedObjectLabel.Size = UDim2.new(0, 250, 1, 0)
	selectedObjectLabel.Font = Enum.Font.SourceSans
	selectedObjectLabel.TextSize = 14
	selectedObjectLabel.TextColor3 = Config.Colors.TextMuted
	selectedObjectLabel.BackgroundTransparency = 1
	selectedObjectLabel.TextXAlignment = Enum.TextXAlignment.Right
	selectedObjectLabel.Text = "Tidak ada objek yang dipilih"
	selectedObjectLabel.Parent = topBarFrame


	-- MAIN CONTENT --
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 1, -36)
	contentFrame.Position = UDim2.new(0, 0, 0, 36)
	contentFrame.BackgroundTransparency = 1
	contentFrame.BorderSizePixel = 0
	contentFrame.Parent = mainFrame

	-- PROPERTIES PANEL --
	local propertiesFrame = Instance.new("Frame")
	propertiesFrame.Name = "Properties"
	propertiesFrame.Size = UDim2.new(0, 250, 1, 0)
	propertiesFrame.Position = UDim2.new(1, -250, 0, 0)
	propertiesFrame.BackgroundColor3 = Config.Colors.PropertiesBackground
	propertiesFrame.BorderSizePixel = 0
	propertiesFrame.Parent = contentFrame

	local collapseButton = Instance.new("TextButton")
	collapseButton.Name = "CollapseButton"
	collapseButton.Size = UDim2.new(0, 20, 0, 40)
	collapseButton.Position = UDim2.new(0, -20, 0.5, -20)
	collapseButton.Text = "<"
	collapseButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	collapseButton.TextColor3 = Config.Colors.TextPrimary
	collapseButton.Font = Enum.Font.SourceSansBold
	collapseButton.TextSize = 18
	collapseButton.Parent = propertiesFrame
	addCorner(collapseButton)

	local propertyLayout = Instance.new("UIListLayout")
	propertyLayout.Padding = UDim.new(0, 5)
	propertyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	propertyLayout.Parent = propertiesFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -10, 0, 20)
	titleLabel.Position = UDim2.new(0, 5, 0, 5)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.Text = "Properti Keyframe"
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Config.Colors.TextSecondary
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.LayoutOrder = 1
	titleLabel.Parent = propertiesFrame

	local function createPropertyDisplay(name, order)
		local holder = Instance.new("Frame")
		holder.Name = name .. "Holder"
		holder.Size = UDim2.new(1, -10, 0, 20)
		holder.Position = UDim2.new(0, 5, 0, 0)
		holder.BackgroundTransparency = 1
		holder.LayoutOrder = order
		holder.Parent = propertiesFrame

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = name .. "Label"
		nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
		nameLabel.Font = Enum.Font.SourceSans
		nameLabel.Text = name
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = Config.Colors.TextDisabled
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = holder

		local valueBox = Instance.new("TextBox")
		valueBox.Name = name .. "Value"
		valueBox.Size = UDim2.new(0.6, 0, 1, 0)
		valueBox.Position = UDim2.new(0.4, 0, 0, 0)
		valueBox.Font = Enum.Font.SourceSans
		valueBox.Text = "-.--"
		valueBox.TextSize = 14
		valueBox.TextColor3 = Config.Colors.TextPrimary
		valueBox.BackgroundColor3 = Config.Colors.InputBackground
		valueBox.TextXAlignment = Enum.TextXAlignment.Right
		valueBox.Parent = holder

		return valueBox, holder, nameLabel
	end

	local genericPropName, genericPropHolder, genericPropNameLabel = createPropertyDisplay("Property", 2)
	local genericPropValueX, genericPropValueXHolder = createPropertyDisplay("  - X", 3)
	local genericPropValueY, genericPropValueYHolder = createPropertyDisplay("  - Y", 4)
	local genericPropValueZ, genericPropValueZHolder = createPropertyDisplay("  - Z", 5)

	local posLabel, posHolder = createPropertyDisplay("Position", 6)
	local posX, posXHolder = createPropertyDisplay("  - X", 7)
	local posY, posYHolder = createPropertyDisplay("  - Y", 8)
	local posZ, posZHolder = createPropertyDisplay("  - Z", 9)

	local rotLabel, rotHolder = createPropertyDisplay("Rotation", 10)
	local rotX, rotXHolder = createPropertyDisplay("  - X", 11)
	local rotY, rotYHolder = createPropertyDisplay("  - Y", 12)
	local rotZ, rotZHolder = createPropertyDisplay("  - Z", 13)

	-- New Color Picker Swatch
	local colorHolder = Instance.new("Frame")
	colorHolder.Name = "ColorHolder"
	colorHolder.Size = UDim2.new(1, -10, 0, 20)
	colorHolder.Position = UDim2.new(0, 5, 0, 0)
	colorHolder.BackgroundTransparency = 1
	colorHolder.LayoutOrder = 14
	colorHolder.Parent = propertiesFrame

	local colorNameLabel = Instance.new("TextLabel")
	colorNameLabel.Name = "ColorLabel"
	colorNameLabel.Size = UDim2.new(0.4, 0, 1, 0)
	colorNameLabel.Font = Enum.Font.SourceSans
	colorNameLabel.Text = "Color"
	colorNameLabel.TextSize = 14
	colorNameLabel.TextColor3 = Config.Colors.TextDisabled
	colorNameLabel.BackgroundTransparency = 1
	colorNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	colorNameLabel.Parent = colorHolder

	local colorSwatch = Instance.new("TextButton")
	colorSwatch.Name = "ColorSwatch"
	colorSwatch.Size = UDim2.new(0.6, 0, 1, 0)
	colorSwatch.Position = UDim2.new(0.4, 0, 0, 0)
	colorSwatch.Text = ""
	colorSwatch.BackgroundColor3 = Color3.new(1, 1, 1)
	colorSwatch.BorderColor3 = Config.Colors.Border
	colorSwatch.Parent = colorHolder


	local udim2Label, udim2Holder = createPropertyDisplay("UDim2", 18)
	local udim2XS, udim2XSHolder = createPropertyDisplay("  - X Scale", 19)
	local udim2XO, udim2XOHolder = createPropertyDisplay("  - X Offset", 20)
	local udim2YS, udim2YSHolder = createPropertyDisplay("  - Y Scale", 21)
	local udim2YO, udim2YOHolder = createPropertyDisplay("  - Y Offset", 22)

	-- New Boolean Checkbox
	local boolHolder = Instance.new("Frame")
	boolHolder.Name = "BoolHolder"
	boolHolder.Size = UDim2.new(1, -10, 0, 20)
	boolHolder.Position = UDim2.new(0, 5, 0, 0)
	boolHolder.BackgroundTransparency = 1
	boolHolder.LayoutOrder = 23
	boolHolder.Parent = propertiesFrame

	local boolNameLabel = Instance.new("TextLabel")
	boolNameLabel.Name = "BoolLabel"
	boolNameLabel.Size = UDim2.new(0.4, 0, 1, 0)
	boolNameLabel.Font = Enum.Font.SourceSans
	boolNameLabel.Text = "Value"
	boolNameLabel.TextSize = 14
	boolNameLabel.TextColor3 = Config.Colors.TextDisabled
	boolNameLabel.BackgroundTransparency = 1
	boolNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	boolNameLabel.Parent = boolHolder

	local boolCheckbox = Instance.new("TextButton")
	boolCheckbox.Name = "BoolCheckbox"
	boolCheckbox.Size = UDim2.new(0, 20, 0, 20)
	boolCheckbox.Position = UDim2.new(0.4, 0, 0, 0)
	boolCheckbox.Font = Enum.Font.SourceSansBold
	boolCheckbox.Text = "✓"
	boolCheckbox.TextSize = 14
	boolCheckbox.TextColor3 = Config.Colors.TextPrimary
	boolCheckbox.BackgroundColor3 = Config.Colors.InputBackground
	boolCheckbox.Parent = boolHolder

	local easingButton = Instance.new("TextButton")
	easingButton.Name = "EasingButton"
	easingButton.Size = UDim2.new(1, -10, 0, 24)
	easingButton.Position = UDim2.new(0, 5, 0, 0)
	easingButton.BackgroundColor3 = Config.Colors.Separator
	easingButton.TextColor3 = Config.Colors.TextPrimary
	easingButton.Font = Enum.Font.SourceSans
	easingButton.TextSize = 14
	easingButton.Text = "Easing: Linear"
	easingButton.LayoutOrder = 24
	easingButton.Visible = false
	easingButton.Parent = propertiesFrame

	local easingMenu = Instance.new("ScrollingFrame")
	easingMenu.Name = "EasingMenu"
	easingMenu.Visible = false
	easingMenu.Size = UDim2.new(1, -10, 0, 150)
	easingMenu.Position = UDim2.new(0, 5, 0, 0) -- Akan disesuaikan saat ditampilkan
	easingMenu.BackgroundColor3 = Config.Colors.TrackBackground
	easingMenu.BorderColor3 = Config.Colors.Border
	easingMenu.ScrollBarThickness = 5
	easingMenu.LayoutOrder = 25 -- Setelah tombol easing
	easingMenu.ZIndex = 11
	easingMenu.Parent = propertiesFrame

	local deleteKeyframeButton = Instance.new("TextButton")
	deleteKeyframeButton.Name = "DeleteKeyframeButton"
	deleteKeyframeButton.Size = UDim2.new(1, -10, 0, 28)
	deleteKeyframeButton.Text = "Hapus Keyframe"
	deleteKeyframeButton.BackgroundColor3 = Config.Colors.ButtonDanger
	deleteKeyframeButton.TextColor3 = Config.Colors.TextPrimary
	deleteKeyframeButton.Font = Enum.Font.SourceSansBold
	deleteKeyframeButton.TextSize = 14
	deleteKeyframeButton.LayoutOrder = 26 -- After the easing menu
	deleteKeyframeButton.Visible = false
	deleteKeyframeButton.Parent = propertiesFrame

	local placeholderLabel = Instance.new("TextLabel")
	placeholderLabel.Name = "PlaceholderLabel"
	placeholderLabel.Size = UDim2.new(1, -10, 1, -80)
	placeholderLabel.Position = UDim2.new(0, 5, 0, 40)
	placeholderLabel.Font = Enum.Font.SourceSansItalic
	placeholderLabel.Text = "Pilih sebuah keyframe untuk melihat propertinya."
	placeholderLabel.TextSize = 14
	placeholderLabel.TextColor3 = Config.Colors.TextMuted
	placeholderLabel.BackgroundTransparency = 1
	placeholderLabel.TextWrapped = true
	placeholderLabel.TextYAlignment = Enum.TextYAlignment.Top
	placeholderLabel.LayoutOrder = 27
	placeholderLabel.Visible = true -- Tampil secara default
	placeholderLabel.Parent = propertiesFrame

	local easingMenuLayout = Instance.new("UIListLayout")
	easingMenuLayout.Padding = UDim.new(0, 2)
	easingMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
	easingMenuLayout.Parent = easingMenu

	-- TIMELINE --
	local timelineContainer = Instance.new("Frame")
	timelineContainer.Name = "TimelineContainer"
	timelineContainer.Size = UDim2.new(1, -250, 1, 0)
	timelineContainer.BackgroundColor3 = Config.Colors.ContentBackground
	timelineContainer.BorderSizePixel = 0
	timelineContainer.ClipsDescendants = true
	timelineContainer.Parent = contentFrame

	local trackListFrame = Instance.new("ScrollingFrame")
	trackListFrame.Name = "TrackList"
	trackListFrame.Size = UDim2.new(0, 200, 1, -24)
	trackListFrame.Position = UDim2.new(0, 0, 0, 24)
	trackListFrame.BackgroundColor3 = Config.Colors.TrackListBackground
	trackListFrame.BorderSizePixel = 0
	trackListFrame.ScrollBarThickness = 6
	trackListFrame.Parent = timelineContainer

	local trackListLayout = Instance.new("UIListLayout")
	trackListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	trackListLayout.Parent = trackListFrame

	local keyframeAreaFrame = Instance.new("ScrollingFrame")
	keyframeAreaFrame.Name = "KeyframeArea"
	keyframeAreaFrame.Size = UDim2.new(1, -200, 1, 0)
	keyframeAreaFrame.Position = UDim2.new(0, 200, 0, 0)
	keyframeAreaFrame.BackgroundColor3 = Config.Colors.ContentBackground
	keyframeAreaFrame.BorderSizePixel = 0
	keyframeAreaFrame.ScrollBarThickness = 6
	keyframeAreaFrame.ScrollingDirection = Enum.ScrollingDirection.XY
	keyframeAreaFrame.Parent = timelineContainer

	local timelineRuler = Instance.new("Frame")
	timelineRuler.Name = "Ruler"
	timelineRuler.Size = UDim2.new(0, 50000, 0, 24) -- Lebar statis yang sangat besar
	timelineRuler.BackgroundColor3 = Config.Colors.PropertiesBackground
	timelineRuler.BorderSizePixel = 0
	timelineRuler.Parent = keyframeAreaFrame

	local keyframeTracksContainer = Instance.new("Frame")
	keyframeTracksContainer.Name = "KeyframeTracksContainer"
	keyframeTracksContainer.Size = UDim2.new(5, 0, 1, -24)
	keyframeTracksContainer.Position = UDim2.new(0, 0, 0, 24)
	keyframeTracksContainer.BackgroundTransparency = 1
	keyframeTracksContainer.Parent = keyframeAreaFrame

	local keyframeTracksLayout = Instance.new("UIListLayout")
	keyframeTracksLayout.SortOrder = Enum.SortOrder.LayoutOrder
	keyframeTracksLayout.Parent = keyframeTracksContainer

	-- GRAPH EDITOR PANEL --
	local graphEditorFrame = Instance.new("Frame")
	graphEditorFrame.Name = "GraphEditorFrame"
	graphEditorFrame.Size = UDim2.new(1, 0, 1, -24)
	graphEditorFrame.Position = UDim2.new(0, 0, 0, 24)
	graphEditorFrame.BackgroundColor3 = Config.Colors.ContentBackground
	graphEditorFrame.BorderSizePixel = 0
	graphEditorFrame.Visible = false -- Sembunyikan secara default
	graphEditorFrame.ClipsDescendants = true
	graphEditorFrame.Parent = keyframeAreaFrame

	local graphCanvas = Instance.new("Frame")
	graphCanvas.Name = "GraphCanvas"
	graphCanvas.Size = UDim2.new(1, 0, 1, 0)
	graphCanvas.BackgroundTransparency = 1
	graphCanvas.Parent = graphEditorFrame

	for i = 0, 200 do -- Perpanjang ruler awal
		local position = i * Config.PIXELS_PER_FRAME_INTERVAL
		local frameNumber = i * Config.FRAMES_PER_INTERVAL
		local timeInSeconds = frameNumber / Config.FRAMES_PER_SECOND

		local marker = Instance.new("Frame")
		marker.Size = UDim2.new(0, 1, 1, 0)
		marker.Position = UDim2.new(0, position, 0, 0)
		marker.BackgroundColor3 = Config.Colors.Separator
		marker.BorderSizePixel = 0
		marker.Parent = timelineRuler

		local frameLabel = Instance.new("TextLabel")
		frameLabel.Size = UDim2.new(0, 50, 0, 12)
		frameLabel.Position = UDim2.new(0, 3, 0, 0)
		frameLabel.Text = tostring(frameNumber)
		frameLabel.Font = Enum.Font.SourceSans
		frameLabel.TextSize = 10
		frameLabel.TextColor3 = Config.Colors.TextDisabled
		frameLabel.BackgroundTransparency = 1
		frameLabel.TextXAlignment = Enum.TextXAlignment.Left
		frameLabel.Parent = marker

		-- Hanya tampilkan label waktu pada interval yang signifikan
		if i % 2 == 0 and i > 0 then
			local timeLabel = Instance.new("TextLabel")
			timeLabel.Size = UDim2.new(0, 50, 0, 12)
			timeLabel.Position = UDim2.new(0, 3, 0, 12)
			timeLabel.Text = string.format("%.1fs", timeInSeconds)
			timeLabel.Font = Enum.Font.SourceSans
			timeLabel.TextSize = 10
			timeLabel.TextColor3 = Config.Colors.TextMuted
			timeLabel.BackgroundTransparency = 1
			timeLabel.TextXAlignment = Enum.TextXAlignment.Left
			timeLabel.Parent = marker
		end
	end

	local playhead = Instance.new("Frame")
	playhead.Name = "Playhead"
	playhead.Size = UDim2.new(0, 2, 1, 0)
	playhead.Position = UDim2.new(0, 50, 0, 0)
	playhead.BackgroundColor3 = Config.Colors.Playhead
	playhead.BorderSizePixel = 0
	playhead.ZIndex = 3
	playhead.Parent = keyframeAreaFrame

	local playbackRangeFrame = Instance.new("Frame")
	playbackRangeFrame.Name = "PlaybackRange"
	playbackRangeFrame.Size = UDim2.new(0, 200, 1, 0)
	playbackRangeFrame.Position = UDim2.new(0, 0, 0, 0)
	playbackRangeFrame.BackgroundColor3 = Config.Colors.Playhead
	playbackRangeFrame.BackgroundTransparency = 0.8
	playbackRangeFrame.BorderSizePixel = 0
	playbackRangeFrame.ZIndex = 2
	playbackRangeFrame.Parent = timelineRuler

	local startHandle = Instance.new("TextButton")
	startHandle.Name = "StartHandle"
	startHandle.Size = UDim2.new(0, 8, 1, 0)
	startHandle.Position = UDim2.new(0, 0, 0, 0)
	startHandle.BackgroundColor3 = Config.Colors.Playhead
	startHandle.BorderSizePixel = 0
	startHandle.Text = ""
	startHandle.ZIndex = 4
	startHandle.Parent = timelineRuler

	local endHandle = Instance.new("TextButton")
	endHandle.Name = "EndHandle"
	endHandle.Size = UDim2.new(0, 8, 1, 0)
	endHandle.Position = UDim2.new(0, 200, 0, 0)
	endHandle.BackgroundColor3 = Config.Colors.Playhead
	endHandle.BorderSizePixel = 0
	endHandle.Text = ""
	endHandle.ZIndex = 4
	endHandle.Parent = timelineRuler

	-- SAVE DIALOG --
	local saveDialogGui = Instance.new("ScreenGui")
	saveDialogGui.Name = "SaveDialogGui"
	saveDialogGui.Enabled = false
	saveDialogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	saveDialogGui.Parent = parentWidget

	local saveDialogFrame = Instance.new("Frame")
	saveDialogFrame.Name = "SaveDialogFrame"
	saveDialogFrame.Size = UDim2.new(0, 300, 0, 150)
	saveDialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	saveDialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	saveDialogFrame.BackgroundColor3 = Config.Colors.DialogBackground
	saveDialogFrame.BorderColor3 = Config.Colors.Border
	saveDialogFrame.Parent = saveDialogGui

	local saveTitle = Instance.new("TextLabel")
	saveTitle.Size = UDim2.new(1, 0, 0, 30)
	saveTitle.Text = "Simpan Animasi"
	saveTitle.Font = Enum.Font.SourceSansBold
	saveTitle.TextSize = 16
	saveTitle.TextColor3 = Config.Colors.TextPrimary
	saveTitle.BackgroundColor3 = Config.Colors.DialogHeader
	saveTitle.Parent = saveDialogFrame

	local animNameBox = Instance.new("TextBox")
	animNameBox.Name = "AnimNameBox"
	animNameBox.Size = UDim2.new(1, -20, 0, 30)
	animNameBox.Position = UDim2.new(0, 10, 0, 40)
	animNameBox.PlaceholderText = "Nama Animasi..."
	animNameBox.Font = Enum.Font.SourceSans
	animNameBox.TextSize = 14
	animNameBox.Parent = saveDialogFrame

	local confirmSaveButton = Instance.new("TextButton")
	confirmSaveButton.Name = "ConfirmSaveButton"
	confirmSaveButton.Size = UDim2.new(0.5, -15, 0, 30)
	confirmSaveButton.Position = UDim2.new(0, 10, 1, -40)
	confirmSaveButton.Text = "Simpan"
	confirmSaveButton.BackgroundColor3 = Config.Colors.ButtonPrimary
	confirmSaveButton.TextColor3 = Config.Colors.TextPrimary
	confirmSaveButton.Font = Enum.Font.SourceSansBold
	confirmSaveButton.Parent = saveDialogFrame

	local cancelSaveButton = Instance.new("TextButton")
	cancelSaveButton.Name = "CancelSaveButton"
	cancelSaveButton.Size = UDim2.new(0.5, -15, 0, 30)
	cancelSaveButton.Position = UDim2.new(0.5, 5, 1, -40)
	cancelSaveButton.Text = "Batal"
	cancelSaveButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	cancelSaveButton.TextColor3 = Config.Colors.TextPrimary
	cancelSaveButton.Font = Enum.Font.SourceSansBold
	cancelSaveButton.Parent = saveDialogFrame

	-- LOAD DIALOG --
	local loadDialogGui = Instance.new("ScreenGui")
	loadDialogGui.Name = "LoadDialogGui"
	loadDialogGui.Enabled = false
	loadDialogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	loadDialogGui.Parent = parentWidget

	local loadDialogFrame = Instance.new("Frame")
	loadDialogFrame.Name = "LoadDialogFrame"
	loadDialogFrame.Size = UDim2.new(0, 350, 0, 400)
	loadDialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	loadDialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	loadDialogFrame.BackgroundColor3 = Config.Colors.DialogBackground
	loadDialogFrame.BorderColor3 = Config.Colors.Border
	loadDialogFrame.Parent = loadDialogGui

	local loadTitle = Instance.new("TextLabel")
	loadTitle.Size = UDim2.new(1, 0, 0, 30)
	loadTitle.Text = "Muat Animasi"
	loadTitle.Font = Enum.Font.SourceSansBold
	loadTitle.TextSize = 16
	loadTitle.TextColor3 = Config.Colors.TextPrimary
	loadTitle.BackgroundColor3 = Config.Colors.DialogHeader
	loadTitle.Parent = loadDialogFrame

	local savedAnimsList = Instance.new("ScrollingFrame")
	savedAnimsList.Name = "SavedAnimsList"
	savedAnimsList.Size = UDim2.new(1, -20, 1, -80)
	savedAnimsList.Position = UDim2.new(0, 10, 0, 40)
	savedAnimsList.BackgroundColor3 = Config.Colors.MainBackground
	savedAnimsList.BorderSizePixel = 0
	savedAnimsList.ScrollBarThickness = 6
	savedAnimsList.Parent = loadDialogFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = savedAnimsList

	local cancelLoadButton = Instance.new("TextButton")
	cancelLoadButton.Name = "CancelLoadButton"
	cancelLoadButton.Size = UDim2.new(1, -20, 0, 30)
	cancelLoadButton.Position = UDim2.new(0, 10, 1, -40)
	cancelLoadButton.Text = "Batal"
	cancelLoadButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	cancelLoadButton.TextColor3 = Config.Colors.TextPrimary
	cancelLoadButton.Font = Enum.Font.SourceSansBold
	cancelLoadButton.Parent = loadDialogFrame

	-- EXPORT DIALOG --
	local exportDialogGui = Instance.new("ScreenGui")
	exportDialogGui.Name = "ExportDialogGui"
	exportDialogGui.Enabled = false
	exportDialogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	exportDialogGui.Parent = parentWidget

	local exportDialogFrame = Instance.new("Frame")
	exportDialogFrame.Name = "ExportDialogFrame"
	exportDialogFrame.Size = UDim2.new(0, 300, 0, 150)
	exportDialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	exportDialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	exportDialogFrame.BackgroundColor3 = Config.Colors.DialogBackground
	exportDialogFrame.BorderColor3 = Config.Colors.Border
	exportDialogFrame.Parent = exportDialogGui

	local exportTitle = Instance.new("TextLabel")
	exportTitle.Size = UDim2.new(1, 0, 0, 30)
	exportTitle.Text = "Ekspor Animasi"
	exportTitle.Font = Enum.Font.SourceSansBold
	exportTitle.TextSize = 16
	exportTitle.TextColor3 = Config.Colors.TextPrimary
	exportTitle.BackgroundColor3 = Config.Colors.DialogHeader
	exportTitle.Parent = exportDialogFrame

	local exportAnimNameBox = Instance.new("TextBox")
	exportAnimNameBox.Name = "ExportAnimNameBox"
	exportAnimNameBox.Size = UDim2.new(1, -20, 0, 30)
	exportAnimNameBox.Position = UDim2.new(0, 10, 0, 40)
	exportAnimNameBox.PlaceholderText = "Nama Animasi..."
	exportAnimNameBox.Font = Enum.Font.SourceSans
	exportAnimNameBox.TextSize = 14
	exportAnimNameBox.Parent = exportDialogFrame

	local confirmExportButton = Instance.new("TextButton")
	confirmExportButton.Name = "ConfirmExportButton"
	confirmExportButton.Size = UDim2.new(0.5, -15, 0, 30)
	confirmExportButton.Position = UDim2.new(0, 10, 1, -40)
	confirmExportButton.Text = "Ekspor"
	confirmExportButton.BackgroundColor3 = Config.Colors.ButtonPrimary
	confirmExportButton.TextColor3 = Config.Colors.TextPrimary
	confirmExportButton.Font = Enum.Font.SourceSansBold
	confirmExportButton.Parent = exportDialogFrame

	local cancelExportButton = Instance.new("TextButton")
	cancelExportButton.Name = "CancelExportButton"
	cancelExportButton.Size = UDim2.new(0.5, -15, 0, 30)
	cancelExportButton.Position = UDim2.new(0.5, 5, 1, -40)
	cancelExportButton.Text = "Batal"
	cancelExportButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	cancelExportButton.TextColor3 = Config.Colors.TextPrimary
	cancelExportButton.Font = Enum.Font.SourceSansBold
	cancelExportButton.Parent = exportDialogFrame

	-- CONFIRMATION DIALOG --
	local confirmDialogGui = Instance.new("ScreenGui")
	confirmDialogGui.Name = "ConfirmDialogGui"
	confirmDialogGui.Enabled = false
	confirmDialogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	confirmDialogGui.Parent = parentWidget

	local confirmDialogFrame = Instance.new("Frame")
	confirmDialogFrame.Name = "ConfirmDialogFrame"
	confirmDialogFrame.Size = UDim2.new(0, 300, 0, 150)
	confirmDialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	confirmDialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	confirmDialogFrame.BackgroundColor3 = Config.Colors.DialogBackground
	confirmDialogFrame.BorderColor3 = Config.Colors.Border
	confirmDialogFrame.Parent = confirmDialogGui

	local confirmTitle = Instance.new("TextLabel")
	confirmTitle.Name = "ConfirmTitle"
	confirmTitle.Size = UDim2.new(1, 0, 0, 30)
	confirmTitle.Text = "Konfirmasi"
	confirmTitle.Font = Enum.Font.SourceSansBold
	confirmTitle.TextSize = 16
	confirmTitle.TextColor3 = Config.Colors.TextPrimary
	confirmTitle.BackgroundColor3 = Config.Colors.DialogHeader
	confirmTitle.Parent = confirmDialogFrame

	local confirmMessage = Instance.new("TextLabel")
	confirmMessage.Name = "ConfirmMessage"
	confirmMessage.Size = UDim2.new(1, -20, 0, 60)
	confirmMessage.Position = UDim2.new(0, 10, 0, 35)
	confirmMessage.Text = "Apakah Anda yakin ingin melanjutkan?"
	confirmMessage.Font = Enum.Font.SourceSans
	confirmMessage.TextSize = 14
	confirmMessage.TextColor3 = Config.Colors.TextSecondary
	confirmMessage.TextWrapped = true
	confirmMessage.TextYAlignment = Enum.TextYAlignment.Top
	confirmMessage.BackgroundTransparency = 1
	confirmMessage.Parent = confirmDialogFrame

	local confirmYesButton = Instance.new("TextButton")
	confirmYesButton.Name = "ConfirmYesButton"
	confirmYesButton.Size = UDim2.new(0.5, -15, 0, 30)
	confirmYesButton.Position = UDim2.new(0, 10, 1, -40)
	confirmYesButton.Text = "Ya"
	confirmYesButton.BackgroundColor3 = Config.Colors.ButtonDanger
	confirmYesButton.TextColor3 = Config.Colors.TextPrimary
	confirmYesButton.Font = Enum.Font.SourceSansBold
	confirmYesButton.Parent = confirmDialogFrame

	local confirmCancelButton = Instance.new("TextButton")
	confirmCancelButton.Name = "ConfirmCancelButton"
	confirmCancelButton.Size = UDim2.new(0.5, -15, 0, 30)
	confirmCancelButton.Position = UDim2.new(0.5, 5, 1, -40)
	confirmCancelButton.Text = "Batal"
	confirmCancelButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	confirmCancelButton.TextColor3 = Config.Colors.TextPrimary
	confirmCancelButton.Font = Enum.Font.SourceSansBold
	confirmCancelButton.Parent = confirmDialogFrame

	-- NOTIFICATION DIALOG --
	local notificationDialogGui = Instance.new("ScreenGui")
	notificationDialogGui.Name = "NotificationDialogGui"
	notificationDialogGui.Enabled = false
	notificationDialogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	notificationDialogGui.Parent = parentWidget

	local notificationDialogFrame = Instance.new("Frame")
	notificationDialogFrame.Name = "NotificationDialogFrame"
	notificationDialogFrame.Size = UDim2.new(0, 300, 0, 150)
	notificationDialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	notificationDialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	notificationDialogFrame.BackgroundColor3 = Config.Colors.DialogBackground
	notificationDialogFrame.BorderColor3 = Config.Colors.Border
	notificationDialogFrame.Parent = notificationDialogGui

	local notificationTitle = Instance.new("TextLabel")
	notificationTitle.Name = "NotificationTitle"
	notificationTitle.Size = UDim2.new(1, 0, 0, 30)
	notificationTitle.Text = "Notifikasi"
	notificationTitle.Font = Enum.Font.SourceSansBold
	notificationTitle.TextSize = 16
	notificationTitle.TextColor3 = Config.Colors.TextPrimary
	notificationTitle.BackgroundColor3 = Config.Colors.DialogHeader
	notificationTitle.Parent = notificationDialogFrame

	local notificationMessage = Instance.new("TextLabel")
	notificationMessage.Name = "NotificationMessage"
	notificationMessage.Size = UDim2.new(1, -20, 0, 60)
	notificationMessage.Position = UDim2.new(0, 10, 0, 35)
	notificationMessage.Text = "Ini adalah pesan notifikasi."
	notificationMessage.Font = Enum.Font.SourceSans
	notificationMessage.TextSize = 14
	notificationMessage.TextColor3 = Config.Colors.TextSecondary
	notificationMessage.TextWrapped = true
	notificationMessage.TextYAlignment = Enum.TextYAlignment.Top
	notificationMessage.BackgroundTransparency = 1
	notificationMessage.Parent = notificationDialogFrame

	local notificationOkButton = Instance.new("TextButton")
	notificationOkButton.Name = "NotificationOkButton"
	notificationOkButton.Size = UDim2.new(1, -20, 0, 30)
	notificationOkButton.Position = UDim2.new(0, 10, 1, -40)
	notificationOkButton.Text = "OK"
	notificationOkButton.BackgroundColor3 = Config.Colors.ButtonPrimary
	notificationOkButton.TextColor3 = Config.Colors.TextPrimary
	notificationOkButton.Font = Enum.Font.SourceSansBold
	notificationOkButton.Parent = notificationDialogFrame

	-- PROPERTY SELECTOR MENU --
	local propMenuFrame = Instance.new("Frame")
	propMenuFrame.Name = "PropertyMenu"
	propMenuFrame.Visible = false
	propMenuFrame.Size = UDim2.new(0, 180, 0, 250)
	propMenuFrame.BackgroundColor3 = Config.Colors.TrackListBackground
	propMenuFrame.BorderColor3 = Config.Colors.Border
	propMenuFrame.ZIndex = 10
	propMenuFrame.Parent = mainFrame

	local propSearchBox = Instance.new("TextBox")
	propSearchBox.Name = "PropertySearchBox"
	propSearchBox.Size = UDim2.new(1, -10, 0, 22)
	propSearchBox.Position = UDim2.new(0, 5, 0, 5)
	propSearchBox.PlaceholderText = "Cari properti..."
	propSearchBox.Font = Enum.Font.SourceSans
	propSearchBox.TextSize = 14
	propSearchBox.BackgroundColor3 = Config.Colors.InputBackground
	propSearchBox.TextColor3 = Config.Colors.TextPrimary
	propSearchBox.ClearTextOnFocus = false
	propSearchBox.Parent = propMenuFrame

	local propList = Instance.new("ScrollingFrame")
	propList.Name = "PropertyList"
	propList.Size = UDim2.new(1, 0, 1, -32)
	propList.Position = UDim2.new(0, 0, 0, 32)
	propList.BackgroundTransparency = 1
	propList.BorderSizePixel = 0
	propList.ScrollBarThickness = 5
	propList.Parent = propMenuFrame

	local propListLayout = Instance.new("UIListLayout")
	propListLayout.Padding = UDim.new(0, 2)
	propListLayout.Parent = propList

	-- CONTEXT MENU --
	local contextMenuFrame = Instance.new("Frame")
	contextMenuFrame.Name = "ContextMenu"
	contextMenuFrame.Visible = false
	contextMenuFrame.Size = UDim2.new(0, 150, 0, 100) -- Ukuran akan disesuaikan
	contextMenuFrame.BackgroundColor3 = Config.Colors.TrackListBackground
	contextMenuFrame.BorderColor3 = Config.Colors.Border
	contextMenuFrame.ZIndex = 20
	contextMenuFrame.Parent = mainFrame

	local contextMenuLayout = Instance.new("UIListLayout")
	contextMenuLayout.Padding = UDim.new(0, 2)
	contextMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contextMenuLayout.Parent = contextMenuFrame

	-- MARQUEE SELECTION BOX --
	local marqueeSelectionBox = Instance.new("Frame")
	marqueeSelectionBox.Name = "MarqueeSelectionBox"
	marqueeSelectionBox.Visible = false
	marqueeSelectionBox.BackgroundColor3 = Config.Colors.KeyframeSelected
	marqueeSelectionBox.BackgroundTransparency = 0.8
	marqueeSelectionBox.BorderColor3 = Config.Colors.KeyframeSelected
	marqueeSelectionBox.BorderSizePixel = 1
	marqueeSelectionBox.ZIndex = 5
	marqueeSelectionBox.Parent = keyframeAreaFrame

	-- TOOLTIP LABEL --
	local tooltipLabel = Instance.new("TextLabel")
	tooltipLabel.Name = "TooltipLabel"
	tooltipLabel.Visible = false
	tooltipLabel.Size = UDim2.new(0, 150, 0, 25) -- Default size, can be adjusted
	tooltipLabel.BackgroundColor3 = Config.Colors.DialogBackground
	tooltipLabel.BorderColor3 = Config.Colors.Border
	tooltipLabel.TextColor3 = Config.Colors.TextPrimary
	tooltipLabel.Font = Enum.Font.SourceSans
	tooltipLabel.TextSize = 12
	tooltipLabel.TextWrapped = true
	tooltipLabel.ZIndex = 100 -- Ensure it's on top of everything
	tooltipLabel.Parent = mainFrame

	return {
		mainFrame = mainFrame,
		tooltipLabel = tooltipLabel,
		marqueeSelectionBox = marqueeSelectionBox,
		selectedObjectLabel = selectedObjectLabel,
		saveButton = saveButton,
		loadButton = loadButton,
		undoButton = undoButton,
		redoButton = redoButton,
		exportButton = exportButton,
		clearAllButton = clearAllButton,
		playButton = playButton,
		stopButton = stopButton,
		speedDropdown = speedDropdown,
		loopButton = loopButton,
	viewToggleButton = viewToggleButton,
		zoomInButton = zoomInButton,
		zoomOutButton = zoomOutButton,
		addObjectButton = addObjectButton,
		addCameraButton = addCameraButton,
		cameraLockButton = cameraLockButton,
		addKeyframeButton = addKeyframeButton,
		autoKeyButton = autoKeyButton,
		timelineLengthInput = timelineLengthInput,
		easingButton = easingButton,
		collapseButton = collapseButton,
		deleteKeyframeButton = deleteKeyframeButton,
		easingMenu = easingMenu,
		trackListFrame = trackListFrame,
		propertiesFrame = propertiesFrame,
		timelineContainer = timelineContainer,
		keyframeAreaFrame = keyframeAreaFrame,
		keyframeTracksContainer = keyframeTracksContainer,
		timelineRuler = timelineRuler,
		playhead = playhead,
		playbackRange = {
			frame = playbackRangeFrame,
			startHandle = startHandle,
			endHandle = endHandle,
		},
		graphEditor = {
			frame = graphEditorFrame,
			canvas = graphCanvas,
		},
		saveDialog = {
			gui = saveDialogGui,
			frame = saveDialogFrame,
			nameBox = animNameBox,
			confirmButton = confirmSaveButton,
			cancelButton = cancelSaveButton,
		},
		loadDialog = {
			gui = loadDialogGui,
			list = savedAnimsList,
			cancelButton = cancelLoadButton,
		},
		exportDialog = {
			gui = exportDialogGui,
			frame = exportDialogFrame,
			nameBox = exportAnimNameBox,
			confirmButton = confirmExportButton,
			cancelButton = cancelExportButton,
		},
		confirmDialog = {
			gui = confirmDialogGui,
			title = confirmTitle,
			message = confirmMessage,
			yesButton = confirmYesButton,
			cancelButton = confirmCancelButton,
		},
		notificationDialog = {
			gui = notificationDialogGui,
			title = notificationTitle,
			message = notificationMessage,
			okButton = notificationOkButton,
		},
		contextMenu = {
			frame = contextMenuFrame,
			layout = contextMenuLayout,
		},
		propMenu = {
			frame = propMenuFrame,
			searchBox = propSearchBox,
			list = propList,
			layout = propListLayout,
		},
		placeholderLabel = placeholderLabel,
		propertyLabels = {
			cframe = {
				posHolder = posHolder,
				posXHolder = posXHolder, posYHolder = posYHolder, posZHolder = posZHolder,
				rotHolder = rotHolder,
				rotXHolder = rotXHolder, rotYHolder = rotYHolder, rotZHolder = rotZHolder,
				posX = posX, posY = posY, posZ = posZ,
				rotX = rotX, rotY = rotY, rotZ = rotZ,
			},
			generic = {
				holder = genericPropHolder,
				nameLabel = genericPropNameLabel,
				name = genericPropName,
				x = genericPropValueX, xHolder = genericPropValueXHolder,
				y = genericPropValueY, yHolder = genericPropValueYHolder,
				z = genericPropValueZ, zHolder = genericPropValueZHolder,
			},
			color3 = {
				holder = colorHolder,
				nameLabel = colorNameLabel,
				swatch = colorSwatch,
			},
			udim2 = {
				holder = udim2Holder,
				xsHolder = udim2XSHolder, xoHolder = udim2XOHolder,
				ysHolder = udim2YSHolder, yoHolder = udim2YOHolder,
				xs = udim2XS, xo = udim2XO, ys = udim2YS, yo = udim2YO,
			},
			boolean = {
				holder = boolHolder,
				nameLabel = boolNameLabel,
				checkbox = boolCheckbox,
			}
		}
	}
end

return UIManager
