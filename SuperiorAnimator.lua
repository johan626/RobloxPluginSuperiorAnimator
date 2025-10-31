--SuperiorAnimator.lua

local PLUGIN_NAME = "SuperiorAnimator"
local PLUGIN_VERSION = "0.1.0"

-- === KONFIGURASI ===
local Config = {
	TRACK_HEIGHT = 28,
	FRAMES_PER_SECOND = 24,
	PIXELS_PER_FRAME_INTERVAL = 60,
	FRAMES_PER_INTERVAL = 10,
	Colors = {
		-- Latar Belakang
		MainBackground = Color3.fromRGB(45, 45, 45),
		ContentBackground = Color3.fromRGB(50, 50, 50),
		PropertiesBackground = Color3.fromRGB(40, 40, 40),
		TopBarBackground = Color3.fromRGB(35, 35, 35),
		TrackListBackground = Color3.fromRGB(60, 60, 60),
		TrackBackground = Color3.fromRGB(55, 55, 55),
		SubTrackBackground = Color3.fromRGB(58, 58, 58),
		SubTrackLabelBackground = Color3.fromRGB(65, 65, 65),
		DialogBackground = Color3.fromRGB(50, 50, 50),
		DialogHeader = Color3.fromRGB(40, 40, 40),
		InputBackground = Color3.fromRGB(50, 50, 50),

		-- Teks
		TextPrimary = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(220, 220, 220),
		TextMuted = Color3.fromRGB(200, 200, 200),
		TextDisabled = Color3.fromRGB(180, 180, 180),

		-- Tombol
		ButtonPrimary = Color3.fromRGB(70, 90, 120),
		ButtonSecondary = Color3.fromRGB(80, 80, 80),
		ButtonDanger = Color3.fromRGB(120, 70, 70),
		ButtonDelete = Color3.fromRGB(80, 50, 50),

		-- Timeline
		Playhead = Color3.fromRGB(255, 80, 80),
		KeyframeLinear = Color3.fromRGB(255, 255, 0),
		KeyframeEased = Color3.fromRGB(0, 255, 127),
		KeyframeSelected = Color3.fromRGB(0, 170, 255),
		TrackSelected = Color3.fromRGB(80, 80, 100),

		-- Lain-lain
		Border = Color3.fromRGB(80, 80, 80),
		Separator = Color3.fromRGB(60, 60, 60),
	}
}

-- Forward declarations untuk fungsi yang saling memanggil
local updateAnimationFromPlayhead
local updatePropertyDisplay
local onHeartbeat
local updateSelectedObjectLabel
local updateTimelineRuler
local openContextMenu
local updateCanvasSize
local clearTimeline
local createTrackForObject
local addKeyframeData
local createKeyframeMarkerUI
local deleteTrack
local updateKeyframeValue
local openContextMenu
local handleKeyframeSelection
local updateTimelineRuler

-- Fungsi ini HANYA membuat dan mengembalikan elemen-elemen UI.
-- Semua logika perilaku (event) akan dihubungkan di luar fungsi ini.
local function createUiElements(parentWidget)
	-- === STRUKTUR UI ===
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = Config.Colors.MainBackground
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = parentWidget

	-- TOP BAR --
	local topBarFrame = Instance.new("Frame")
	topBarFrame.Name = "TopBar"
	topBarFrame.Size = UDim2.new(1, 0, 0, 36)
	topBarFrame.BackgroundColor3 = Config.Colors.TopBarBackground
	topBarFrame.BorderSizePixel = 0
	topBarFrame.Parent = mainFrame

	local topBarLayout = Instance.new("UIListLayout")
	topBarLayout.FillDirection = Enum.FillDirection.Horizontal
	topBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	topBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	topBarLayout.Padding = UDim.new(0, 5)
	topBarLayout.Parent = topBarFrame

	local saveButton = Instance.new("TextButton")
	saveButton.Name = "SaveButton"
	saveButton.Size = UDim2.new(0, 50, 0, 28)
	saveButton.Text = "Save"
	saveButton.BackgroundColor3 = Config.Colors.ButtonPrimary
	saveButton.TextColor3 = Config.Colors.TextPrimary
	saveButton.Font = Enum.Font.SourceSansBold
	saveButton.TextSize = 14
	saveButton.LayoutOrder = 1
	saveButton.Parent = topBarFrame

	local loadButton = Instance.new("TextButton")
	loadButton.Name = "LoadButton"
	loadButton.Size = UDim2.new(0, 50, 0, 28)
	loadButton.Text = "Load"
	loadButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	loadButton.TextColor3 = Config.Colors.TextPrimary
	loadButton.Font = Enum.Font.SourceSansBold
	loadButton.TextSize = 14
	loadButton.LayoutOrder = 2
	loadButton.Parent = topBarFrame

	local separator_undo = Instance.new("Frame")
	separator_undo.Size = UDim2.new(0, 1, 0, 28)
	separator_undo.BackgroundColor3 = Config.Colors.Separator
	separator_undo.LayoutOrder = 3
	separator_undo.Parent = topBarFrame

	local undoButton = Instance.new("TextButton")
	undoButton.Name = "UndoButton"
	undoButton.Size = UDim2.new(0, 50, 0, 28)
	undoButton.Text = "Undo"
	undoButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	undoButton.TextColor3 = Config.Colors.TextDisabled -- Dimulai sebagai nonaktif
	undoButton.Font = Enum.Font.SourceSansBold
	undoButton.TextSize = 14
	undoButton.LayoutOrder = 4
	undoButton.Parent = topBarFrame

	local redoButton = Instance.new("TextButton")
	redoButton.Name = "RedoButton"
	redoButton.Size = UDim2.new(0, 50, 0, 28)
	redoButton.Text = "Redo"
	redoButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	redoButton.TextColor3 = Config.Colors.TextDisabled -- Dimulai sebagai nonaktif
	redoButton.Font = Enum.Font.SourceSansBold
	redoButton.TextSize = 14
	redoButton.LayoutOrder = 5
	redoButton.Parent = topBarFrame

	local exportButton = Instance.new("TextButton")
	exportButton.Name = "ExportButton"
	exportButton.Size = UDim2.new(0, 60, 0, 28)
	exportButton.Text = "Export"
	exportButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	exportButton.TextColor3 = Config.Colors.TextPrimary
	exportButton.Font = Enum.Font.SourceSansBold
	exportButton.TextSize = 14
	exportButton.LayoutOrder = 3
	exportButton.Parent = topBarFrame

	local separator1 = Instance.new("Frame")
	separator1.Size = UDim2.new(0, 1, 0, 28)
	separator1.BackgroundColor3 = Config.Colors.Separator
	separator1.LayoutOrder = 6
	separator1.Parent = topBarFrame

	local playButton = Instance.new("TextButton")
	playButton.Name = "PlayButton"
	playButton.Size = UDim2.new(0, 50, 0, 28)
	playButton.Text = "Play"
	playButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	playButton.TextColor3 = Config.Colors.TextPrimary
	playButton.Font = Enum.Font.SourceSansBold
	playButton.TextSize = 14
	playButton.LayoutOrder = 7
	playButton.Parent = topBarFrame

	local stopButton = Instance.new("TextButton")
	stopButton.Name = "StopButton"
	stopButton.Size = UDim2.new(0, 50, 0, 28)
	stopButton.Text = "Stop"
	stopButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	stopButton.TextColor3 = Config.Colors.TextPrimary
	stopButton.Font = Enum.Font.SourceSansBold
	stopButton.TextSize = 14
	stopButton.LayoutOrder = 8
	stopButton.Parent = topBarFrame

	local speedDropdown = Instance.new("TextButton")
	speedDropdown.Name = "SpeedDropdown"
	speedDropdown.Size = UDim2.new(0, 60, 0, 28)
	speedDropdown.Text = "1x"
	speedDropdown.BackgroundColor3 = Config.Colors.ButtonSecondary
	speedDropdown.TextColor3 = Config.Colors.TextPrimary
	speedDropdown.Font = Enum.Font.SourceSansBold
	speedDropdown.TextSize = 14
	speedDropdown.LayoutOrder = 9
	speedDropdown.Parent = topBarFrame

	local loopButton = Instance.new("TextButton")
	loopButton.Name = "LoopButton"
	loopButton.Size = UDim2.new(0, 28, 0, 28)
	loopButton.Text = "🔁" -- Loop symbol
	loopButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	loopButton.TextColor3 = Config.Colors.TextPrimary
	loopButton.Font = Enum.Font.SourceSansBold
	loopButton.TextSize = 16
	loopButton.LayoutOrder = 10
	loopButton.Parent = topBarFrame

	local zoomOutButton = Instance.new("TextButton")
	zoomOutButton.Name = "ZoomOutButton"
	zoomOutButton.Size = UDim2.new(0, 28, 0, 28)
	zoomOutButton.Text = "-"
	zoomOutButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	zoomOutButton.TextColor3 = Config.Colors.TextPrimary
	zoomOutButton.Font = Enum.Font.SourceSansBold
	zoomOutButton.TextSize = 20
	zoomOutButton.LayoutOrder = 11
	zoomOutButton.Parent = topBarFrame

	local zoomInButton = Instance.new("TextButton")
	zoomInButton.Name = "ZoomInButton"
	zoomInButton.Size = UDim2.new(0, 28, 0, 28)
	zoomInButton.Text = "+"
	zoomInButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	zoomInButton.TextColor3 = Config.Colors.TextPrimary
	zoomInButton.Font = Enum.Font.SourceSansBold
	zoomInButton.TextSize = 20
	zoomInButton.LayoutOrder = 12
	zoomInButton.Parent = topBarFrame

	local separator2 = Instance.new("Frame")
	separator2.Size = UDim2.new(0, 1, 0, 28)
	separator2.BackgroundColor3 = Config.Colors.Separator
	separator2.LayoutOrder = 13
	separator2.Parent = topBarFrame

	local addObjectButton = Instance.new("TextButton")
	addObjectButton.Name = "AddObjectButton"
	addObjectButton.Size = UDim2.new(0, 100, 0, 28)
	addObjectButton.Text = "Tambah Objek"
	addObjectButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	addObjectButton.TextColor3 = Config.Colors.TextPrimary
	addObjectButton.Font = Enum.Font.SourceSansBold
	addObjectButton.TextSize = 14
	addObjectButton.LayoutOrder = 14
	addObjectButton.Parent = topBarFrame

	local addKeyframeButton = Instance.new("TextButton")
	addKeyframeButton.Name = "AddKeyframeButton"
	addKeyframeButton.Size = UDim2.new(0, 28, 0, 28)
	addKeyframeButton.Text = "+"
	addKeyframeButton.Font = Enum.Font.SourceSansBold
	addKeyframeButton.TextSize = 24
	addKeyframeButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	addKeyframeButton.TextColor3 = Config.Colors.TextPrimary
	addKeyframeButton.LayoutOrder = 15
	addKeyframeButton.Parent = topBarFrame

	local autoKeyButton = Instance.new("TextButton")
	autoKeyButton.Name = "AutoKeyButton"
	autoKeyButton.Size = UDim2.new(0, 50, 0, 28)
	autoKeyButton.Text = "Auto"
	autoKeyButton.BackgroundColor3 = Config.Colors.ButtonSecondary -- Warna default (non-aktif)
	autoKeyButton.TextColor3 = Config.Colors.TextPrimary
	autoKeyButton.Font = Enum.Font.SourceSansBold
	autoKeyButton.TextSize = 14
	autoKeyButton.LayoutOrder = 16
	autoKeyButton.Parent = topBarFrame

	local separator3 = Instance.new("Frame")
	separator3.Size = UDim2.new(0, 1, 0, 28)
	separator3.BackgroundColor3 = Config.Colors.Separator
	separator3.LayoutOrder = 17
	separator3.Parent = topBarFrame

	local selectedObjectLabel = Instance.new("TextLabel")
	selectedObjectLabel.Name = "SelectedObjectLabel"
	selectedObjectLabel.Size = UDim2.new(1, -700, 1, 0) -- Adjusted size for new buttons
	selectedObjectLabel.Font = Enum.Font.SourceSans
	selectedObjectLabel.TextSize = 14
	selectedObjectLabel.TextColor3 = Config.Colors.TextMuted
	selectedObjectLabel.BackgroundTransparency = 1
	selectedObjectLabel.TextXAlignment = Enum.TextXAlignment.Right
	selectedObjectLabel.Text = "Tidak ada objek yang dipilih"
	selectedObjectLabel.LayoutOrder = 18
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

	return {
		mainFrame = mainFrame,
		marqueeSelectionBox = marqueeSelectionBox,
		selectedObjectLabel = selectedObjectLabel,
		saveButton = saveButton,
		loadButton = loadButton,
		undoButton = undoButton,
		redoButton = redoButton,
		exportButton = exportButton,
		playButton = playButton,
		stopButton = stopButton,
		speedDropdown = speedDropdown,
		loopButton = loopButton,
		zoomInButton = zoomInButton,
		zoomOutButton = zoomOutButton,
		addObjectButton = addObjectButton,
		addKeyframeButton = addKeyframeButton,
		autoKeyButton = autoKeyButton,
		easingButton = easingButton,
		deleteKeyframeButton = deleteKeyframeButton,
		easingMenu = easingMenu,
		trackListFrame = trackListFrame,
		keyframeAreaFrame = keyframeAreaFrame,
		keyframeTracksContainer = keyframeTracksContainer,
		timelineRuler = timelineRuler,
		playhead = playhead,
		playbackRange = {
			frame = playbackRangeFrame,
			startHandle = startHandle,
			endHandle = endHandle,
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

-- === LOGIKA UTAMA PLUGIN ===
local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float, true, false, 800, 600, 600, 400
)
local mainWidget = plugin:CreateDockWidgetPluginGui("SuperiorAnimator_Main", widgetInfo)
mainWidget.Title = PLUGIN_NAME
mainWidget.Name = "SuperiorAnimator"

local ui = createUiElements(mainWidget)

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local newAnimationButton = toolbar:CreateButton(
	"Superior Animator", "Buka Superior Animator", "rbxassetid://448737683"
)

-- === DATA & STATE VARIABLES ===
local RunService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
local selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

-- Definisikan OutBounce secara terpisah untuk mengatasi masalah forward declaration
local function OutBounce(t)
	local n1=7.5625; local d1=2.75;
	if t < 1/d1 then return n1*t*t
	elseif t < 2/d1 then local t2=t-(1.5/d1); return n1*t2*t2+0.75
	elseif t < 2.5/d1 then local t2=t-(2.25/d1); return n1*t2*t2+0.9375
	else local t2=t-(2.625/d1); return n1*t2*t2+0.984375 end
end

local EasingFunctions = {
	Linear = function(t) return t end,

	-- Sine
	InSine = function(t) return 1 - math.cos((t * math.pi) / 2) end,
	OutSine = function(t) return math.sin((t * math.pi) / 2) end,
	InOutSine = function(t) return -(math.cos(math.pi * t) - 1) / 2 end,

	-- Quad
	InQuad = function(t) return t * t end,
	OutQuad = function(t) return 1 - (1 - t) * (1 - t) end,
	InOutQuad = function(t)
		if t < 0.5 then return 2 * t * t
		else return 1 - math.pow(-2 * t + 2, 2) / 2 end
	end,

	-- Cubic
	InCubic = function(t) return t * t * t end,
	OutCubic = function(t) return 1 - math.pow(1 - t, 3) end,
	InOutCubic = function(t)
		if t < 0.5 then return 4 * t * t * t
		else return 1 - math.pow(-2 * t + 2, 3) / 2 end
	end,

	-- Quart
	InQuart = function(t) return t * t * t * t end,
	OutQuart = function(t) return 1 - math.pow(1 - t, 4) end,
	InOutQuart = function(t)
		if t < 0.5 then return 8 * t * t * t * t
		else return 1 - math.pow(-2 * t + 2, 4) / 2 end
	end,

	-- Quint
	InQuint = function(t) return t * t * t * t * t end,
	OutQuint = function(t) return 1 - math.pow(1 - t, 5) end,
	InOutQuint = function(t)
		if t < 0.5 then return 16 * t * t * t * t * t
		else return 1 - math.pow(-2 * t + 2, 5) / 2 end
	end,

	-- Expo
	InExpo = function(t) if t == 0 then return 0 else return math.pow(2, 10 * t - 10) end end,
	OutExpo = function(t) if t == 1 then return 1 else return 1 - math.pow(2, -10 * t) end end,
	InOutExpo = function(t)
		if t == 0 then return 0
		elseif t == 1 then return 1
		elseif t < 0.5 then return math.pow(2, 20 * t - 10) / 2
		else return (2 - math.pow(2, -20 * t + 10)) / 2 end
	end,

	-- Circ
	InCirc = function(t) return 1 - math.sqrt(1 - math.pow(t, 2)) end,
	OutCirc = function(t) return math.sqrt(1 - math.pow(t - 1, 2)) end,
	InOutCirc = function(t)
		if t < 0.5 then return (1 - math.sqrt(1 - math.pow(2 * t, 2))) / 2
		else return (math.sqrt(1 - math.pow(-2 * t + 2, 2)) + 1) / 2 end
	end,

	-- Back
	InBack = function(t) local c1=1.70158; local c3=c1+1; return c3*t*t*t-c1*t*t end,
	OutBack = function(t) local c1=1.70158; local c3=c1+1; return 1+c3*math.pow(t-1,3)+c1*math.pow(t-1,2) end,
	InOutBack = function(t)
		local c1=1.70158; local c2=c1*1.525;
		if t < 0.5 then return (math.pow(2*t,2)*((c2+1)*2*t-c2))/2
		else return (math.pow(2*t-2,2)*((c2+1)*(t*2-2)+c2)+2)/2 end
	end,

	-- Elastic
	InElastic = function(t)
		local c4=(2*math.pi)/3; if t==0 then return 0 elseif t==1 then return 1 end
		return -math.pow(2,10*t-10)*math.sin((t*10-10.75)*c4)
	end,
	OutElastic = function(t)
		local c4=(2*math.pi)/3; if t==0 then return 0 elseif t==1 then return 1 end
		return math.pow(2,-10*t)*math.sin((t*10-0.75)*c4)+1
	end,
	InOutElastic = function(t)
		local c5=(2*math.pi)/4.5; if t==0 then return 0 elseif t==1 then return 1 end
		if t < 0.5 then return -(math.pow(2,20*t-10)*math.sin((20*t-11.125)*c5))/2
		else return (math.pow(2,-20*t+10)*math.sin((20*t-11.125)*c5))/2+1 end
	end,
	-- Bounce
	OutBounce = OutBounce, -- Referensikan fungsi lokal
	InBounce = function(t) return 1 - OutBounce(1-t) end, -- Panggil fungsi lokal
	InOutBounce = function(t)
		if t < 0.5 then return (1-OutBounce(1-2*t))/2
		else return (1+OutBounce(2*t-1))/2 end
	end
}

-- Diurutkan berdasarkan kategori untuk dropdown nanti
local easingStyles = {
	{ Name = "Linear", Styles = {"Linear"} },
	{ Name = "Sine", Styles = {"InSine", "OutSine", "InOutSine"} },
	{ Name = "Quad", Styles = {"InQuad", "OutQuad", "InOutQuad"} },
	{ Name = "Cubic", Styles = {"InCubic", "OutCubic", "InOutCubic"} },
	{ Name = "Quart", Styles = {"InQuart", "OutQuart", "InOutQuart"} },
	{ Name = "Quint", Styles = {"InQuint", "OutQuint", "InOutQuint"} },
	{ Name = "Expo", Styles = {"InExpo", "OutExpo", "InOutExpo"} },
	{ Name = "Circ", Styles = {"InCirc", "OutCirc", "InOutCirc"} },
	{ Name = "Back", Styles = {"InBack", "OutBack", "InOutBack"} },
	{ Name = "Elastic", Styles = {"InElastic", "OutElastic", "InOutElastic"} },
	{ Name = "Bounce", Styles = {"InBounce", "OutBounce", "InOutBounce"} },
}

local animationData = {} 
local currentSelection = {
	type = nil, -- "Keyframe", "Event"
	data = {} -- List of selected items (kfInfo or eventInfo)
}
local currentlySelectedTrack = { object = nil, property = nil, label = nil }
local draggingKeyframeInfo = nil
local isDraggingPlayhead = false
local draggingPlaybackHandle = nil -- "Start" or "End"
local currentlySelectedObject = nil
local isPlaying = false
local isLoopingEnabled = false
local playbackConnection = nil
local objectForPropMenu = nil
local confirmAction = nil
local contextMenuTarget = nil
local keyframeClipboard = nil -- Untuk copy/paste
local isAutoKeyingEnabled = false
local autoKeyConnections = {} -- [Instance] = RBXScriptConnection
local debounceThreads = {} -- [Instance][propName] = thread
local isMarqueeSelecting = false
local marqueeStartPoint = Vector2.new(0, 0)
local zoomLevel = 1.0 -- 1.0 = 100% zoom
local playbackSpeed = 1.0 -- 1.0 = 100% speed

-- === PENGELOLA RIWAYAT TINDAKAN (UNDO/REDO) ===
local ActionHistory = {}
local undoStack = {}
local redoStack = {}
local MAX_HISTORY = 100 -- Batasi jumlah riwayat untuk menghemat memori

-- Fungsi ini akan dipanggil nanti untuk mengaktifkan/menonaktifkan tombol
local updateUndoRedoButtonStates = function() end

function ActionHistory.register(action)
	-- 'action' harus berupa tabel dengan fungsi 'undo' dan 'redo'
	table.insert(undoStack, action)

	-- Hapus riwayat tertua jika melebihi batas
	if #undoStack > MAX_HISTORY then
		table.remove(undoStack, 1)
	end

	-- Setiap tindakan baru akan menghapus riwayat redo
	for i = #redoStack, 1, -1 do
		table.remove(redoStack, i)
	end

	updateUndoRedoButtonStates() 
end

function ActionHistory.undo()
	if #undoStack == 0 then
		print("Tidak ada tindakan untuk diurungkan.")
		return
	end

	local action = table.remove(undoStack)
	if action and action.undo then
		pcall(action.undo) -- Gunakan pcall untuk keamanan
		table.insert(redoStack, action)
		updateUndoRedoButtonStates()
		print("Tindakan diurungkan.")
	end
end

function ActionHistory.redo()
	if #redoStack == 0 then
		print("Tidak ada tindakan untuk diulangi.")
		return
	end

	local action = table.remove(redoStack)
	if action and action.redo then
		pcall(action.redo) -- Gunakan pcall untuk keamanan
		table.insert(undoStack, action)
		updateUndoRedoButtonStates()
		print("Tindakan diulangi.")
	end
end


-- === FUNCTION DEFINITIONS ===

local function createEventMarkerUI(object, frame, name)
	local eventTrack = animationData[object].Events
	local container = animationData[object].eventTrackUI.keyframes
	if not container then return nil end

	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * zoomLevel
	local positionX = frame * pixelsPerFrame

	local marker = Instance.new("TextButton")
	marker.Name = "EventMarker_" .. frame
	marker.Text = "" 
	marker.AnchorPoint = Vector2.new(0.5, 0.5)
	marker.Size = UDim2.new(0, 12, 0, 12)
	marker.Position = UDim2.new(0, positionX, 0.5, 0)
	marker.BackgroundColor3 = Color3.fromRGB(255, 120, 0) -- Orange color for events
	marker.Parent = container

	eventTrack.markers[frame] = marker
	eventTrack.keyframes[frame] = { Name = name }

	marker.MouseButton1Click:Connect(function()
		-- Clear other selections
		for _, selectedInfo in ipairs(selectedKeyframes) do
			local prevPropData = animationData[selectedInfo.object].Properties[selectedInfo.property]
			if prevPropData then
				local prevTargetTrack = selectedInfo.component and prevPropData.Components[selectedInfo.component] or prevPropData
				if prevTargetTrack and prevTargetTrack.keyframes[selectedInfo.frame] then
					local prevKeyframeData = prevTargetTrack.keyframes[selectedInfo.frame]
					selectedInfo.marker.BackgroundColor3 = if prevKeyframeData.Easing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
				end
			end
		end
		-- Clear other selections of different types
		if currentSelection.type ~= "Event" then
			-- Deselect all keyframes
			for _, selectedInfo in ipairs(currentSelection.data) do
				local prevPropData = animationData[selectedInfo.object].Properties[selectedInfo.property]
				if prevPropData then
					local prevKeyframeData = (selectedInfo.component and prevPropData.Components[selectedInfo.component] or prevPropData).keyframes[selectedInfo.frame]
					if prevKeyframeData then
						selectedInfo.marker.BackgroundColor3 = if prevKeyframeData.Easing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
					end
				end
			end
			currentSelection = { type = "Event", data = {} }
		end

		-- For now, event selection is single-select only
		for _, sel in ipairs(currentSelection.data) do
			sel.marker.BackgroundColor3 = Color3.fromRGB(255, 120, 0) -- Deselect previous event
		end
		currentSelection.data = {}

		table.insert(currentSelection.data, { object = object, frame = frame, marker = marker })
		marker.BackgroundColor3 = Config.Colors.KeyframeSelected

		updatePropertyDisplay(nil, nil, eventTrack.keyframes[frame])
	end)

	marker.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			local options = {
				{ Text = "Delete Event", Callback = function(target)
					local eventTrack = animationData[target.object].Events
					local eventData = eventTrack.keyframes[target.frame]
					if not eventData then return end

					local action = {
						redo = function()
							if eventTrack.markers[target.frame] then
								eventTrack.markers[target.frame]:Destroy()
								eventTrack.markers[target.frame] = nil
								eventTrack.keyframes[target.frame] = nil
							end
							currentSelection = { type = nil, data = {} }
							updatePropertyDisplay(nil,nil,nil)
							updateTimelineRuler()
						end,
						undo = function()
							createEventMarkerUI(target.object, target.frame, eventData.Name)
							updateTimelineRuler()
						end
					}
					ActionHistory.register(action)
					action.redo()
				end}
			}
			openContextMenu({object = object, frame = frame, marker = marker}, options)
		end
	end)

	return marker
end



local function connectAutoKeyListener(object)
	if not isAutoKeyingEnabled or autoKeyConnections[object] or not animationData[object] then
		return
	end

	autoKeyConnections[object] = object.Changed:Connect(function(propName)
		local objectData = animationData[object]
		if not objectData or not objectData.Properties[propName] then
			return
		end

		if not debounceThreads[object] then debounceThreads[object] = {} end

		-- Batalkan thread debounce sebelumnya untuk properti ini, jika ada
		if debounceThreads[object][propName] then
			task.cancel(debounceThreads[object][propName])
		end

		-- Buat thread debounce baru
		debounceThreads[object][propName] = task.delay(0.1, function()
			-- Dapatkan frame saat ini
			local playheadX = ui.playhead.Position.X.Offset
			local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * zoomLevel
			local currentFrame = math.floor(playheadX / pixelsPerFrame)

			-- Tambahkan atau perbarui keyframe
			local propData = objectData.Properties[propName]
			local newValue = object[propName]

			local existingKeyframe = propData.keyframes[currentFrame]
			if existingKeyframe then
				existingKeyframe.Value = newValue
			else
				addKeyframeData(object, propName, currentFrame, newValue, "Linear", nil)
				createKeyframeMarkerUI(object, propName, currentFrame, nil)
				updateTimelineRuler() -- Perbarui ruler jika keyframe baru dibuat
			end

			-- Perbarui tampilan properti jika keyframe yang baru saja diubah adalah yang sedang dipilih
			if #selectedKeyframes == 1 and selectedKeyframes[1].object == object and selectedKeyframes[1].property == propName and selectedKeyframes[1].frame == currentFrame then
				updatePropertyDisplay(propData.keyframes[currentFrame], propName)
			end

			debounceThreads[object][propName] = nil
		end)
	end)
end

local function disconnectAutoKeyListener(object)
	if autoKeyConnections[object] then
		autoKeyConnections[object]:Disconnect()
		autoKeyConnections[object] = nil
	end

	-- Batalkan semua thread debounce yang tertunda untuk objek ini
	if debounceThreads[object] then
		for propName, thread in pairs(debounceThreads[object]) do
			if thread then
				task.cancel(thread)
			end
		end
		debounceThreads[object] = nil
	end
end

local function showConfirmation(title, message, onConfirm)
	ui.confirmDialog.title.Text = title
	ui.confirmDialog.message.Text = message
	confirmAction = onConfirm -- Simpan aksi yang akan dijalankan
	ui.confirmDialog.gui.Enabled = true
end

function handleKeyframeSelection(kfInfo, forceShift)
	local keyframeMarker = kfInfo.marker
	local object = kfInfo.object
	local mainPropName = kfInfo.property
	local componentName = kfInfo.component
	local frame = kfInfo.frame

	local propData = animationData[object] and animationData[object].Properties[mainPropName]
	if not propData then return end
	local targetTrack = componentName and propData.Components[componentName] or propData
	if not targetTrack then return end

	local isShiftDown = forceShift or inputService:IsKeyDown(Enum.KeyCode.LeftShift) or inputService:IsKeyDown(Enum.KeyCode.RightShift)

	if not isShiftDown or currentSelection.type ~= "Keyframe" then
		-- Hapus seleksi sebelumnya
		for _, selectedInfo in ipairs(currentSelection.data) do
			if selectedInfo.marker ~= keyframeMarker then
				local prevPropData = animationData[selectedInfo.object].Properties[selectedInfo.property]
				if prevPropData then
					local prevTargetTrack = selectedInfo.component and prevPropData.Components[selectedInfo.component] or prevPropData
					if prevTargetTrack and prevTargetTrack.keyframes[selectedInfo.frame] then
						local prevKeyframeData = prevTargetTrack.keyframes[selectedInfo.frame]
						selectedInfo.marker.BackgroundColor3 = if prevKeyframeData.Easing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
					end
				end
			end
		end
		currentSelection = { type = "Keyframe", data = {} }
	end

	-- Periksa apakah keyframe sudah dipilih
	local alreadySelected = false
	local selectionIndex = -1
	for i, selectedInfo in ipairs(currentSelection.data) do
		if selectedInfo.marker == keyframeMarker then
			alreadySelected = true
			selectionIndex = i
			break
		end
	end

	if isShiftDown and alreadySelected then
		-- Hapus dari seleksi
		local selectedInfo = currentSelection.data[selectionIndex]
		local prevPropData = animationData[selectedInfo.object].Properties[selectedInfo.property]
		local prevTargetTrack = selectedInfo.component and prevPropData.Components[selectedInfo.component] or prevPropData
		local prevKeyframeData = prevTargetTrack.keyframes[selectedInfo.frame]
		selectedInfo.marker.BackgroundColor3 = if prevKeyframeData.Easing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
		table.remove(currentSelection.data, selectionIndex)
	elseif not alreadySelected then
		-- Tambahkan ke seleksi
		table.insert(currentSelection.data, kfInfo)
		keyframeMarker.BackgroundColor3 = Config.Colors.KeyframeSelected
	end

	-- Perbarui tampilan properti hanya jika satu keyframe dipilih
	if #currentSelection.data == 1 then
		local info = currentSelection.data[1]
		local data = animationData[info.object].Properties[info.property]
		local track = info.component and data.Components[info.component] or data
		updatePropertyDisplay(track.keyframes[info.frame], info.component or info.property, nil)
	else
		updatePropertyDisplay(nil, nil, nil) -- Sembunyikan jika lebih dari satu dipilih
	end
end

function openContextMenu(target, options)
	contextMenuTarget = target
	local menu = ui.contextMenu.frame

	-- Hapus opsi lama
	for _, child in ipairs(menu:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end

	-- Buat tombol baru
	for i, optionData in ipairs(options) do
		local itemButton = Instance.new("TextButton")
		itemButton.Name = optionData.Text
		itemButton.Text = "  " .. optionData.Text
		itemButton.Size = UDim2.new(1, 0, 0, 26)
		itemButton.BackgroundColor3 = Config.Colors.ButtonSecondary
		itemButton.TextColor3 = Config.Colors.TextSecondary
		itemButton.Font = Enum.Font.SourceSans
		itemButton.TextXAlignment = Enum.TextXAlignment.Left
		itemButton.LayoutOrder = i
		itemButton.Parent = menu

		itemButton.MouseButton1Click:Connect(function()
			menu.Visible = false
			optionData.Callback(target)
		end)
	end

	-- Sesuaikan ukuran dan posisi
	local numItems = #options
	menu.Size = UDim2.new(0, 150, 0, numItems * 28)

	local mousePos = inputService:GetMouseLocation()
	menu.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)

	menu.Visible = true
end

function updateKeyframeValue(newValue, componentType, axis)
	local kfInfo
	if currentSelection.type == "Keyframe" and #currentSelection.data == 1 then
		kfInfo = currentSelection.data[1]
	elseif currentSelection.type == "Event" and #currentSelection.data == 1 then
		local eventInfo = currentSelection.data[1]
		local eventTrack = animationData[eventInfo.object].Events
		local eventData = eventTrack.keyframes[eventInfo.frame]
		if not eventData then return end

		local oldName = eventData.Name
		local newName = tostring(newValue)
		if oldName == newName or newName == "" then return end

		local action = {
			redo = function()
				animationData[eventInfo.object].Events.keyframes[eventInfo.frame].Name = newName
				updatePropertyDisplay(nil, nil, { Name = newName })
			end,
			undo = function()
				animationData[eventInfo.object].Events.keyframes[eventInfo.frame].Name = oldName
				updatePropertyDisplay(nil, nil, { Name = oldName })
			end
		}
		ActionHistory.register(action)
		action.redo()
		return -- Event name updated, exit function
	else
		return
	end

	local val
	if typeof(newValue) == "string" then
		val = tonumber(newValue)
		if not val then return end
	else
		val = newValue -- For direct value updates (e.g., boolean, color)
	end

	local propData = animationData[kfInfo.object].Properties[kfInfo.property]
	if not propData then return end

	local keyframe = propData.keyframes[kfInfo.frame]
	if not keyframe then return end

	local oldValue = keyframe.Value
	local finalNewValue

	if kfInfo.property == "CFrame" then
		local oldCFrame = oldValue
		local newPos = oldCFrame.Position
		local newRot = Vector3.new(oldCFrame:ToEulerAnglesYXZ())

		if componentType == "Position" then
			newPos = Vector3.new(
				axis == "X" and val or newPos.X,
				axis == "Y" and val or newPos.Y,
				axis == "Z" and val or newPos.Z
			)
		elseif componentType == "Rotation" then
			newRot = Vector3.new(
				axis == "X" and math.rad(val) or newRot.X,
				axis == "Y" and math.rad(val) or newRot.Y,
				axis == "Z" and math.rad(val) or newRot.Z
			)
		end
		finalNewValue = CFrame.new(newPos) * CFrame.fromEulerAnglesYXZ(newRot.Y, newRot.X, newRot.Z)

	elseif typeof(oldValue) == "number" and axis == "X" then
		finalNewValue = val
	elseif typeof(oldValue) == "Vector3" then
		finalNewValue = Vector3.new(
			axis == "X" and val or oldValue.X,
			axis == "Y" and val or oldValue.Y,
			axis == "Z" and val or oldValue.Z
		)
	elseif typeof(oldValue) == "Color3" then
		if typeof(val) == "Color3" then
			finalNewValue = val
		else
			finalNewValue = Color3.new(
				axis == "R" and val or oldValue.R,
				axis == "G" and val or oldValue.G,
				axis == "B" and val or oldValue.B
			)
		end
	elseif typeof(oldValue) == "UDim2" then
		finalNewValue = UDim2.new(
			axis == "XS" and val or oldValue.X.Scale,
			axis == "XO" and val or oldValue.X.Offset,
			axis == "YS" and val or oldValue.Y.Scale,
			axis == "YO" and val or oldValue.Y.Offset
		)
	elseif typeof(oldValue) == "boolean" then
		finalNewValue = val
	end

	if finalNewValue == nil or finalNewValue == oldValue then return end

	local action = {
		redo = function()
			local kf = animationData[kfInfo.object].Properties[kfInfo.property].keyframes[kfInfo.frame]
			kf.Value = finalNewValue
			updatePropertyDisplay(kf, kfInfo.component or kfInfo.property)
			updateAnimationFromPlayhead()
		end,
		undo = function()
			local kf = animationData[kfInfo.object].Properties[kfInfo.property].keyframes[kfInfo.frame]
			kf.Value = oldValue
			updatePropertyDisplay(kf, kfInfo.component or kfInfo.property, nil)
			updateAnimationFromPlayhead()
		end
	}
	ActionHistory.register(action)
	action.redo()
end

function deleteTrack(object, propName)
	local objectData = animationData[object]
	if not objectData then return end

	local trackDataToSave = {}
	local isFullObjectDeletion = not propName

	if isFullObjectDeletion then
		-- Salin seluruh data objek
		trackDataToSave = animationData[object]
	elseif objectData.Properties[propName] and propName ~= "CFrame" then
		-- Salin hanya data properti spesifik
		trackDataToSave[propName] = objectData.Properties[propName]
	else
		return -- Tidak ada yang dihapus
	end

	local action = {
		redo = function()
			local objData = animationData[object]
			if not objData then return end

			if isFullObjectDeletion then
				for name, _ in pairs(objData.Properties) do
					if name ~= "CFrame" then
						-- Hapus sub-track (hanya UI)
						local subTrackUi = objData.subTrackFrames[name]
						if subTrackUi then
							subTrackUi.label:Destroy()
							subTrackUi.keyframes:Destroy()
						end
					end
				end
				objData.trackFrame:Destroy()
				objData.keyframeContainer:Destroy()
				disconnectAutoKeyListener(object)
				animationData[object] = nil
			else
				local subTrackUi = objData.subTrackFrames[propName]
				if subTrackUi then
					subTrackUi.label:Destroy()
					subTrackUi.keyframes:Destroy()
				end
				objData.Properties[propName] = nil
				objData.subTrackFrames[propName] = nil
			end

			if currentlySelectedTrack.object == object and (isFullObjectDeletion or currentlySelectedTrack.property == propName) then
				currentlySelectedTrack = { object = nil, property = nil, label = nil }
			end
			updateCanvasSize()
		end,
		undo = function()
			if isFullObjectDeletion then
				animationData[object] = trackDataToSave
				-- Buat ulang UI dari data yang disimpan
				createTrackForObject(object, false) -- Buat ulang trek utama
				for name, propData in pairs(trackDataToSave.Properties) do
					if name ~= "CFrame" then
						createTrackForObject(object, true, name) -- Buat ulang sub-trek
						-- Buat ulang keyframe marker untuk sub-trek
						for frame, _ in pairs(propData.keyframes) do
							createKeyframeMarkerUI(object, name, frame, nil)
						end
					end
				end
				-- Buat ulang keyframe marker untuk trek CFrame
				for frame, _ in pairs(trackDataToSave.Properties.CFrame.keyframes) do
					createKeyframeMarkerUI(object, "CFrame", frame, nil)
				end
				connectAutoKeyListener(object)
			else
				local objData = animationData[object]
				objData.Properties[propName] = trackDataToSave[propName]
				createTrackForObject(object, true, propName)
				for frame, _ in pairs(trackDataToSave[propName].keyframes) do
					createKeyframeMarkerUI(object, propName, frame, nil)
				end
			end
			updateCanvasSize()
		end
	}

	ActionHistory.register(action)
	action.redo()
end

function lerp(a, b, alpha)
	local dataType = typeof(a)
	if dataType == "number" then
		return a + (b - a) * alpha
	elseif dataType == "Vector3" then
		return a:Lerp(b, alpha)
	elseif dataType == "CFrame" then
		return a:Lerp(b, alpha)
	elseif dataType == "Color3" then
		return a:Lerp(b, alpha)
	elseif dataType == "UDim2" then
		return a:Lerp(b, alpha)
	elseif dataType == "boolean" then
		return if alpha < 1 then a else b -- Perilaku "step", berubah di akhir
	else
		return a -- Tidak mendukung interpolasi, kembalikan nilai awal
	end
end

function clearTimeline()
	for _, child in ipairs(ui.trackListFrame:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UIListLayout") then child:Destroy() end
	end
	for _, child in ipairs(ui.keyframeTracksContainer:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UIListLayout") then child:Destroy() end
	end
	animationData = {}
	selectedKeyframes = {}
	currentlySelectedTrack = { object = nil, property = nil, label = nil }
	updatePropertyDisplay(nil)
	updateCanvasSize()
	ui.playhead.Position = UDim2.new(0, 0, 0, 0)
end

function createTrackForObject(object, isSubTrack, propName)
	if not isSubTrack and animationData[object] then return end

	if not isSubTrack then
		print("Membuat track untuk: " .. object.Name)
		animationData[object] = {
			Properties = {
				CFrame = { keyframes = {}, markers = {} }
			},
			Events = { keyframes = {}, markers = {} }, -- Tambahkan struktur data untuk Events
			trackFrame = nil,
			subTrackFrames = {},
		}
		connectAutoKeyListener(object)
	end

	local trackLabelHolder = Instance.new("TextButton")
	trackLabelHolder.Name = (propName or object.Name) .. "_TrackLabel"
	trackLabelHolder.Size = UDim2.new(1, 0, 0, Config.TRACK_HEIGHT)
	trackLabelHolder.BackgroundColor3 = isSubTrack and Config.Colors.SubTrackLabelBackground or Config.Colors.TrackListBackground
	trackLabelHolder.BorderSizePixel = 1
	trackLabelHolder.BorderColor3 = Config.Colors.ContentBackground
	trackLabelHolder.Text = ""
	trackLabelHolder.AutoButtonColor = false
	trackLabelHolder.Parent = ui.trackListFrame

	local trackLabel = Instance.new("TextLabel")
	trackLabel.Position = UDim2.new(0, isSubTrack and 15 or 5, 0, 0)
	trackLabel.Text = propName or object.Name
	trackLabel.Font = Enum.Font.SourceSans
	trackLabel.TextSize = 14
	trackLabel.TextColor3 = Config.Colors.TextSecondary
	trackLabel.BackgroundTransparency = 1
	trackLabel.TextXAlignment = Enum.TextXAlignment.Left
	trackLabel.Parent = trackLabelHolder

	local deleteTrackButton = Instance.new("TextButton")
	deleteTrackButton.Name = "DeleteTrackButton"
	deleteTrackButton.Size = UDim2.new(0, 20, 0, 20)
	deleteTrackButton.Position = UDim2.new(1, -25, 0.5, -10)
	deleteTrackButton.Text = "X"
	deleteTrackButton.Font = Enum.Font.SourceSansBold
	deleteTrackButton.TextSize = 14
	deleteTrackButton.TextColor3 = Config.Colors.TextMuted
	deleteTrackButton.BackgroundColor3 = Config.Colors.ButtonDelete
	deleteTrackButton.Parent = trackLabelHolder

	deleteTrackButton.MouseButton1Click:Connect(function()
		local trackName = isSubTrack and propName or object.Name
		local title = "Hapus Track"
		local message = "Apakah Anda yakin ingin menghapus track '" .. trackName .. "'? Tindakan ini tidak dapat diurungkan."

		showConfirmation(title, message, function()
			-- Jika ini sub-track, berikan nama propertinya. Jika tidak, kirim nil untuk menghapus seluruh objek.
			deleteTrack(object, isSubTrack and propName or nil)
		end)
	end)

	if not isSubTrack then
		trackLabel.Size = UDim2.new(1, -55, 1, 0) -- Space for add and delete buttons

		local addPropButton = Instance.new("TextButton")
		addPropButton.Size = UDim2.new(0, 20, 0, 20)
		addPropButton.Position = UDim2.new(1, -50, 0.5, -10) -- To the left of delete button
		addPropButton.Text = "+"
		addPropButton.Font = Enum.Font.SourceSansBold
		addPropButton.TextSize = 16
		addPropButton.Parent = trackLabelHolder

		addPropButton.MouseButton1Click:Connect(function()
			-- Hapus item menu sebelumnya
			for _, child in ipairs(ui.propMenu.list:GetChildren()) do
				if not child:IsA("UIListLayout") then
					child:Destroy()
				end
			end
			ui.propMenu.searchBox.Text = ""

			-- Daftar properti yang dapat dianimasikan berdasarkan ClassName (versi diperluas)
			local animatablePropertiesByClass = {
				BasePart = {"Size", "Color", "Transparency", "Reflectance", "Position", "Orientation"},
				Decal = {"Color3", "Transparency"},
				Frame = {"BackgroundColor3", "BackgroundTransparency", "BorderColor3", "Position", "Size", "Rotation", "Visible", "ZIndex"},
				TextLabel = {"TextColor3", "TextTransparency", "TextStrokeColor3", "TextStrokeTransparency", "BackgroundColor3", "BackgroundTransparency", "BorderColor3", "Position", "Size", "Rotation", "Visible", "ZIndex"},
				TextButton = {"TextColor3", "TextTransparency", "TextStrokeColor3", "TextStrokeTransparency", "BackgroundColor3", "BackgroundTransparency", "BorderColor3", "Position", "Size", "Rotation", "Visible", "ZIndex"},
				ImageLabel = {"ImageColor3", "ImageTransparency", "BackgroundColor3", "BackgroundTransparency", "BorderColor3", "Position", "Size", "Rotation", "Visible", "ZIndex"},
				ImageButton = {"ImageColor3", "ImageTransparency", "BackgroundColor3", "BackgroundTransparency", "BorderColor3", "Position", "Size", "Rotation", "Visible", "ZIndex"},
				Light = {"Brightness", "Color", "Range", "Enabled"},
				PointLight = {"Brightness", "Color", "Range", "Enabled"},
				SpotLight = {"Angle", "Brightness", "Color", "Face", "Range", "Enabled"},
				SurfaceLight = {"Angle", "Brightness", "Color", "Face", "Range", "Enabled"},
				ParticleEmitter = {"Acceleration", "Color", "Drag", "Lifetime", "LightEmission", "LightInfluence", "LockedToPart", "Rate", "Rotation", "RotSpeed", "Size", "Speed", "SpreadAngle", "Transparency", "VelocitySpread", "ZOffset", "Enabled"},
				Trail = {"Color", "Lifetime", "LightEmission", "LightInfluence", "Transparency", "WidthScale"}
			}

			local supportedValueTypes = { "Vector3", "Color3", "number", "boolean", "UDim2" }
			local propsToShow = {}

			-- Kumpulkan properti berdasarkan hierarki kelas objek
			for className, props in pairs(animatablePropertiesByClass) do
				if object:IsA(className) then
					for _, propName in ipairs(props) do
						propsToShow[propName] = true -- Gunakan tabel sebagai set untuk menghindari duplikat
					end
				end
			end

			-- Urutkan properti berdasarkan abjad
			local sortedPropNames = {}
			for name, _ in pairs(propsToShow) do
				table.insert(sortedPropNames, name)
			end
			table.sort(sortedPropNames)

			-- Buat tombol untuk setiap properti unik yang ditemukan
			for _, propName in ipairs(sortedPropNames) do
				local success, value = pcall(function() return object[propName] end)
				if success then
					local propType = typeof(value)
					if table.find(supportedValueTypes, propType) then
						local propButton = Instance.new("TextButton")
						propButton.Name = propName
						propButton.Text = "  " .. propName .. " (" .. propType .. ")"
						propButton.Size = UDim2.new(1, 0, 0, 24)
						propButton.BackgroundColor3 = Config.Colors.ButtonSecondary
						propButton.TextColor3 = Config.Colors.TextSecondary
						propButton.Font = Enum.Font.SourceSans
						propButton.TextXAlignment = Enum.TextXAlignment.Left
						propButton.Parent = ui.propMenu.list

						propButton.MouseButton1Click:Connect(function()
							if object and not animationData[object].Properties[propName] then
								local action = {
									redo = function()
										animationData[object].Properties[propName] = { 
											keyframes = {}, 
											markers = {},
											Components = {},
											ComponentTracks = {},
											IsExpanded = false,
											ValueType = propType
										}
										createTrackForObject(object, true, propName)
										updateCanvasSize()
									end,
									undo = function()
										deleteTrack(object, propName)
									end
								}
								ActionHistory.register(action)
								action.redo()
							end
							ui.propMenu.frame.Visible = false
						end)
					end
				end
			end

			-- Atur posisi dan tampilkan menu properti
			objectForPropMenu = object
			local numItems = #ui.propMenu.list:GetChildren() - 1
			local listHeight = math.min(numItems * 26, 250 - 32)
			ui.propMenu.frame.Size = UDim2.new(0, 180, 0, listHeight + 32)
			ui.propMenu.frame.Position = UDim2.new(0, addPropButton.AbsolutePosition.X - 180, 0, addPropButton.AbsolutePosition.Y + 25)
			ui.propMenu.frame.Visible = true
		end)
	else
		local expandableTypes = {Vector3 = {"X", "Y", "Z"}, Color3 = {"R", "G", "B"}, UDim2 = {"XScale", "XOffset", "YScale", "YOffset"}}
		local propData = animationData[object] and animationData[object].Properties[propName]
		local isExpandable = propData and expandableTypes[propData.ValueType]

		if isExpandable then
			trackLabel.Size = UDim2.new(1, -55, 1, 0) -- Sisakan ruang untuk tombol expand dan delete

			local expandButton = Instance.new("TextButton")
			expandButton.Name = "ExpandButton"
			expandButton.Size = UDim2.new(0, 20, 0, 20)
			expandButton.Position = UDim2.new(0, 5, 0.5, -10)
			expandButton.Text = ">"
			expandButton.Font = Enum.Font.SourceSansBold
			expandButton.TextSize = 14
			expandButton.TextColor3 = Config.Colors.TextMuted
			expandButton.BackgroundTransparency = 1
			expandButton.Parent = trackLabelHolder

			trackLabel.Position = UDim2.new(0, 25, 0, 0) -- Geser teks properti

			expandButton.MouseButton1Click:Connect(function()
				propData.IsExpanded = not propData.IsExpanded
				expandButton.Text = propData.IsExpanded and "v" or ">"

				if propData.IsExpanded then
					local components = expandableTypes[propData.ValueType]
					for i, compName in ipairs(components) do
						local componentTrackName = propName .. "." .. compName
						local compTrackLabel, compKeyframeTrack = createTrackForObject(object, true, componentTrackName)
						propData.ComponentTracks[compName] = {label = compTrackLabel, keyframes = compKeyframeTrack}

						-- Buat marker UI untuk keyframe yang sudah ada dari proses load
						if propData.Components[compName] then
							for frame, _ in pairs(propData.Components[compName].keyframes) do
								createKeyframeMarkerUI(object, propName, frame, compName)
							end
						end
					end
				else
					for compName, trackUI in pairs(propData.ComponentTracks) do
						trackUI.label:Destroy()
						trackUI.keyframes:Destroy()
					end
					propData.ComponentTracks = {}
				end
				updateCanvasSize()
			end)
		else
			trackLabel.Size = UDim2.new(1, -30, 1, 0) -- Hanya ruang untuk tombol delete
		end
	end

	local keyframeTrack = Instance.new("Frame")
	keyframeTrack.Name = (propName or object.Name) .. "_KeyframeTrack"
	keyframeTrack.Size = UDim2.new(1, 0, 0, Config.TRACK_HEIGHT)
	keyframeTrack.BackgroundColor3 = isSubTrack and Config.Colors.SubTrackBackground or Config.Colors.TrackBackground
	keyframeTrack.BorderSizePixel = 0
	keyframeTrack.ClipsDescendants = true
	keyframeTrack.Parent = ui.keyframeTracksContainer

	-- Tambahkan UI untuk Event Track jika ini adalah trek objek utama
	if not isSubTrack then
		local eventTrackLabel = Instance.new("TextLabel")
		eventTrackLabel.Name = object.Name .. "_EventTrackLabel"
		eventTrackLabel.Size = UDim2.new(1, 0, 0, Config.TRACK_HEIGHT)
		eventTrackLabel.BackgroundColor3 = Config.Colors.SubTrackLabelBackground
		eventTrackLabel.BorderSizePixel = 1
		eventTrackLabel.BorderColor3 = Config.Colors.ContentBackground
		eventTrackLabel.Text = "  Events"
		eventTrackLabel.Font = Enum.Font.SourceSansItalic
		eventTrackLabel.TextColor3 = Config.Colors.TextMuted
		eventTrackLabel.TextXAlignment = Enum.TextXAlignment.Left
		eventTrackLabel.LayoutOrder = trackLabelHolder.LayoutOrder + 1 -- Tepat di bawah trek utama
		eventTrackLabel.Parent = ui.trackListFrame

		local eventKeyframeTrack = Instance.new("Frame")
		eventKeyframeTrack.Name = object.Name .. "_EventKeyframeTrack"
		eventKeyframeTrack.Size = UDim2.new(1, 0, 0, Config.TRACK_HEIGHT)
		eventKeyframeTrack.BackgroundColor3 = Config.Colors.SubTrackBackground
		eventKeyframeTrack.BorderSizePixel = 0
		eventKeyframeTrack.ClipsDescendants = true
		eventKeyframeTrack.LayoutOrder = keyframeTrack.LayoutOrder + 1 -- Tepat di bawah trek utama
		eventKeyframeTrack.Parent = ui.keyframeTracksContainer

		-- Simpan referensi ke UI trek event
		animationData[object].eventTrackUI = {
			label = eventTrackLabel,
			keyframes = eventKeyframeTrack
		}

		eventKeyframeTrack.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * zoomLevel
				local mouseX = input.Position.X - eventKeyframeTrack.AbsolutePosition.X + ui.keyframeAreaFrame.CanvasPosition.X
				local frame = math.floor(mouseX / pixelsPerFrame)

				local options = {
					{ Text = "Add Event", Callback = function(target)
						local action = {
							redo = function()
								createEventMarkerUI(target.object, target.frame, "NewEvent")
								updateTimelineRuler()
							end,
							undo = function()
								local eventTrack = animationData[target.object].Events
								if eventTrack.markers[target.frame] then
									eventTrack.markers[target.frame]:Destroy()
									eventTrack.markers[target.frame] = nil
									eventTrack.keyframes[target.frame] = nil
								end
								updateTimelineRuler()
							end
						}
						ActionHistory.register(action)
						action.redo()
					end }
				}
				openContextMenu({ object = object, frame = frame }, options)
			end
		end)
	end

	trackLabelHolder.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			local trackTarget = { object = object, propName = propName, isSubTrack = isSubTrack }
			local trackName = isSubTrack and propName or object.Name
			local options = {
				{ Text = "Hapus Track", Callback = function(target)
					showConfirmation(
						"Hapus Track",
						"Apakah Anda yakin ingin menghapus track '" .. trackName .. "'?",
						function()
							deleteTrack(target.object, target.isSubTrack and target.propName or nil)
						end
					)
				end }
			}
			openContextMenu(trackTarget, options)
		end
	end)

	trackLabelHolder.MouseButton1Click:Connect(function()
		if currentlySelectedTrack.label then
			currentlySelectedTrack.label.BackgroundColor3 = currentlySelectedTrack.isSub and Config.Colors.SubTrackLabelBackground or Config.Colors.TrackListBackground
		end
		trackLabelHolder.BackgroundColor3 = Config.Colors.TrackSelected
		currentlySelectedTrack = {object = object, property = propName or "CFrame", label = trackLabelHolder, isSub = isSubTrack}
		print("Track dipilih:", currentlySelectedTrack.property)
	end)

	if isSubTrack then
		animationData[object].subTrackFrames[propName] = {label = trackLabelHolder, keyframes = keyframeTrack}
		local mainTrackOrder = animationData[object].trackFrame.LayoutOrder
		trackLabelHolder.LayoutOrder = mainTrackOrder + #animationData[object].subTrackFrames
		keyframeTrack.LayoutOrder = trackLabelHolder.LayoutOrder
	else
		animationData[object].trackFrame = trackLabelHolder
		animationData[object].keyframeContainer = keyframeTrack
		trackLabelHolder.LayoutOrder = (#ui.trackListFrame:GetChildren() - 1) * 10
		keyframeTrack.LayoutOrder = trackLabelHolder.LayoutOrder
	end

	return trackLabelHolder, keyframeTrack
end

-- Hanya menambahkan data keyframe ke tabel animationData
function addKeyframeData(object, mainPropName, frame, value, easing, componentName)
	local objectData = animationData[object]
	local propData = objectData.Properties[mainPropName]

	local targetTrack
	if componentName then
		if not propData.Components[componentName] then
			propData.Components[componentName] = { keyframes = {}, markers = {} }
		end
		targetTrack = propData.Components[componentName]
	else
		targetTrack = propData
	end

	targetTrack.keyframes[frame] = {
		Value = value,
		Easing = easing
	}
	return targetTrack, propData
end

-- Hanya membuat elemen UI untuk keyframe yang datanya sudah ada
function createKeyframeMarkerUI(object, mainPropName, frame, componentName)
	local objectData = animationData[object]
	local propData = objectData.Properties[mainPropName]

	local targetTrack, container
	if componentName then
		targetTrack = propData.Components[componentName]
		container = propData.ComponentTracks[componentName].keyframes
	else
		targetTrack = propData
		container = (mainPropName == "CFrame") and objectData.keyframeContainer or objectData.subTrackFrames[mainPropName].keyframes
	end

	-- Pastikan container UI ada sebelum melanjutkan
	if not container then
		-- This can happen normally if data is added before the UI is expanded.
		-- The UI will be created when the track is expanded.
		return nil
	end

	local keyframeData = targetTrack and targetTrack.keyframes[frame]
	if not keyframeData then return nil end

	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * zoomLevel
	local playheadX = frame * pixelsPerFrame

	local keyframeMarker = Instance.new("TextButton")
	keyframeMarker.Name = tostring(frame)
	keyframeMarker.Text = ""
	keyframeMarker.AnchorPoint = Vector2.new(0.5, 0.5)
	keyframeMarker.Size = UDim2.new(0, 10, 0, 10)
	keyframeMarker.Position = UDim2.new(0, playheadX, 0, Config.TRACK_HEIGHT / 2) 
	keyframeMarker.Rotation = 45
	keyframeMarker.BackgroundColor3 = if keyframeData.Easing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
	keyframeMarker.Parent = container
	targetTrack.markers[frame] = keyframeMarker

	keyframeMarker.MouseButton1Click:Connect(function()
		local kfInfo = { object = object, frame = frame, property = mainPropName, component = componentName, marker = keyframeMarker }
		handleKeyframeSelection(kfInfo)
	end)

	keyframeMarker.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local kfInfo = { object = object, frame = frame, property = mainPropName, component = componentName, marker = keyframeMarker }
			-- Jika keyframe yang diklik tidak ada dalam seleksi, bersihkan seleksi dan pilih hanya yang ini.
			local isClickedInSelection = false
			for _, selected in ipairs(selectedKeyframes) do
				if selected.marker == keyframeMarker then
					isClickedInSelection = true
					break
				end
			end
			if not isClickedInSelection then
				handleKeyframeSelection(kfInfo)
			end

			-- Salin seleksi saat ini untuk operasi penyeretan
			local selectionCopy = {}
			for _, kfInfo in ipairs(selectedKeyframes) do
				table.insert(selectionCopy, {
					object = kfInfo.object,
					originalFrame = kfInfo.frame, -- Simpan posisi frame asli
					property = kfInfo.property,
					component = kfInfo.component,
					marker = kfInfo.marker,
				})
			end

			draggingKeyframeInfo = { 
				selection = selectionCopy,
				originalFrame = frame -- Frame dari keyframe spesifik yang di-klik
			}
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			local keyframeTarget = { object = object, frame = frame, property = mainPropName, component = componentName, marker = keyframeMarker }
			local options = {
				{ Text = "Hapus Keyframe", Callback = function(target)
					-- Hapus data
					local propData = animationData[target.object].Properties[target.property]
					local targetTrack = target.component and propData.Components[target.component] or propData
					targetTrack.keyframes[target.frame] = nil
					targetTrack.markers[target.frame] = nil
					-- Hapus UI
					target.marker:Destroy()
					-- Hapus dari seleksi jika ada
					for i, kfInfo in ipairs(selectedKeyframes) do
						if kfInfo.marker == target.marker then
							table.remove(selectedKeyframes, i)
							break
						end
					end
					updatePropertyDisplay(nil)
					updateTimelineRuler()
				end },
				-- Tambahkan opsi lain di sini di masa mendatang, seperti "Salin", "Tempel", "Ubah Easing"
			}
			openContextMenu(keyframeTarget, options)
		end
	end)

	return keyframeMarker
end


function updateTimelineRuler()
	local maxFrame = 100 -- Default minimum frame count
	for _, objectData in pairs(animationData) do
		for _, propTrack in pairs(objectData.Properties) do
			for frame, _ in pairs(propTrack.keyframes) do
				if frame > maxFrame then
					maxFrame = frame
				end
			end
			-- Juga periksa komponen
			if propTrack.Components then
				for _, compTrack in pairs(propTrack.Components) do
					for frame, _ in pairs(compTrack.keyframes) do
						if frame > maxFrame then
							maxFrame = frame
						end
					end
				end
			end
		end
	end

	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * zoomLevel
	local newWidth = (maxFrame + Config.FRAMES_PER_INTERVAL * 2) * pixelsPerFrame -- Tambahkan sedikit padding di akhir

	-- Hanya perbarui CanvasSize.X, biarkan Y diurus oleh updateCanvasSize
	local currentCanvasSize = ui.keyframeAreaFrame.CanvasSize
	ui.keyframeAreaFrame.CanvasSize = UDim2.new(0, newWidth, 0, currentCanvasSize.Y.Offset)

	-- Sesuaikan end handle secara otomatis jika diperlukan
	if ui.playbackRange.endHandle.Position.X.Offset < newWidth then
		ui.playbackRange.endHandle.Position = UDim2.new(0, newWidth, 0, 0)
	end
	if ui.playbackRange.startHandle.Position.X.Offset > newWidth then
		ui.playbackRange.startHandle.Position = UDim2.new(0, newWidth, 0, 0)
	end

	-- Update range frame visual
	local startX = ui.playbackRange.startHandle.Position.X.Offset
	local endX = ui.playbackRange.endHandle.Position.X.Offset
	ui.playbackRange.frame.Position = UDim2.new(0, startX, 0, 0)
	ui.playbackRange.frame.Size = UDim2.new(0, endX - startX, 1, 0)
end

function updateCanvasSize()
	local totalHeight = 0
	for _, child in ipairs(ui.trackListFrame:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UIListLayout") then
			totalHeight = totalHeight + child.AbsoluteSize.Y
		end
	end

	ui.trackListFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
	-- Hanya perbarui CanvasSize.Y, biarkan X diurus oleh updateTimelineRuler
	local currentCanvasSize = ui.keyframeAreaFrame.CanvasSize
	ui.keyframeAreaFrame.CanvasSize = UDim2.new(0, currentCanvasSize.X.Offset, 0, totalHeight)
end

function updatePropertyDisplay(keyframeData, propName, eventData)
	local isKeyframeSelected = (keyframeData ~= nil) or (eventData ~= nil)

	-- Tampilkan atau sembunyikan placeholder
	ui.placeholderLabel.Visible = not isKeyframeSelected

	-- Tampilkan atau sembunyikan kontrol properti
	ui.easingButton.Visible = isKeyframeSelected
	ui.deleteKeyframeButton.Visible = isKeyframeSelected

	for _, group in pairs(ui.propertyLabels) do
		for _, item in pairs(group) do
			if item:IsA("GuiObject") and item.Parent.Name ~= "Properties" then
				item.Parent.Visible = false
			end
		end
	end

	if not keyframeData then return end

	local value = keyframeData.Value
	local valueType = typeof(value)
	local function format(num) return string.format("%.2f", num) end

	if propName == "CFrame" then
		local cframeLabels = ui.propertyLabels.cframe
		cframeLabels.posHolder.Visible = true
		cframeLabels.posXHolder.Visible = true
		cframeLabels.posYHolder.Visible = true
		cframeLabels.posZHolder.Visible = true
		cframeLabels.rotHolder.Visible = true
		cframeLabels.rotXHolder.Visible = true
		cframeLabels.rotYHolder.Visible = true
		cframeLabels.rotZHolder.Visible = true

		local pos = value.Position
		local rot = Vector3.new(value:ToEulerAnglesYXZ())
		cframeLabels.posX.Text = format(pos.X)
		cframeLabels.posY.Text = format(pos.Y)
		cframeLabels.posZ.Text = format(pos.Z)
		cframeLabels.rotX.Text = format(math.deg(rot.X))
		cframeLabels.rotY.Text = format(math.deg(rot.Y))
		cframeLabels.rotZ.Text = format(math.deg(rot.Z))
	elseif valueType == "Color3" then
		local colorLabels = ui.propertyLabels.color3
		colorLabels.holder.Visible = true
		colorLabels.nameLabel.Text = propName
		colorLabels.swatch.BackgroundColor3 = value
	elseif valueType == "UDim2" then
		local udimLabels = ui.propertyLabels.udim2
		udimLabels.holder.Visible = true
		udimLabels.xsHolder.Visible = true
		udimLabels.xoHolder.Visible = true
		udimLabels.ysHolder.Visible = true
		udimLabels.yoHolder.Visible = true
		udimLabels.xs.Text = format(value.X.Scale)
		udimLabels.xo.Text = tostring(value.X.Offset)
		udimLabels.ys.Text = format(value.Y.Scale)
		udimLabels.yo.Text = tostring(value.Y.Offset)
	elseif valueType == "boolean" then
		local boolLabels = ui.propertyLabels.boolean
		boolLabels.holder.Visible = true
		boolLabels.nameLabel.Text = propName
		boolLabels.checkbox.Text = value and "✓" or ""
	else -- Fallback untuk number dan Vector3
		local genericLabels = ui.propertyLabels.generic
		genericLabels.holder.Visible = true
		genericLabels.nameLabel.Text = propName

		if valueType == "number" then
			genericLabels.xHolder.Visible = true
			genericLabels.x.Text = format(value)
			genericLabels.yHolder.Visible = false
			genericLabels.zHolder.Visible = false
		elseif valueType == "Vector3" then
			genericLabels.xHolder.Visible = true
			genericLabels.yHolder.Visible = true
			genericLabels.zHolder.Visible = true
			genericLabels.x.Text = format(value.X)
			genericLabels.y.Text = format(value.Y)
			genericLabels.z.Text = format(value.Z)
		end
	end

	if eventData then
		local genericLabels = ui.propertyLabels.generic
		genericLabels.holder.Visible = true
		genericLabels.nameLabel.Text = "Event Name"
		genericLabels.xHolder.Visible = true
		genericLabels.x.Text = eventData.Name
		genericLabels.yHolder.Visible = false
		genericLabels.zHolder.Visible = false
		ui.deleteKeyframeButton.Visible = true -- Re-use delete button for events
	elseif keyframeData then
		ui.easingButton.Text = "Easing: " .. keyframeData.Easing
	end
end

function updateAnimationFromPlayhead()
	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * zoomLevel
	local playheadX = ui.playhead.Position.X.Offset
	local currentFrame = math.floor(playheadX / pixelsPerFrame)

	for object, objectAnimData in pairs(animationData) do
		if not object or not object.Parent then continue end

		for propName, propData in pairs(objectAnimData.Properties) do
			local finalValue

			-- Fungsi helper untuk menginterpolasi nilai dari sebuah track
			local function getInterpolatedValue(track, defaultValue)
				local sortedFrames = {}
				for frameNumber, _ in pairs(track.keyframes) do table.insert(sortedFrames, frameNumber) end
				table.sort(sortedFrames)

				if #sortedFrames == 0 then return defaultValue end

				local prevFrame, nextFrame
				if currentFrame < sortedFrames[1] then prevFrame, nextFrame = sortedFrames[1], sortedFrames[1]
				elseif currentFrame >= sortedFrames[#sortedFrames] then prevFrame, nextFrame = sortedFrames[#sortedFrames], sortedFrames[#sortedFrames]
				else
					for i = 1, #sortedFrames - 1 do
						if sortedFrames[i] <= currentFrame and sortedFrames[i+1] > currentFrame then
							prevFrame, nextFrame = sortedFrames[i], sortedFrames[i+1]; break
						end
					end
				end

				if prevFrame and nextFrame then
					local kf1 = track.keyframes[prevFrame]
					local kf2 = track.keyframes[nextFrame]
					if prevFrame == nextFrame then return kf1.Value end

					local alpha = (currentFrame - prevFrame) / (nextFrame - prevFrame)
					local easing = EasingFunctions[kf1.Easing] or EasingFunctions.Linear
					return lerp(kf1.Value, kf2.Value, easing(alpha))
				end
				return defaultValue
			end

			local expandableTypes = {Vector3 = {"X", "Y", "Z"}, Color3 = {"R", "G", "B"}, UDim2 = {"XScale", "XOffset", "YScale", "YOffset"}}
			local components = expandableTypes[propData.ValueType]

			if not components then
				-- Logika asli untuk properti yang tidak dapat diperluas
				finalValue = getInterpolatedValue(propData, object[propName])
			else
				-- Logika baru untuk properti dengan komponen
				local componentValues = {}
				local mainTrackValue = getInterpolatedValue(propData, object[propName])

				for _, compName in ipairs(components) do
					local compTrack = propData.Components[compName]
					if compTrack then
						-- Jika ada track komponen, interpolasi nilainya
						componentValues[compName] = getInterpolatedValue(compTrack, mainTrackValue and mainTrackValue[compName])
					else
						-- Jika tidak ada track komponen, gunakan nilai dari track utama
						componentValues[compName] = mainTrackValue and mainTrackValue[compName]
					end
				end

				-- Bangun kembali nilai utuh dari komponen
				if propData.ValueType == "Vector3" then
					finalValue = Vector3.new(componentValues.X, componentValues.Y, componentValues.Z)
				elseif propData.ValueType == "Color3" then
					finalValue = Color3.new(componentValues.R, componentValues.G, componentValues.B)
				elseif propData.ValueType == "UDim2" then
					finalValue = UDim2.new(componentValues.XScale, componentValues.XOffset, componentValues.YScale, componentValues.YOffset)
				end
			end

			if finalValue then
				object[propName] = finalValue
			end
		end
	end
end

function onHeartbeat(deltaTime)
	if not isPlaying then return end

	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * zoomLevel
	local pixelsPerSecond = pixelsPerFrame * Config.FRAMES_PER_SECOND * playbackSpeed

	local currentX = ui.playhead.Position.X.Offset
	local newX = currentX + (pixelsPerSecond * deltaTime)

	local startX = ui.playbackRange.startHandle.Position.X.Offset
	local endX = ui.playbackRange.endHandle.Position.X.Offset

	if newX >= endX then
		if isLoopingEnabled then
			newX = startX
		else
			newX = endX
			isPlaying = false
			print("Playback selesai.")
		end
	end

	ui.playhead.Position = UDim2.new(0, newX, 0, 0)
	updateAnimationFromPlayhead()
end

function updateSelectedObjectLabel()
	local selectedObjects = selection:Get()
	if #selectedObjects > 0 then
		if selectedObjects[1] ~= currentlySelectedObject then
			currentlySelectedObject = selectedObjects[1]
			ui.selectedObjectLabel.Text = "Terpilih: " .. currentlySelectedObject.Name
		end
	else
		currentlySelectedObject = nil
		ui.selectedObjectLabel.Text = "Tidak ada objek yang dipilih"
	end
end

local function redrawTimeline()
	-- Hapus marker ruler yang lama
	for _, child in ipairs(ui.timelineRuler:GetChildren()) do
		if child.Name:find("RulerMarker") then
			child:Destroy()
		end
	end

	-- Gambar ulang ruler dengan zoom baru
	local pixelsPerInterval = Config.PIXELS_PER_FRAME_INTERVAL * zoomLevel
	for i = 0, 200 do
		local position = i * pixelsPerInterval
		local frameNumber = i * Config.FRAMES_PER_INTERVAL
		local timeInSeconds = frameNumber / Config.FRAMES_PER_SECOND

		local marker = Instance.new("Frame")
		marker.Name = "RulerMarker"
		marker.Size = UDim2.new(0, 1, 1, 0)
		marker.Position = UDim2.new(0, position, 0, 0)
		marker.BackgroundColor3 = Config.Colors.Separator
		marker.BorderSizePixel = 0
		marker.Parent = ui.timelineRuler

		-- Logic for labels remains the same, just parented to the new marker
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

	-- Posisikan ulang semua keyframe yang ada
	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * zoomLevel
	for _, objectData in pairs(animationData) do
		for _, propData in pairs(objectData.Properties) do
			local function reposition(track)
				if not track then return end
				for frame, marker in pairs(track.markers) do
					if marker and marker.Parent then
						marker.Position = UDim2.new(0, frame * pixelsPerFrame, 0.5, 0)
					end
				end
			end
			reposition(propData)
			if propData.Components then
				for _, compData in pairs(propData.Components) do
					reposition(compData)
				end
			end
		end
	end

	updateTimelineRuler() -- Perbarui ukuran kanvas
end


-- === EVENT CONNECTIONS & INITIALIZATION ===

ui.zoomInButton.MouseButton1Click:Connect(function()
	zoomLevel = math.clamp(zoomLevel * 1.5, 0.2, 5)
	redrawTimeline()
end)

ui.zoomOutButton.MouseButton1Click:Connect(function()
	zoomLevel = math.clamp(zoomLevel / 1.5, 0.2, 5)
	redrawTimeline()
end)

ui.saveButton.MouseButton1Click:Connect(function()
	ui.saveDialog.gui.Enabled = true
end)

ui.saveDialog.cancelButton.MouseButton1Click:Connect(function()
	ui.saveDialog.gui.Enabled = false
end)

ui.saveDialog.confirmButton.MouseButton1Click:Connect(function()
	local animName = ui.saveDialog.nameBox.Text
	if animName == "" or animName:match("^%s*$") then
		print("Superior Animator: Nama animasi tidak boleh kosong.")
		return
	end

	local serializableData = { Objects = {} }
	for object, data in pairs(animationData) do
		local path = object:GetFullName()
		local properties = {}
		for propName, propTrack in pairs(data.Properties) do
			local keyframes = {}
			for frame, keyframeData in pairs(propTrack.keyframes) do

				local valueToSave
				local valueType = typeof(keyframeData.Value)
				if valueType == "CFrame" then
					valueToSave = {vType="CFrame", comps={keyframeData.Value:GetComponents()}}
				elseif valueType == "Vector3" then
					local v = keyframeData.Value
					valueToSave = {vType="Vector3", x=v.X, y=v.Y, z=v.Z}
				elseif valueType == "number" then
					valueToSave = {vType="number", val=keyframeData.Value}
				elseif valueType == "Color3" then
					local c = keyframeData.Value
					valueToSave = {vType="Color3", r=c.R, g=c.G, b=c.B}
				elseif valueType == "UDim2" then
					local u = keyframeData.Value
					valueToSave = {vType="UDim2", xs=u.X.Scale, xo=u.X.Offset, ys=u.Y.Scale, yo=u.Y.Offset}
				elseif valueType == "boolean" then
					valueToSave = {vType="boolean", val=keyframeData.Value}
				end

				if valueToSave then
					keyframes[tostring(frame)] = {
						Value = valueToSave,
						Easing = keyframeData.Easing
					}
				end
			end

			local components = {}
			if data.Properties[propName].Components then
				for compName, compTrack in pairs(data.Properties[propName].Components) do
					local compKeyframes = {}
					for frame, keyframeData in pairs(compTrack.keyframes) do
						compKeyframes[tostring(frame)] = {
							Value = {vType="number", val=keyframeData.Value}, -- Komponen selalu angka
							Easing = keyframeData.Easing
						}
					end
					components[compName] = { Keyframes = compKeyframes }
				end
			end

			properties[propName] = { Keyframes = keyframes, Components = components, ValueType = data.Properties[propName].ValueType }
		end
		serializableData.Objects[path] = { Properties = properties }
	end

	local function tableToString(tbl, indent)
		indent = indent or 0
		local str = "{\n"
		local indentStr = string.rep("\t", indent + 1)
		for k, v in pairs(tbl) do
			local keyStr
			if typeof(k) == "string" then
				keyStr = string.format("[\"%s\"]", k)
			else
				keyStr = string.format("[%s]", tostring(k))
			end

			if typeof(v) == "table" then
				str = str .. indentStr .. keyStr .. " = " .. tableToString(v, indent + 1) .. ",\n"
			elseif typeof(v) == "string" then
				str = str .. indentStr .. keyStr .. " = " .. string.format("%q", v) .. ",\n"
			else
				str = str .. indentStr .. keyStr .. " = " .. tostring(v) .. ",\n"
			end
		end
		return str .. string.rep("\t", indent) .. "}"
	end

	local moduleSource = "return " .. tableToString(serializableData)

	local savesFolder = ServerStorage:FindFirstChild("SuperiorAnimator_Saves")
	if not savesFolder then
		savesFolder = Instance.new("Folder")
		savesFolder.Name = "SuperiorAnimator_Saves"
		savesFolder.Parent = ServerStorage
	end

	local newAnimModule = Instance.new("ModuleScript")
	newAnimModule.Name = animName
	newAnimModule.Source = moduleSource
	newAnimModule.Parent = savesFolder

	print("Superior Animator: Animasi '" .. animName .. "' berhasil disimpan!")
	ui.saveDialog.gui.Enabled = false
end)

ui.loadButton.MouseButton1Click:Connect(function()
	for _, child in ipairs(ui.loadDialog.list:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end

	local savesFolder = ServerStorage:FindFirstChild("SuperiorAnimator_Saves")
	if not savesFolder then return end

	for _, animModule in ipairs(savesFolder:GetChildren()) do
		if animModule:IsA("ModuleScript") then
			local itemFrame = Instance.new("Frame")
			itemFrame.Name = animModule.Name .. "_Item"
			itemFrame.Size = UDim2.new(1, 0, 0, 30)
			itemFrame.BackgroundTransparency = 1
			itemFrame.Parent = ui.loadDialog.list

			local deleteButton = Instance.new("TextButton")
			deleteButton.Name = "DeleteAnimButton"
			deleteButton.Size = UDim2.new(0, 24, 0, 24)
			deleteButton.Position = UDim2.new(1, -24, 0.5, -12)
			deleteButton.Text = "X"
			deleteButton.Font = Enum.Font.SourceSansBold
			deleteButton.TextColor3 = Config.Colors.TextMuted
			deleteButton.BackgroundColor3 = Config.Colors.ButtonDelete
			deleteButton.Parent = itemFrame

			local animButton = Instance.new("TextButton")
			animButton.Name = animModule.Name
			animButton.Text = animModule.Name
			animButton.Size = UDim2.new(1, -30, 1, 0)
			animButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
			animButton.TextColor3 = Color3.fromRGB(220,220,220)
			animButton.Font = Enum.Font.SourceSans
			animButton.TextXAlignment = Enum.TextXAlignment.Left
			animButton.Parent = itemFrame

			deleteButton.MouseButton1Click:Connect(function()
				showConfirmation(
					"Hapus Animasi",
					"Apakah Anda yakin ingin menghapus animasi '" .. animModule.Name .. "' secara permanen?",
					function()
						animModule:Destroy()
						itemFrame:Destroy()
						print("Animasi '" .. animModule.Name .. "' telah dihapus.")
					end
				)
			end)

			animButton.MouseButton1Click:Connect(function()
				clearTimeline()

				local success, loadedData = pcall(require, animModule)
				if not success then
					warn("Gagal memuat data animasi:", loadedData)
					return
				end

				for path, data in pairs(loadedData.Objects) do
					local object = workspace:FindFirstChild(path, true)
					if object then
						createTrackForObject(object, false)

						for propName, propTrackData in pairs(data.Properties) do
							if propName ~= "CFrame" then
								animationData[object].Properties[propName] = { 
									keyframes = {}, markers = {},
									Components = {}, ComponentTracks = {}, IsExpanded = false,
									ValueType = propTrackData.ValueType
								}
								createTrackForObject(object, true, propName)
							end

							-- Muat keyframe utama
							if propTrackData.Keyframes then
								for frameStr, keyframeData in pairs(propTrackData.Keyframes) do
									local frame = tonumber(frameStr)
									local savedValue = keyframeData.Value
									local value
									if savedValue.vType == "CFrame" then value = CFrame.new(unpack(savedValue.comps))
									elseif savedValue.vType == "Vector3" then value = Vector3.new(savedValue.x, savedValue.y, savedValue.z)
									elseif savedValue.vType == "number" then value = savedValue.val
									elseif savedValue.vType == "Color3" then value = Color3.new(savedValue.r, savedValue.g, savedValue.b)
									elseif savedValue.vType == "UDim2" then value = UDim2.new(savedValue.xs, savedValue.xo, savedValue.ys, savedValue.yo)
									elseif savedValue.vType == "boolean" then value = savedValue.val
									end
									if value then
										addKeyframeData(object, propName, frame, value, keyframeData.Easing, nil)
									end
								end
							end

							-- Muat keyframe komponen
							if propTrackData.Components then
								for compName, compTrackData in pairs(propTrackData.Components) do
									for frameStr, keyframeData in pairs(compTrackData.Keyframes) do
										local frame = tonumber(frameStr)
										local value = keyframeData.Value.val -- Komponen selalu angka
										addKeyframeData(object, propName, frame, value, keyframeData.Easing, compName)
									end
								end
							end
						end
					else
						warn("Superior Animator: Objek tidak ditemukan di path: " .. path)
					end
				end
				updateCanvasSize()
				ui.loadDialog.gui.Enabled = false
			end)
		end
	end

	ui.loadDialog.gui.Enabled = true
end)

ui.loadDialog.cancelButton.MouseButton1Click:Connect(function()
	ui.loadDialog.gui.Enabled = false
end)

ui.exportButton.MouseButton1Click:Connect(function()
	ui.exportDialog.gui.Enabled = true
end)

ui.exportDialog.cancelButton.MouseButton1Click:Connect(function()
	ui.exportDialog.gui.Enabled = false
end)

ui.exportDialog.confirmButton.MouseButton1Click:Connect(function()
	local animName = ui.exportDialog.nameBox.Text
	if animName == "" or animName:match("^%s*$") then
		print("Superior Animator: Nama animasi untuk ekspor tidak boleh kosong.")
		return
	end

	print("Mengekspor animasi sebagai '" .. animName .. "'...")

	local success, result = pcall(function()
		local animation = Instance.new("Animation")
		animation.Name = animName

		local keyframeSequence = Instance.new("KeyframeSequence")
		keyframeSequence.Parent = animation

		-- ganti getRealEnum dan cara pemakaiannya dengan dua helper sederhana:
		local function parseEasingStyleFromName(easingName)
			local name = easingName or "Linear"
			-- Hilangkan prefix arah untuk mendapat style murni: "InQuad" -> "Quad", "InOutCubic" -> "Cubic"
			if name:find("InOut") then
				name = name:gsub("InOut", "")
			else
				name = name:gsub("In", ""):gsub("Out", "")
			end
			if name == "" then name = "Linear" end
			local style = Enum.EasingStyle[name]
			if style == nil then
				warn("Unknown easing style '" .. tostring(name) .. "', defaulting to Linear.")
				return Enum.EasingStyle.Linear
			end
			return style
		end

		local function parseEasingDirectionFromName(easingName)
			local name = easingName or "InOut"
			if easingName:find("InOut") then
				return Enum.EasingDirection.InOut
			elseif easingName:find("In") then
				return Enum.EasingDirection.In
			elseif easingName:find("Out") then
				return Enum.EasingDirection.Out
			else
				return Enum.EasingDirection.InOut
			end
		end

		-- 1. Kumpulkan semua frame unik dari CFrame tracks
		local allCFrameFrames = {}
		for object, objectData in pairs(animationData) do
			if objectData.Properties.CFrame then
				for frame, _ in pairs(objectData.Properties.CFrame.keyframes) do
					allCFrameFrames[frame] = true
				end
			end
		end

		local sortedFrames = {}
		for frame, _ in pairs(allCFrameFrames) do table.insert(sortedFrames, frame) end
		table.sort(sortedFrames)

		-- 2. Buat Keyframe & Pose objects untuk CFrame animasi
		for _, frame in ipairs(sortedFrames) do
			local time = frame / Config.FRAMES_PER_SECOND
			local keyframe = Instance.new("Keyframe")
			keyframe.Time = time

			local hasPoses = false
			for object, objectData in pairs(animationData) do
				if objectData.Properties.CFrame and objectData.Properties.CFrame.keyframes[frame] then
					local keyframeCFrameData = objectData.Properties.CFrame.keyframes[frame]
					local pose = Instance.new("Pose")
					pose.Name = object.Name -- Mengasumsikan path relatif
					pose.CFrame = keyframeCFrameData.Value

					local easingName = keyframeCFrameData.Easing or "Linear"
					pose.EasingStyle = parseEasingStyleFromName(easingName)
					pose.EasingDirection = parseEasingDirectionFromName(easingName)

					pose.Parent = keyframe
					hasPoses = true
				end
			end

			-- Hanya tambahkan keyframe jika memiliki setidaknya satu pose
			if hasPoses then
				keyframe.Parent = keyframeSequence
			else
				keyframe:Destroy()
			end
		end

		-- 3. Buat [Type]Keyframe objects untuk properti lain
		for object, objectData in pairs(animationData) do
			for propName, propTrack in pairs(objectData.Properties) do
				if propName ~= "CFrame" then
					for frame, keyframeData in pairs(propTrack.keyframes) do
						local time = frame / Config.FRAMES_PER_SECOND
						local valueType = typeof(keyframeData.Value)
						local propKeyframe

						if valueType == "number" then
							propKeyframe = Instance.new("NumberKeyframe")
						elseif valueType == "Vector3" then
							propKeyframe = Instance.new("Vector3Keyframe")
						end

						if propKeyframe then
							propKeyframe.Value = keyframeData.Value
							propKeyframe.Time = time
							propKeyframe.Name = object.Name .. "." .. propName -- Mengasumsikan path relatif

							local easingName = keyframeData.Easing or "Linear"
							propKeyframe.EasingStyle = parseEasingStyleFromName(easingName)
							propKeyframe.EasingDirection = parseEasingDirectionFromName(easingName)

							propKeyframe.Parent = keyframeSequence
						end
					end
				end
			end

			-- Tambahkan KeyframeMarkers untuk Events
			if objectData.Events then
				for frame, eventData in pairs(objectData.Events.keyframes) do
					local time = frame / Config.FRAMES_PER_SECOND
					local marker = Instance.new("KeyframeMarker")
					marker.Name = eventData.Name
					marker.Time = time
					marker.Parent = keyframeSequence
				end
			end
		end

		local savesFolder = ServerStorage:FindFirstChild("SuperiorAnimator_Exports")
		if not savesFolder then
			savesFolder = Instance.new("Folder")
			savesFolder.Name = "SuperiorAnimator_Exports"
			savesFolder.Parent = ServerStorage
		end
		animation.Parent = savesFolder
	end)

	if success then
		print("Animasi berhasil diekspor!")
		ui.exportDialog.gui.Enabled = false
	else
		warn("Ekspor animasi gagal:", result)
	end
end)

ui.confirmDialog.cancelButton.MouseButton1Click:Connect(function()
	confirmAction = nil
	ui.confirmDialog.gui.Enabled = false
end)

ui.confirmDialog.yesButton.MouseButton1Click:Connect(function()
	if confirmAction then
		confirmAction()
	end
	confirmAction = nil
	ui.confirmDialog.gui.Enabled = false
end)

ui.loopButton.MouseButton1Click:Connect(function()
	isLoopingEnabled = not isLoopingEnabled
	if isLoopingEnabled then
		ui.loopButton.BackgroundColor3 = Config.Colors.ButtonPrimary
	else
		ui.loopButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	end
end)

ui.autoKeyButton.MouseButton1Click:Connect(function()
	isAutoKeyingEnabled = not isAutoKeyingEnabled
	if isAutoKeyingEnabled then
		ui.autoKeyButton.BackgroundColor3 = Config.Colors.ButtonPrimary
		ui.autoKeyButton.Text = "Auto: On"
		-- Hubungkan listener ke semua objek yang sudah ada
		for object, _ in pairs(animationData) do
			connectAutoKeyListener(object)
		end
	else
		ui.autoKeyButton.BackgroundColor3 = Config.Colors.ButtonSecondary
		ui.autoKeyButton.Text = "Auto"
		-- Putuskan semua listener yang ada
		for object, _ in pairs(autoKeyConnections) do
			disconnectAutoKeyListener(object)
		end
	end
end)


newAnimationButton.Click:Connect(function()
	mainWidget.Enabled = not mainWidget.Enabled
end)

local function syncScroll(source, target)
	target.CanvasPosition = Vector2.new(target.CanvasPosition.X, source.CanvasPosition.Y)
end
ui.trackListFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	syncScroll(ui.trackListFrame, ui.keyframeAreaFrame)
end)
ui.keyframeAreaFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	syncScroll(ui.keyframeAreaFrame, ui.trackListFrame)
end)

ui.playbackRange.startHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingPlaybackHandle = "Start"
	end
end)

ui.playbackRange.endHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingPlaybackHandle = "End"
	end
end)

ui.timelineRuler.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		-- Guard clause: Jangan mulai menyeret playhead jika sudah menyeret keyframe
		if draggingKeyframeInfo or draggingPlaybackHandle then return end

		isDraggingPlayhead = true
		local mouseX = input.Position.X - ui.timelineRuler.AbsolutePosition.X
		ui.playhead.Position = UDim2.new(0, math.clamp(mouseX, 0, ui.timelineRuler.AbsoluteSize.X), 0, 0)
		updateAnimationFromPlayhead()
	end
end)

-- Event handler untuk seluruh area keyframe, termasuk ruang kosong
ui.keyframeAreaFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		-- Guard clause: Abaikan jika sudah menyeret sesuatu yang lain
		if draggingKeyframeInfo or draggingPlaybackHandle or isDraggingPlayhead then return end

		-- Mulai seleksi kotak
		isMarqueeSelecting = true
		marqueeStartPoint = input.Position

		-- Kosongkan seleksi saat ini
		for _, selectedInfo in ipairs(selectedKeyframes) do
			local prevPropData = animationData[selectedInfo.object].Properties[selectedInfo.property]
			if prevPropData then
				local prevTargetTrack = selectedInfo.component and prevPropData.Components[selectedInfo.component] or prevPropData
				if prevTargetTrack and prevTargetTrack.keyframes[selectedInfo.frame] then
					local prevKeyframeData = prevTargetTrack.keyframes[selectedInfo.frame]
					selectedInfo.marker.BackgroundColor3 = if prevKeyframeData.Easing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
				end
			end
		end
		selectedKeyframes = {}
		updatePropertyDisplay(nil)


		-- Dapatkan posisi relatif terhadap area keyframe
		local relativePos = marqueeStartPoint - ui.keyframeAreaFrame.AbsolutePosition
		ui.marqueeSelectionBox.Position = UDim2.new(0, relativePos.X + ui.keyframeAreaFrame.CanvasPosition.X, 0, relativePos.Y + ui.keyframeAreaFrame.CanvasPosition.Y)
		ui.marqueeSelectionBox.Size = UDim2.new(0, 0, 0, 0)
		ui.marqueeSelectionBox.Visible = true
	end
end)


inputService.InputChanged:Connect(function(input)
	if isDraggingPlayhead and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local mouseX = input.Position.X - ui.keyframeAreaFrame.AbsolutePosition.X + ui.keyframeAreaFrame.CanvasPosition.X
		mouseX = math.clamp(mouseX, 0, ui.keyframeAreaFrame.CanvasSize.X.Offset)
		ui.playhead.Position = UDim2.new(0, mouseX, 0, 0)
		updateAnimationFromPlayhead()
	elseif isMarqueeSelecting and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local currentPos = input.Position
		local startPos = marqueeStartPoint

		-- Hitung posisi dan ukuran kotak
		local topLeft = Vector2.new(math.min(startPos.X, currentPos.X), math.min(startPos.Y, currentPos.Y))
		local bottomRight = Vector2.new(math.max(startPos.X, currentPos.X), math.max(startPos.Y, currentPos.Y))

		local relativePos = topLeft - ui.keyframeAreaFrame.AbsolutePosition
		local size = bottomRight - topLeft

		-- Terapkan ke UI, dengan mempertimbangkan scroll kanvas
		ui.marqueeSelectionBox.Position = UDim2.new(0, relativePos.X + ui.keyframeAreaFrame.CanvasPosition.X, 0, relativePos.Y + ui.keyframeAreaFrame.CanvasPosition.Y)
		ui.marqueeSelectionBox.Size = UDim2.new(0, size.X, 0, size.Y)

		-- Deteksi tumpang tindih
		local selectionRect = Rect.new(topLeft, bottomRight)

		local function checkIntersection(kfInfo, marker)
			local markerRect = Rect.new(marker.AbsolutePosition, marker.AbsoluteSize)
			local intersects = not (selectionRect.Min.X > markerRect.Max.X or selectionRect.Max.X < markerRect.Min.X or selectionRect.Min.Y > markerRect.Max.Y or selectionRect.Max.Y < markerRect.Min.Y)

			local alreadySelected = false
			for _, selInfo in ipairs(selectedKeyframes) do
				if selInfo.marker == marker then
					alreadySelected = true
					break
				end
			end

			if intersects and not alreadySelected then
				handleKeyframeSelection(kfInfo, true)
			elseif not intersects and alreadySelected then
				handleKeyframeSelection(kfInfo, true)
			end
		end

		for obj, objData in pairs(animationData) do
			for propName, propData in pairs(objData.Properties) do
				for frame, marker in pairs(propData.markers) do
					checkIntersection({ object = obj, frame = frame, property = propName, marker = marker, component = nil }, marker)
				end
				if propData.Components then
					for compName, compData in pairs(propData.Components) do
						for frame, marker in pairs(compData.markers) do
							checkIntersection({ object = obj, frame = frame, property = propName, marker = marker, component = compName }, marker)
						end
					end
				end
			end
		end

	elseif draggingKeyframeInfo and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local mouseX = input.Position.X - ui.keyframeAreaFrame.AbsolutePosition.X + ui.keyframeAreaFrame.CanvasPosition.X
		mouseX = math.clamp(mouseX, 0, ui.timelineRuler.AbsoluteSize.X)

		-- Hitung delta dari posisi asli keyframe yang diseret
		local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * zoomLevel
		local originalPixelX = draggingKeyframeInfo.originalFrame * pixelsPerFrame
		local deltaX = mouseX - originalPixelX

		-- Terapkan delta ke semua keyframe yang dipilih
		for _, kfInfo in ipairs(draggingKeyframeInfo.selection) do
			local kfOriginalX = kfInfo.originalFrame * pixelsPerFrame
			local newKfX = math.clamp(kfOriginalX + deltaX, 0, ui.timelineRuler.AbsoluteSize.X)
			kfInfo.marker.Position = UDim2.new(0, newKfX, 0, kfInfo.marker.Position.Y.Offset)
		end

	elseif draggingPlaybackHandle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local mouseX = input.Position.X - ui.timelineRuler.AbsolutePosition.X
		mouseX = math.clamp(mouseX, 0, ui.timelineRuler.AbsoluteSize.X)

		local startHandle = ui.playbackRange.startHandle
		local endHandle = ui.playbackRange.endHandle

		if draggingPlaybackHandle == "Start" then
			startHandle.Position = UDim2.new(0, math.min(mouseX, endHandle.Position.X.Offset), 0, 0)
		elseif draggingPlaybackHandle == "End" then
			endHandle.Position = UDim2.new(0, math.max(mouseX, startHandle.Position.X.Offset), 0, 0)
		end

		-- Update range frame
		local startX = startHandle.Position.X.Offset
		local endX = endHandle.Position.X.Offset
		ui.playbackRange.frame.Position = UDim2.new(0, startX, 0, 0)
		ui.playbackRange.frame.Size = UDim2.new(0, endX - startX, 1, 0)
	end
end)

inputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if isMarqueeSelecting then
			isMarqueeSelecting = false
			ui.marqueeSelectionBox.Visible = false
		end
		isDraggingPlayhead = false
		draggingPlaybackHandle = nil
		if draggingKeyframeInfo then
			local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * zoomLevel

			-- Buat tabel sementara untuk menampung data baru agar tidak konflik saat iterasi
			local updates = {}

			for _, kfDragInfo in ipairs(draggingKeyframeInfo.selection) do
				local newFrame = math.floor(kfDragInfo.marker.Position.X.Offset / pixelsPerFrame)

				if newFrame ~= kfDragInfo.originalFrame then
					local propData = animationData[kfDragInfo.object].Properties[kfDragInfo.property]
					local targetTrack = kfDragInfo.component and propData.Components[kfDragInfo.component] or propData

					table.insert(updates, {
						info = kfDragInfo,
						newFrame = newFrame,
						keyframeData = targetTrack.keyframes[kfDragInfo.originalFrame] -- Salin data SEKARANG
					})
				else
					-- Jika tidak ada perubahan, kembalikan ke posisi semula
					kfDragInfo.marker.Position = UDim2.new(0, kfDragInfo.originalFrame * pixelsPerFrame, 0, kfDragInfo.marker.Position.Y.Offset)
				end
			end

			-- Hapus data lama terlebih dahulu untuk menghindari penimpaan
			for _, update in ipairs(updates) do
				local kfInfo = update.info
				local propData = animationData[kfInfo.object].Properties[kfInfo.property]
				local targetTrack = kfInfo.component and propData.Components[kfInfo.component] or propData
				targetTrack.keyframes[kfInfo.originalFrame] = nil
				targetTrack.markers[kfInfo.originalFrame] = nil
			end

			-- Terapkan pembaruan
			local action = {
				redo = function()
					-- Hapus data lama terlebih dahulu
					for _, update in ipairs(updates) do
						local kfInfo = update.info
						local propData = animationData[kfInfo.object].Properties[kfInfo.property]
						local targetTrack = kfInfo.component and propData.Components[kfInfo.component] or propData
						targetTrack.keyframes[kfInfo.originalFrame] = nil
						targetTrack.markers[kfInfo.originalFrame] = nil
					end

					-- Terapkan pembaruan
					for _, update in ipairs(updates) do
						local kfInfo = update.info
						local newFrame = update.newFrame
						local propData = animationData[kfInfo.object].Properties[kfInfo.property]
						local targetTrack = kfInfo.component and propData.Components[kfInfo.component] or propData

						targetTrack.keyframes[newFrame] = update.keyframeData
						targetTrack.markers[newFrame] = kfInfo.marker
						kfInfo.marker.Position = UDim2.new(0, newFrame * pixelsPerFrame, 0, kfInfo.marker.Position.Y.Offset)

						for _, selected in ipairs(selectedKeyframes) do
							if selected.marker == kfInfo.marker then
								selected.frame = newFrame
								break
							end
						end
					end
					updateTimelineRuler()
				end,
				undo = function()
					-- Hapus dari posisi baru
					for _, update in ipairs(updates) do
						local kfInfo = update.info
						local newFrame = update.newFrame
						local propData = animationData[kfInfo.object].Properties[kfInfo.property]
						local targetTrack = kfInfo.component and propData.Components[kfInfo.component] or propData
						targetTrack.keyframes[newFrame] = nil
						targetTrack.markers[newFrame] = nil
					end

					-- Kembalikan ke posisi lama
					for _, update in ipairs(updates) do
						local kfInfo = update.info
						local originalFrame = kfInfo.originalFrame
						local propData = animationData[kfInfo.object].Properties[kfInfo.property]
						local targetTrack = kfInfo.component and propData.Components[kfInfo.component] or propData

						targetTrack.keyframes[originalFrame] = update.keyframeData
						targetTrack.markers[originalFrame] = kfInfo.marker
						kfInfo.marker.Position = UDim2.new(0, originalFrame * pixelsPerFrame, 0, kfInfo.marker.Position.Y.Offset)

						for _, selected in ipairs(selectedKeyframes) do
							if selected.marker == kfInfo.marker then
								selected.frame = originalFrame
								break
							end
						end
					end
					updateTimelineRuler()
				end
			}
			ActionHistory.register(action)
			action.redo()

			draggingKeyframeInfo = nil
		end
	end
end)

ui.addObjectButton.MouseButton1Click:Connect(function()
	local selectedObjects = selection:Get()
	if #selectedObjects == 0 then return end
	local objectToAdd = selectedObjects[1]
	if animationData[objectToAdd] then return end -- Sudah ada

	local action = {
		redo = function()
			createTrackForObject(objectToAdd, false)
			updateCanvasSize()
			updateSelectedObjectLabel()
		end,
		undo = function()
			deleteTrack(objectToAdd, nil) -- Hapus seluruh trek objek
		end
	}
	ActionHistory.register(action)
	action.redo()
end)

ui.addKeyframeButton.MouseButton1Click:Connect(function()
	if not currentlySelectedTrack.object or not currentlySelectedTrack.property then
		print("Pilih sebuah track properti terlebih dahulu.")
		return
	end

	local selectedObject = currentlySelectedTrack.object
	local fullPropName = currentlySelectedTrack.property

	local playheadX = ui.playhead.Position.X.Offset
	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * zoomLevel
	local currentFrame = math.floor(playheadX / pixelsPerFrame)

	local mainPropName, componentName = fullPropName:match("([^.]+)%.([^.]+)")
	mainPropName = mainPropName or fullPropName

	local propData = animationData[selectedObject].Properties[mainPropName]
	if not propData then return end

	local expandableTypes = {Vector3 = {"X", "Y", "Z"}, Color3 = {"R", "G", "B"}, UDim2 = {"XScale", "XOffset", "YScale", "YOffset"}}

	-- Menangani penambahan keyframe ke track komponen individual
	if componentName then
		if not propData.Components[componentName] then
			propData.Components[componentName] = { keyframes = {}, markers = {} }
		end
		local compTrack = propData.Components[componentName]
		if compTrack.keyframes[currentFrame] then return end

		local currentValue = selectedObject[mainPropName]
		local componentValue
		if propData.ValueType == "UDim2" then -- Penanganan khusus untuk UDim2
			local udimComp = componentName:match("([XY])(Scale|Offset)")
			componentValue = currentValue[udimComp:sub(1,1)][udimComp:sub(2)]
		else
			componentValue = currentValue[componentName]
		end

		addKeyframeData(selectedObject, mainPropName, currentFrame, componentValue, "Linear", componentName)
		createKeyframeMarkerUI(selectedObject, mainPropName, currentFrame, componentName)

		-- Menangani penambahan keyframe ke track utama (baik diperluas maupun tidak)
	else
		-- Jika diperluas, tambahkan keyframe ke semua komponen
		if propData.IsExpanded then
			local components = expandableTypes[propData.ValueType]
			local currentValue = selectedObject[mainPropName]

			for _, compName in ipairs(components) do
				local compTrack = propData.Components[compName]
				if compTrack and compTrack.keyframes[currentFrame] then continue end

				local componentValue
				if propData.ValueType == "UDim2" then
					local udimComp = compName:match("([XY])(Scale|Offset)")
					componentValue = currentValue[udimComp:sub(1,1)][udimComp:sub(2)]
				else
					componentValue = currentValue[compName]
				end
				addKeyframeData(selectedObject, mainPropName, currentFrame, componentValue, "Linear", compName)
				createKeyframeMarkerUI(selectedObject, mainPropName, currentFrame, compName)
			end
			-- Jika tidak diperluas, tambahkan satu keyframe ke track utama
		else
			if propData.keyframes[currentFrame] then return end
			addKeyframeData(selectedObject, mainPropName, currentFrame, selectedObject[mainPropName], "Linear", nil)
			createKeyframeMarkerUI(selectedObject, mainPropName, currentFrame, nil)
		end
	end

	local action = {
		info = "Add Keyframe(s)",
		redo = function()
			-- Lakukan kembali tindakan penambahan keyframe
			if componentName then
				addKeyframeData(selectedObject, mainPropName, currentFrame, selectedObject[mainPropName][componentName], "Linear", componentName)
				createKeyframeMarkerUI(selectedObject, mainPropName, currentFrame, componentName)
			elseif propData.IsExpanded then
				local components = expandableTypes[propData.ValueType]
				local currentValue = selectedObject[mainPropName]
				for _, compName in ipairs(components) do
					local componentValue = (propData.ValueType == "UDim2") and currentValue[compName:sub(1,1)][compName:sub(2)] or currentValue[compName]
					addKeyframeData(selectedObject, mainPropName, currentFrame, componentValue, "Linear", compName)
					createKeyframeMarkerUI(selectedObject, mainPropName, currentFrame, compName)
				end
			else
				addKeyframeData(selectedObject, mainPropName, currentFrame, selectedObject[mainPropName], "Linear", nil)
				createKeyframeMarkerUI(selectedObject, mainPropName, currentFrame, nil)
			end
			updateTimelineRuler()
		end,
		undo = function()
			-- Urungkan tindakan penambahan keyframe
			local function removeKeyframe(obj, prop, frame, comp)
				local pData = animationData[obj].Properties[prop]
				local track = comp and pData.Components[comp] or pData
				if track and track.markers[frame] then
					track.markers[frame]:Destroy()
					track.markers[frame] = nil
					track.keyframes[frame] = nil
				end
			end

			if componentName then
				removeKeyframe(selectedObject, mainPropName, currentFrame, componentName)
			elseif propData.IsExpanded then
				local components = expandableTypes[propData.ValueType]
				for _, compName in ipairs(components) do
					removeKeyframe(selectedObject, mainPropName, currentFrame, compName)
				end
			else
				removeKeyframe(selectedObject, mainPropName, currentFrame, nil)
			end
			updateTimelineRuler()
		end
	}
	ActionHistory.register(action)
	action.redo()

end)

selection.SelectionChanged:Connect(updateSelectedObjectLabel)

ui.playButton.MouseButton1Click:Connect(function()
	if not isPlaying then
		-- Jika playhead sudah di akhir, mulai lagi dari awal rentang
		if ui.playhead.Position.X.Offset >= ui.playbackRange.endHandle.Position.X.Offset then
			ui.playhead.Position = UDim2.new(0, ui.playbackRange.startHandle.Position.X.Offset, 0, 0)
		end

		isPlaying = true
		if not playbackConnection then
			playbackConnection = RunService.Heartbeat:Connect(onHeartbeat)
		end
	end
end)

ui.stopButton.MouseButton1Click:Connect(function()
	if isPlaying then
		isPlaying = false
	end
	-- Kembalikan playhead ke awal rentang, bukan ke 0
	ui.playhead.Position = UDim2.new(0, ui.playbackRange.startHandle.Position.X.Offset, 0, 0)
	updateAnimationFromPlayhead()
end)

ui.easingButton.MouseButton1Click:Connect(function()
	local currentPos = ui.easingButton.AbsolutePosition
	local menuPos = UDim2.new(0, 5, 0, ui.easingButton.LayoutOrder * 30) -- Perkiraan posisi
	ui.easingMenu.Position = menuPos
	-- Reposition menu to be directly below the button
	local buttonPos = ui.easingButton.AbsolutePosition
	local propsPos = ui.propertyLabels.cframe.posHolder.Parent.AbsolutePosition
	local finalPos = UDim2.new(0, 5, 0, buttonPos.Y - propsPos.Y + ui.easingButton.AbsoluteSize.Y)

	ui.easingMenu.Position = finalPos
	ui.easingMenu.Visible = not ui.easingMenu.Visible
end)

-- Sembunyikan menu jika diklik di luar
ui.mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if ui.easingMenu.Visible then
			-- Cek apakah klik berada di dalam menu atau tombol easing
			local mousePos = input.Position
			local menuRect = Rect.new(ui.easingMenu.AbsolutePosition, ui.easingMenu.AbsoluteSize)
			local buttonRect = Rect.new(ui.easingButton.AbsolutePosition, ui.easingButton.AbsoluteSize)

			if not (mousePos.X >= menuRect.Min.X and mousePos.X <= menuRect.Max.X and mousePos.Y >= menuRect.Min.Y and mousePos.Y <= menuRect.Max.Y) and
				not (mousePos.X >= buttonRect.Min.X and mousePos.X <= buttonRect.Max.X and mousePos.Y >= buttonRect.Min.Y and mousePos.Y <= buttonRect.Max.Y)
			then
				ui.easingMenu.Visible = false
			end
		end

		if ui.propMenu.frame.Visible then
			local mousePos = input.Position
			local menuRect = Rect.new(ui.propMenu.frame.AbsolutePosition, ui.propMenu.frame.AbsoluteSize)
			if not (mousePos.X >= menuRect.Min.X and mousePos.X <= menuRect.Max.X and mousePos.Y >= menuRect.Min.Y and mousePos.Y <= menuRect.Max.Y) then
				ui.propMenu.frame.Visible = false
			end
		end

		if ui.contextMenu.frame.Visible then
			local mousePos = input.Position
			local menuRect = Rect.new(ui.contextMenu.frame.AbsolutePosition, ui.contextMenu.frame.AbsoluteSize)
			if not (mousePos.X >= menuRect.Min.X and mousePos.X <= menuRect.Max.X and mousePos.Y >= menuRect.Min.Y and mousePos.Y <= menuRect.Max.Y) then
				ui.contextMenu.frame.Visible = false
			end
		end
	end
end)

ui.propMenu.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local searchText = ui.propMenu.searchBox.Text:lower()
	local totalHeight = 0
	local visibleCount = 0
	for _, child in ipairs(ui.propMenu.list:GetChildren()) do
		if child:IsA("TextButton") then
			local match = child.Name:lower():find(searchText, 1, true)
			child.Visible = match
			if match then
				totalHeight = totalHeight + 26 -- 24 height + 2 padding
				visibleCount = visibleCount + 1
			end
		end
	end
	local listHeight = math.min(totalHeight, 250 - 32)
	ui.propMenu.frame.Size = UDim2.new(0, 180, 0, listHeight + 32)
	ui.propMenu.list.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end)

-- Isi menu dropdown easing
for _, category in ipairs(easingStyles) do
	-- Buat label kategori (kecuali untuk Linear)
	if category.Name ~= "Linear" then
		local categoryLabel = Instance.new("TextLabel")
		categoryLabel.Name = category.Name .. "_Category"
		categoryLabel.Text = "  " .. category.Name
		categoryLabel.Size = UDim2.new(1, 0, 0, 20)
		categoryLabel.Font = Enum.Font.SourceSansBold
		categoryLabel.TextColor3 = Config.Colors.TextSecondary
		categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
		categoryLabel.BackgroundTransparency = 1
		categoryLabel.Parent = ui.easingMenu
	end

	for _, styleName in ipairs(category.Styles) do
		local itemButton = Instance.new("TextButton")
		itemButton.Name = styleName
		itemButton.Text = "    " .. styleName -- Beri indentasi
		itemButton.Size = UDim2.new(1, 0, 0, 24)
		itemButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
		itemButton.TextColor3 = Color3.fromRGB(220,220,220)
		itemButton.Font = Enum.Font.SourceSans
		itemButton.TextSize = 14
		itemButton.TextXAlignment = Enum.TextXAlignment.Left
		itemButton.Parent = ui.easingMenu

		itemButton.MouseButton1Click:Connect(function()
			if #selectedKeyframes ~= 1 then return end
			local kfInfo = selectedKeyframes[1]

			local propTrack = animationData[kfInfo.object].Properties[kfInfo.property]
			if not (propTrack and propTrack.keyframes[kfInfo.frame]) then return end

			local keyframe = propTrack.keyframes[kfInfo.frame]
			local oldEasing = keyframe.Easing
			local newEasing = styleName

			if oldEasing == newEasing then return end

			local action = {
				redo = function()
					local kf = animationData[kfInfo.object].Properties[kfInfo.property].keyframes[kfInfo.frame]
					kf.Easing = newEasing
					ui.easingButton.Text = "Easing: " .. newEasing
					if kfInfo.marker then
						kfInfo.marker.BackgroundColor3 = if newEasing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
					end
					ui.easingMenu.Visible = false
				end,
				undo = function()
					local kf = animationData[kfInfo.object].Properties[kfInfo.property].keyframes[kfInfo.frame]
					kf.Easing = oldEasing
					ui.easingButton.Text = "Easing: " .. oldEasing
					if kfInfo.marker then
						kfInfo.marker.BackgroundColor3 = if oldEasing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
					end
				end
			}
			ActionHistory.register(action)
			action.redo()
		end)
	end
end

local function deleteSelectedKeyframes()
	if currentSelection.type == "Keyframe" and #currentSelection.data > 0 then
		-- Existing logic for keyframes
	elseif currentSelection.type == "Event" and #currentSelection.data > 0 then
		-- Logic for deleting events
	else
		return
	end

	local deletedKeyframesData = {}
	for _, kfInfo in ipairs(currentSelection.data) do
		if kfInfo.marker and kfInfo.object then
			local propTrack = animationData[kfInfo.object].Properties[kfInfo.property]
			if propTrack then
				local targetTrack = kfInfo.component and propTrack.Components[kfInfo.component] or propTrack
				if targetTrack and targetTrack.keyframes[kfInfo.frame] then
					table.insert(deletedKeyframesData, {
						object = kfInfo.object,
						property = kfInfo.property,
						component = kfInfo.component,
						frame = kfInfo.frame,
						data = targetTrack.keyframes[kfInfo.frame]
					})
				end
			end
		end
	end

	if #deletedKeyframesData == 0 then return end

	local action = {
		redo = function()
			for _, deletedInfo in ipairs(deletedKeyframesData) do
				local propTrack = animationData[deletedInfo.object].Properties[deletedInfo.property]
				local targetTrack = deletedInfo.component and propTrack.Components[deletedInfo.component] or propTrack
				if targetTrack and targetTrack.markers[deletedInfo.frame] then
					targetTrack.markers[deletedInfo.frame]:Destroy()
					targetTrack.markers[deletedInfo.frame] = nil
					targetTrack.keyframes[deletedInfo.frame] = nil
				end
			end
			selectedKeyframes = {}
			updatePropertyDisplay(nil)
			updateTimelineRuler()
		end,
		undo = function()
			for _, deletedInfo in ipairs(deletedKeyframesData) do
				addKeyframeData(deletedInfo.object, deletedInfo.property, deletedInfo.frame, deletedInfo.data.Value, deletedInfo.data.Easing, deletedInfo.component)
				createKeyframeMarkerUI(deletedInfo.object, deletedInfo.property, deletedInfo.frame, deletedInfo.component)
			end
			updateTimelineRuler()
		end
	}
	ActionHistory.register(action)
	action.redo()
end

ui.deleteKeyframeButton.MouseButton1Click:Connect(deleteSelectedKeyframes)

inputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	local isCtrlDown = inputService:IsKeyDown(Enum.KeyCode.LeftControl) or inputService:IsKeyDown(Enum.KeyCode.RightControl)
	local isShiftDown = inputService:IsKeyDown(Enum.KeyCode.LeftShift) or inputService:IsKeyDown(Enum.KeyCode.RightShift)

	if input.KeyCode == Enum.KeyCode.Delete then
		deleteSelectedKeyframes()
	elseif input.KeyCode == Enum.KeyCode.Z and isCtrlDown and not isShiftDown then
		ActionHistory.undo()
	elseif (input.KeyCode == Enum.KeyCode.Y and isCtrlDown) or (input.KeyCode == Enum.KeyCode.Z and isCtrlDown and isShiftDown) then
		ActionHistory.redo()
	elseif input.KeyCode == Enum.KeyCode.C and isCtrlDown then
		-- Copy Keyframe (hanya jika satu yang dipilih)
		if #selectedKeyframes == 1 then
			local kfInfo = selectedKeyframes[1]
			local propData = animationData[kfInfo.object].Properties[kfInfo.property]
			if not propData then return end

			local targetTrack = kfInfo.component and propData.Components[kfInfo.component] or propData
			local keyframeData = targetTrack.keyframes[kfInfo.frame]

			if keyframeData then
				keyframeClipboard = {
					Value = keyframeData.Value,
					Easing = keyframeData.Easing,
					ValueType = typeof(keyframeData.Value)
				}
				print("Keyframe tunggal disalin ke clipboard.")
			end
		else
			print("Silakan pilih tepat satu keyframe untuk disalin.")
		end
	elseif input.KeyCode == Enum.KeyCode.V and isCtrlDown then
		-- Paste Keyframe
		if not keyframeClipboard then
			print("Clipboard keyframe kosong.")
			return
		end

		if not currentlySelectedTrack.object or not currentlySelectedTrack.property then
			print("Pilih sebuah track untuk menempel keyframe.")
			return
		end

		local object = currentlySelectedTrack.object
		local fullPropName = currentlySelectedTrack.property

		local mainPropName, componentName = fullPropName:match("([^.]+)%.([^.]+)")
		mainPropName = mainPropName or fullPropName

		local propData = animationData[object].Properties[mainPropName]
		if not propData then return end

		-- Periksa kompatibilitas tipe
		local isCompatible = false
		if componentName then
			-- Menempel ke track komponen (harus number)
			if keyframeClipboard.ValueType == "number" then
				isCompatible = true
			end
		else
			-- Menempel ke track utama
			if keyframeClipboard.ValueType == propData.ValueType then
				isCompatible = true
			end
		end

		if not isCompatible then
			print("Tipe data keyframe di clipboard (" .. keyframeClipboard.ValueType .. ") tidak kompatibel dengan track yang dipilih (" .. (propData.ValueType or "number") .. ").")
			return
		end

		local playheadX = ui.playhead.Position.X.Offset
		local pixelsPerFrame = Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL
		local currentFrame = math.floor(playheadX / pixelsPerFrame)

		-- Hapus keyframe yang ada di frame target jika ada, untuk digantikan
		local targetTrackForDeletion = componentName and propData.Components[componentName] or propData
		if targetTrackForDeletion and targetTrackForDeletion.markers[currentFrame] then
			targetTrackForDeletion.markers[currentFrame]:Destroy()
			targetTrackForDeletion.keyframes[currentFrame] = nil
			targetTrackForDeletion.markers[currentFrame] = nil
		end

		-- Tambahkan data dan buat UI
		addKeyframeData(object, mainPropName, currentFrame, keyframeClipboard.Value, keyframeClipboard.Easing, componentName)
		createKeyframeMarkerUI(object, mainPropName, currentFrame, componentName)
		updateTimelineRuler()
		print("Keyframe ditempel ke frame " .. currentFrame)
	end
end)

updateSelectedObjectLabel()
updateCanvasSize()

-- === KONEKSI UNDO/REDO ===
updateUndoRedoButtonStates = function()
	local canUndo = #undoStack > 0
	local canRedo = #redoStack > 0
	ui.undoButton.TextColor3 = canUndo and Config.Colors.TextPrimary or Config.Colors.TextDisabled
	ui.redoButton.TextColor3 = canRedo and Config.Colors.TextPrimary or Config.Colors.TextDisabled
end

ui.undoButton.MouseButton1Click:Connect(ActionHistory.undo)
ui.redoButton.MouseButton1Click:Connect(ActionHistory.redo)

-- Panggil sekali di awal untuk mengatur keadaan awal
updateUndoRedoButtonStates()

ui.speedDropdown.MouseButton1Click:Connect(function()
	-- For simplicity, this will cycle through speeds. A proper dropdown would be more complex.
	local speeds = {0.25, 0.5, 1.0, 2.0}
	local currentIndex = table.find(speeds, playbackSpeed) or 3
	local nextIndex = (currentIndex % #speeds) + 1
	playbackSpeed = speeds[nextIndex]
	ui.speedDropdown.Text = tostring(playbackSpeed) .. "x"
end)


-- Event handler untuk color swatch
ui.propertyLabels.color3.swatch.MouseButton1Click:Connect(function()
	if #selectedKeyframes ~= 1 then return end
	local kfInfo = selectedKeyframes[1]
	local keyframe = animationData[kfInfo.object].Properties[kfInfo.property].keyframes[kfInfo.frame]
	if not keyframe or typeof(keyframe.Value) ~= "Color3" then return end

	local success, newColor = plugin:GetColor3(keyframe.Value)
	if success then
		updateKeyframeValue(newColor, nil, nil)
	end
end)

-- Event handler untuk boolean checkbox
ui.propertyLabels.boolean.checkbox.MouseButton1Click:Connect(function()
	if #selectedKeyframes ~= 1 then return end
	local kfInfo = selectedKeyframes[1]
	local keyframe = animationData[kfInfo.object].Properties[kfInfo.property].keyframes[kfInfo.frame]
	if not keyframe or typeof(keyframe.Value) ~= "boolean" then return end

	updateKeyframeValue(not keyframe.Value, nil, nil)
end)


-- Hubungkan event untuk pengeditan properti
local function connectPropEdit(textbox, component, axis)
	textbox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			if component == "EventName" then
				updateKeyframeValue(textbox.Text, "EventName", nil)
			else
				updateKeyframeValue(textbox.Text, component, axis)
			end
		end
	end)
end

-- CFrame
connectPropEdit(ui.propertyLabels.cframe.posX, "Position", "X")
connectPropEdit(ui.propertyLabels.cframe.posY, "Position", "Y")
connectPropEdit(ui.propertyLabels.cframe.posZ, "Position", "Z")
connectPropEdit(ui.propertyLabels.cframe.rotX, "Rotation", "X")
connectPropEdit(ui.propertyLabels.cframe.rotY, "Rotation", "Y")
connectPropEdit(ui.propertyLabels.cframe.rotZ, "Rotation", "Z")

-- Generic
connectPropEdit(ui.propertyLabels.generic.x, nil, "X")
connectPropEdit(ui.propertyLabels.generic.y, nil, "Y")
connectPropEdit(ui.propertyLabels.generic.z, nil, "Z")

-- Color3
-- UDim2
connectPropEdit(ui.propertyLabels.udim2.xs, nil, "XS")
connectPropEdit(ui.propertyLabels.udim2.xo, nil, "XO")
connectPropEdit(ui.propertyLabels.udim2.ys, nil, "YS")
connectPropEdit(ui.propertyLabels.udim2.yo, nil, "YO")
