--SuperiorAnimator.lua

local PLUGIN_NAME = "SuperiorAnimator"
local PLUGIN_VERSION = "0.1.0"

-- Fungsi ini HANYA membuat dan mengembalikan elemen-elemen UI.
-- Semua logika perilaku (event) akan dihubungkan di luar fungsi ini.
local function createUiElements(parentWidget)
	-- === STRUKTUR UI ===
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = parentWidget

	-- TOP BAR --
	local topBarFrame = Instance.new("Frame")
	topBarFrame.Name = "TopBar"
	topBarFrame.Size = UDim2.new(1, 0, 0, 36)
	topBarFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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
	saveButton.BackgroundColor3 = Color3.fromRGB(70, 90, 120)
	saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	saveButton.Font = Enum.Font.SourceSansBold
	saveButton.TextSize = 14
	saveButton.LayoutOrder = 1
	saveButton.Parent = topBarFrame
	
	local loadButton = Instance.new("TextButton")
	loadButton.Name = "LoadButton"
	loadButton.Size = UDim2.new(0, 50, 0, 28)
	loadButton.Text = "Load"
	loadButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	loadButton.Font = Enum.Font.SourceSansBold
	loadButton.TextSize = 14
	loadButton.LayoutOrder = 2
	loadButton.Parent = topBarFrame

	local exportButton = Instance.new("TextButton")
	exportButton.Name = "ExportButton"
	exportButton.Size = UDim2.new(0, 60, 0, 28)
	exportButton.Text = "Export"
	exportButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	exportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	exportButton.Font = Enum.Font.SourceSansBold
	exportButton.TextSize = 14
	exportButton.LayoutOrder = 3
	exportButton.Parent = topBarFrame

	local separator1 = Instance.new("Frame")
	separator1.Size = UDim2.new(0, 1, 0, 28)
	separator1.BackgroundColor3 = Color3.fromRGB(60,60,60)
	separator1.LayoutOrder = 4
	separator1.Parent = topBarFrame
	
	local playButton = Instance.new("TextButton")
	playButton.Name = "PlayButton"
	playButton.Size = UDim2.new(0, 50, 0, 28)
	playButton.Text = "Play"
	playButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	playButton.Font = Enum.Font.SourceSansBold
	playButton.TextSize = 14
	playButton.LayoutOrder = 5
	playButton.Parent = topBarFrame
	
	local stopButton = Instance.new("TextButton")
	stopButton.Name = "StopButton"
	stopButton.Size = UDim2.new(0, 50, 0, 28)
	stopButton.Text = "Stop"
	stopButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopButton.Font = Enum.Font.SourceSansBold
	stopButton.TextSize = 14
	stopButton.LayoutOrder = 6
	stopButton.Parent = topBarFrame

	local separator2 = Instance.new("Frame")
	separator2.Size = UDim2.new(0, 1, 0, 28)
	separator2.BackgroundColor3 = Color3.fromRGB(60,60,60)
	separator2.LayoutOrder = 7
	separator2.Parent = topBarFrame
	
	local addObjectButton = Instance.new("TextButton")
	addObjectButton.Name = "AddObjectButton"
	addObjectButton.Size = UDim2.new(0, 100, 0, 28)
	addObjectButton.Text = "Tambah Objek"
	addObjectButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	addObjectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	addObjectButton.Font = Enum.Font.SourceSansBold
	addObjectButton.TextSize = 14
	addObjectButton.LayoutOrder = 8
	addObjectButton.Parent = topBarFrame
	
	local addKeyframeButton = Instance.new("TextButton")
	addKeyframeButton.Name = "AddKeyframeButton"
	addKeyframeButton.Size = UDim2.new(0, 28, 0, 28)
	addKeyframeButton.Text = "+"
	addKeyframeButton.Font = Enum.Font.SourceSansBold
	addKeyframeButton.TextSize = 24
	addKeyframeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	addKeyframeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	addKeyframeButton.LayoutOrder = 9
	addKeyframeButton.Parent = topBarFrame
	
	local selectedObjectLabel = Instance.new("TextLabel")
	selectedObjectLabel.Name = "SelectedObjectLabel"
	selectedObjectLabel.Size = UDim2.new(1, -480, 1, 0)
	selectedObjectLabel.Font = Enum.Font.SourceSans
	selectedObjectLabel.TextSize = 14
	selectedObjectLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	selectedObjectLabel.BackgroundTransparency = 1
	selectedObjectLabel.TextXAlignment = Enum.TextXAlignment.Right
	selectedObjectLabel.Text = "Tidak ada objek yang dipilih"
	selectedObjectLabel.LayoutOrder = 10
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
	propertiesFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
	titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
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
		nameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
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
		valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		valueBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
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

	local colorLabel, colorHolder = createPropertyDisplay("Color", 14)
	local colorR, colorRHolder = createPropertyDisplay("  - R", 15)
	local colorG, colorGHolder = createPropertyDisplay("  - G", 16)
	local colorB, colorBHolder = createPropertyDisplay("  - B", 17)

	local udim2Label, udim2Holder = createPropertyDisplay("UDim2", 18)
	local udim2XS, udim2XSHolder = createPropertyDisplay("  - X Scale", 19)
	local udim2XO, udim2XOHolder = createPropertyDisplay("  - X Offset", 20)
	local udim2YS, udim2YSHolder = createPropertyDisplay("  - Y Scale", 21)
	local udim2YO, udim2YOHolder = createPropertyDisplay("  - Y Offset", 22)

	local boolValue, boolValueHolder, boolNameLabel = createPropertyDisplay("Value", 23)
	
	local easingButton = Instance.new("TextButton")
	easingButton.Name = "EasingButton"
	easingButton.Size = UDim2.new(1, -10, 0, 24)
	easingButton.Position = UDim2.new(0, 5, 0, 0)
	easingButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	easingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
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
	easingMenu.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	easingMenu.BorderColor3 = Color3.fromRGB(90, 90, 90)
	easingMenu.ScrollBarThickness = 5
	easingMenu.LayoutOrder = 25 -- Setelah tombol easing
	easingMenu.ZIndex = 11
	easingMenu.Parent = propertiesFrame
	
	local easingMenuLayout = Instance.new("UIListLayout")
	easingMenuLayout.Padding = UDim.new(0, 2)
	easingMenuLayout.SortOrder = Enum.SortOrder.Name
	easingMenuLayout.Parent = easingMenu
	
	-- TIMELINE --
	local timelineContainer = Instance.new("Frame")
	timelineContainer.Name = "TimelineContainer"
	timelineContainer.Size = UDim2.new(1, -250, 1, 0)
	timelineContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	timelineContainer.BorderSizePixel = 0
	timelineContainer.ClipsDescendants = true
	timelineContainer.Parent = contentFrame

	local trackListFrame = Instance.new("ScrollingFrame")
	trackListFrame.Name = "TrackList"
	trackListFrame.Size = UDim2.new(0, 200, 1, -24)
	trackListFrame.Position = UDim2.new(0, 0, 0, 24)
	trackListFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
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
	keyframeAreaFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	keyframeAreaFrame.BorderSizePixel = 0
	keyframeAreaFrame.ScrollBarThickness = 6
	keyframeAreaFrame.ScrollingDirection = Enum.ScrollingDirection.XY
	keyframeAreaFrame.Parent = timelineContainer

	local timelineRuler = Instance.new("Frame")
	timelineRuler.Name = "Ruler"
	timelineRuler.Size = UDim2.new(5, 0, 0, 24)
	timelineRuler.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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

	local PIXELS_PER_FRAME_INTERVAL = 60
	local FRAMES_PER_INTERVAL = 10
	for i = 0, 100 do
		local position = i * PIXELS_PER_FRAME_INTERVAL
		local frameNumber = i * FRAMES_PER_INTERVAL
		local marker = Instance.new("TextLabel")
		marker.Size = UDim2.new(0, 50, 1, 0)
		marker.Position = UDim2.new(0, position - (marker.Size.X.Offset / 2), 0, 0)
		marker.Text = tostring(frameNumber)
		marker.Font = Enum.Font.SourceSans
		marker.TextSize = 12
		marker.TextColor3 = Color3.fromRGB(180, 180, 180)
		marker.BackgroundTransparency = 1
		marker.Parent = timelineRuler
	end

	local playhead = Instance.new("Frame")
	playhead.Name = "Playhead"
	playhead.Size = UDim2.new(0, 2, 1, 0)
	playhead.Position = UDim2.new(0, 50, 0, 0)
	playhead.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	playhead.BorderSizePixel = 0
	playhead.ZIndex = 3
	playhead.Parent = keyframeAreaFrame

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
	saveDialogFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	saveDialogFrame.BorderColor3 = Color3.fromRGB(80,80,80)
	saveDialogFrame.Parent = saveDialogGui

	local saveTitle = Instance.new("TextLabel")
	saveTitle.Size = UDim2.new(1, 0, 0, 30)
	saveTitle.Text = "Simpan Animasi"
	saveTitle.Font = Enum.Font.SourceSansBold
	saveTitle.TextSize = 16
	saveTitle.TextColor3 = Color3.fromRGB(255,255,255)
	saveTitle.BackgroundColor3 = Color3.fromRGB(40,40,40)
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
	confirmSaveButton.BackgroundColor3 = Color3.fromRGB(70, 90, 120)
	confirmSaveButton.TextColor3 = Color3.fromRGB(255,255,255)
	confirmSaveButton.Font = Enum.Font.SourceSansBold
	confirmSaveButton.Parent = saveDialogFrame
	
	local cancelSaveButton = Instance.new("TextButton")
	cancelSaveButton.Name = "CancelSaveButton"
	cancelSaveButton.Size = UDim2.new(0.5, -15, 0, 30)
	cancelSaveButton.Position = UDim2.new(0.5, 5, 1, -40)
	cancelSaveButton.Text = "Batal"
	cancelSaveButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
	cancelSaveButton.TextColor3 = Color3.fromRGB(255,255,255)
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
	loadDialogFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	loadDialogFrame.BorderColor3 = Color3.fromRGB(80,80,80)
	loadDialogFrame.Parent = loadDialogGui
	
	local loadTitle = Instance.new("TextLabel")
	loadTitle.Size = UDim2.new(1, 0, 0, 30)
	loadTitle.Text = "Muat Animasi"
	loadTitle.Font = Enum.Font.SourceSansBold
	loadTitle.TextSize = 16
	loadTitle.TextColor3 = Color3.fromRGB(255,255,255)
	loadTitle.BackgroundColor3 = Color3.fromRGB(40,40,40)
	loadTitle.Parent = loadDialogFrame
	
	local savedAnimsList = Instance.new("ScrollingFrame")
	savedAnimsList.Name = "SavedAnimsList"
	savedAnimsList.Size = UDim2.new(1, -20, 1, -80)
	savedAnimsList.Position = UDim2.new(0, 10, 0, 40)
	savedAnimsList.BackgroundColor3 = Color3.fromRGB(45,45,45)
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
	cancelLoadButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
	cancelLoadButton.TextColor3 = Color3.fromRGB(255,255,255)
	cancelLoadButton.Font = Enum.Font.SourceSansBold
	cancelLoadButton.Parent = loadDialogFrame
	
	-- PROPERTY SELECTOR MENU --
	local propMenu = Instance.new("ScrollingFrame")
	propMenu.Name = "PropertyMenu"
	propMenu.Visible = false
	propMenu.Size = UDim2.new(0, 180, 0, 250)
	propMenu.BackgroundColor3 = Color3.fromRGB(60,60,60)
	propMenu.BorderColor3 = Color3.fromRGB(90,90,90)
	propMenu.ZIndex = 10
	propMenu.ScrollBarThickness = 5
	propMenu.Parent = mainFrame
	
	local propListLayout = Instance.new("UIListLayout")
	propListLayout.Padding = UDim.new(0, 2)
	propListLayout.Parent = propMenu


	return {
		mainFrame = mainFrame,
		selectedObjectLabel = selectedObjectLabel,
		saveButton = saveButton,
		loadButton = loadButton,
		exportButton = exportButton,
		playButton = playButton,
		stopButton = stopButton,
		addObjectButton = addObjectButton,
		addKeyframeButton = addKeyframeButton,
		easingButton = easingButton,
		easingMenu = easingMenu,
		trackListFrame = trackListFrame,
		keyframeAreaFrame = keyframeAreaFrame,
		keyframeTracksContainer = keyframeTracksContainer,
		timelineRuler = timelineRuler,
		playhead = playhead,
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
		propMenu = {
			frame = propMenu,
			layout = propListLayout,
		},
		PIXELS_PER_FRAME_INTERVAL = PIXELS_PER_FRAME_INTERVAL,
		FRAMES_PER_INTERVAL = FRAMES_PER_INTERVAL,
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
				rHolder = colorRHolder, gHolder = colorGHolder, bHolder = colorBHolder,
				r = colorR, g = colorG, b = colorB,
			},
			udim2 = {
				holder = udim2Holder,
				xsHolder = udim2XSHolder, xoHolder = udim2XOHolder,
				ysHolder = udim2YSHolder, yoHolder = udim2YOHolder,
				xs = udim2XS, xo = udim2XO, ys = udim2YS, yo = udim2YO,
			},
			boolean = {
				holder = boolValueHolder,
				nameLabel = boolNameLabel,
				value = boolValue,
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
	OutBounce = function(t)
		local n1=7.5625; local d1=2.75;
		if t < 1/d1 then return n1*t*t
		elseif t < 2/d1 then local t2=t-(1.5/d1); return n1*t2*t2+0.75
		elseif t < 2.5/d1 then local t2=t-(2.25/d1); return n1*t2*t2+0.9375
		else local t2=t-(2.625/d1); return n1*t2*t2+0.984375 end
	end,
	InBounce = function(t) return 1 - EasingFunctions.OutBounce(1-t) end,
	InOutBounce = function(t)
		if t < 0.5 then return (1-EasingFunctions.OutBounce(1-2*t))/2
		else return (1+EasingFunctions.OutBounce(2*t-1))/2 end
	end
}

-- Diurutkan berdasarkan kategori untuk dropdown nanti
local easingStyles = {
	"Linear",
	"InSine", "OutSine", "InOutSine",
	"InQuad", "OutQuad", "InOutQuad",
	"InCubic", "OutCubic", "InOutCubic",
	"InQuart", "OutQuart", "InOutQuart",
	"InQuint", "OutQuint", "InOutQuint",
	"InExpo", "OutExpo", "InOutExpo",
	"InCirc", "OutCirc", "InOutCirc",
	"InBack", "OutBack", "InOutBack",
	"InElastic", "OutElastic", "InOutElastic",
	"InBounce", "OutBounce", "InOutBounce",
}

local animationData = {} 
local currentlySelectedKeyframe = { object = nil, frame = -1, property = nil, marker = nil }
local currentlySelectedTrack = { object = nil, property = nil, label = nil }
local draggingKeyframeInfo = nil
local isDraggingPlayhead = false
local currentlySelectedObject = nil
local isPlaying = false
local playbackConnection = nil
local FRAMES_PER_SECOND = 24
local objectForPropMenu = nil

-- === FUNCTION DEFINITIONS ===

local updateAnimationFromPlayhead
local updatePropertyDisplay
local onHeartbeat
local updateSelectedObjectLabel
local updateCanvasSize
local clearTimeline
local createTrackForObject
local addKeyframeData
local createKeyframeMarkerUI
local deleteTrack
local updateKeyframeValue

function updateKeyframeValue(newValue, componentType, axis)
	local kfInfo = currentlySelectedKeyframe
	if not kfInfo.object or kfInfo.frame == -1 then return end

	local val = tonumber(newValue)
	if not val then return end -- Input tidak valid

	local propData = animationData[kfInfo.object].Properties[kfInfo.property]
	if not propData then return end
	
	local keyframe = propData.keyframes[kfInfo.frame]
	if not keyframe then return end

	local updated = false
	if kfInfo.property == "CFrame" then
		local oldCFrame = keyframe.Value
		local newPos = oldCFrame.Position
		local newRot = Vector3.new(oldCFrame:ToEulerAnglesYXZ())

		if componentType == "Position" then
			newPos = Vector3.new(
				axis == "X" and val or newPos.X,
				axis == "Y" and val or newPos.Y,
				axis == "Z" and val or newPos.Z
			)
			updated = true
		elseif componentType == "Rotation" then
			newRot = Vector3.new(
				axis == "X" and math.rad(val) or newRot.X,
				axis == "Y" and math.rad(val) or newRot.Y,
				axis == "Z" and math.rad(val) or newRot.Z
			)
			updated = true
		end
		
		if updated then
			keyframe.Value = CFrame.new(newPos) * CFrame.fromEulerAnglesYXZ(newRot.Y, newRot.X, newRot.Z)
		end
		
	elseif typeof(keyframe.Value) == "number" and axis == "X" then
		keyframe.Value = val
		updated = true
	elseif typeof(keyframe.Value) == "Vector3" then
		local oldVec = keyframe.Value
		keyframe.Value = Vector3.new(
			axis == "X" and val or oldVec.X,
			axis == "Y" and val or oldVec.Y,
			axis == "Z" and val or oldVec.Z
		)
		updated = true
	elseif typeof(keyframe.Value) == "Color3" then
		local oldColor = keyframe.Value
		keyframe.Value = Color3.new(
			axis == "R" and val or oldColor.R,
			axis == "G" and val or oldColor.G,
			axis == "B" and val or oldColor.B
		)
		updated = true
	elseif typeof(keyframe.Value) == "UDim2" then
		local oldUDim = keyframe.Value
		keyframe.Value = UDim2.new(
			axis == "XS" and val or oldUDim.X.Scale,
			axis == "XO" and val or oldUDim.X.Offset,
			axis == "YS" and val or oldUDim.Y.Scale,
			axis == "YO" and val or oldUDim.Y.Offset
		)
		updated = true
	elseif typeof(keyframe.Value) == "boolean" then
		local lower = newValue:lower()
		if lower == "true" then
			keyframe.Value = true
			updated = true
		elseif lower == "false" then
			keyframe.Value = false
			updated = true
		end
	end

	if updated then
		updateAnimationFromPlayhead()
	end
end

function deleteTrack(object, propName)
	local objectData = animationData[object]
	if not objectData then return end

	-- Jika propName tidak ada, berarti kita menghapus seluruh objek
	if not propName then
		-- Hapus semua sub-track terlebih dahulu
		for name, _ in pairs(objectData.Properties) do
			if name ~= "CFrame" then
				deleteTrack(object, name) -- Panggil rekursif untuk sub-track
			end
		end

		-- Hapus track utama CFrame
		objectData.trackFrame:Destroy()
		objectData.keyframeContainer:Destroy()
		
		-- Hapus data objek
		animationData[object] = nil
		
		if currentlySelectedTrack.object == object then
			currentlySelectedTrack = { object = nil, property = nil, label = nil }
		end

	-- Jika ada propName, kita hanya menghapus sub-track properti
	else
		if objectData.Properties[propName] and propName ~= "CFrame" then
			objectData.Properties[propName] = nil
			
			local subTrackUi = objectData.subTrackFrames[propName]
			if subTrackUi then
				subTrackUi.label:Destroy()
				subTrackUi.keyframes:Destroy()
				objectData.subTrackFrames[propName] = nil
			end

			if currentlySelectedTrack.object == object and currentlySelectedTrack.property == propName then
				currentlySelectedTrack = { object = nil, property = nil, label = nil }
			end
		end
	end
	
	-- Perbarui UI setelah penghapusan
	updateCanvasSize()
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
	currentlySelectedKeyframe = { object = nil, frame = -1, property = nil, marker = nil }
	currentlySelectedTrack = { object = nil, property = nil, label = nil }
	updatePropertyDisplay(nil)
	updateCanvasSize()
	ui.playhead.Position = UDim2.new(0, 0, 0, 0)
end

function createTrackForObject(object, isSubTrack, propName)
	if not isSubTrack and animationData[object] then return end

	local TRACK_HEIGHT = 28
	
	if not isSubTrack then
		print("Membuat track untuk: " .. object.Name)
		animationData[object] = {
			Properties = {
				CFrame = { keyframes = {}, markers = {} }
			},
			trackFrame = nil,
			subTrackFrames = {},
		}
	end
	
	local trackLabelHolder = Instance.new("TextButton")
	trackLabelHolder.Name = (propName or object.Name) .. "_TrackLabel"
	trackLabelHolder.Size = UDim2.new(1, 0, 0, TRACK_HEIGHT)
	trackLabelHolder.BackgroundColor3 = isSubTrack and Color3.fromRGB(65,65,65) or Color3.fromRGB(60, 60, 60)
	trackLabelHolder.BorderSizePixel = 1
	trackLabelHolder.BorderColor3 = Color3.fromRGB(50,50,50)
	trackLabelHolder.Text = ""
	trackLabelHolder.AutoButtonColor = false
	trackLabelHolder.Parent = ui.trackListFrame

	local trackLabel = Instance.new("TextLabel")
	trackLabel.Position = UDim2.new(0, isSubTrack and 15 or 5, 0, 0)
	trackLabel.Text = propName or object.Name
	trackLabel.Font = Enum.Font.SourceSans
	trackLabel.TextSize = 14
	trackLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
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
	deleteTrackButton.TextColor3 = Color3.fromRGB(200, 200, 200)
	deleteTrackButton.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
	deleteTrackButton.Parent = trackLabelHolder

	deleteTrackButton.MouseButton1Click:Connect(function()
		-- Jika ini sub-track, berikan nama propertinya. Jika tidak, kirim nil untuk menghapus seluruh objek.
		deleteTrack(object, isSubTrack and propName or nil)
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
			for _, child in ipairs(ui.propMenu.frame:GetChildren()) do
				if not child:IsA("UIListLayout") then
					child:Destroy()
				end
			end

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
						propButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
						propButton.TextColor3 = Color3.fromRGB(220,220,220)
						propButton.Font = Enum.Font.SourceSans
						propButton.TextXAlignment = Enum.TextXAlignment.Left
						propButton.Parent = ui.propMenu.frame

						propButton.MouseButton1Click:Connect(function()
							if object and not animationData[object].Properties[propName] then
								animationData[object].Properties[propName] = { 
									keyframes = {}, 
									markers = {},
									-- Siapkan untuk komponen
									Components = {},
									ComponentTracks = {},
									IsExpanded = false,
									ValueType = propType -- Simpan tipe nilai
								}
								createTrackForObject(object, true, propName)
								updateCanvasSize()
							end
							ui.propMenu.frame.Visible = false
						end)
					end
				end
			end

			-- Atur posisi dan tampilkan menu properti
			objectForPropMenu = object
			-- Sesuaikan ukuran menu secara dinamis
			local numItems = #ui.propMenu.frame:GetChildren() - 1
			ui.propMenu.frame.Size = UDim2.new(0, 180, 0, math.min(numItems * 26, 300))
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
			expandButton.TextColor3 = Color3.fromRGB(200, 200, 200)
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
	keyframeTrack.Size = UDim2.new(1, 0, 0, TRACK_HEIGHT)
	keyframeTrack.BackgroundColor3 = isSubTrack and Color3.fromRGB(58,58,58) or Color3.fromRGB(55, 55, 55)
	keyframeTrack.BorderSizePixel = 0
	keyframeTrack.ClipsDescendants = true
	keyframeTrack.Parent = ui.keyframeTracksContainer
	
	trackLabelHolder.MouseButton1Click:Connect(function()
		if currentlySelectedTrack.label then
			currentlySelectedTrack.label.BackgroundColor3 = currentlySelectedTrack.isSub and Color3.fromRGB(65,65,65) or Color3.fromRGB(60,60,60)
		end
		trackLabelHolder.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
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
		warn("Attempted to create a keyframe marker for a track with no UI container:", mainPropName, componentName)
		return nil
	end

	local keyframeData = targetTrack and targetTrack.keyframes[frame]
	if not keyframeData then return nil end

	local playheadX = frame * (ui.PIXELS_PER_FRAME_INTERVAL / ui.FRAMES_PER_INTERVAL)
	local TRACK_HEIGHT = 28
	
	local keyframeMarker = Instance.new("TextButton")
	keyframeMarker.Name = tostring(frame)
	keyframeMarker.Text = ""
	keyframeMarker.AnchorPoint = Vector2.new(0.5, 0.5)
	keyframeMarker.Size = UDim2.new(0, 10, 0, 10)
	keyframeMarker.Position = UDim2.new(0, playheadX, 0, TRACK_HEIGHT / 2) 
	keyframeMarker.Rotation = 45
	keyframeMarker.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
	keyframeMarker.Parent = container
	targetTrack.markers[frame] = keyframeMarker
	
	keyframeMarker.MouseButton1Click:Connect(function()
		if currentlySelectedKeyframe.marker then
			currentlySelectedKeyframe.marker.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
		end
		keyframeMarker.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		currentlySelectedKeyframe = { object = object, frame = frame, property = mainPropName, component = componentName, marker = keyframeMarker }
		updatePropertyDisplay(targetTrack.keyframes[frame], componentName or mainPropName)
	end)
	
	keyframeMarker.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingKeyframeInfo = { object = object, originalFrame = frame, property = mainPropName, component = componentName, marker = keyframeMarker }
		end
	end)
	
	return keyframeMarker
end


function updateCanvasSize()
	local totalHeight = 0
	for _, child in ipairs(ui.trackListFrame:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UIListLayout") then
			totalHeight = totalHeight + child.AbsoluteSize.Y
		end
	end
	
	ui.trackListFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
	ui.keyframeAreaFrame.CanvasSize = UDim2.new(0, ui.timelineRuler.AbsoluteSize.X, 0, totalHeight)
end

function updatePropertyDisplay(keyframeData, propName)
	ui.easingButton.Visible = (keyframeData ~= nil)
	
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
		colorLabels.rHolder.Visible = true
		colorLabels.gHolder.Visible = true
		colorLabels.bHolder.Visible = true
		colorLabels.r.Text = format(value.R)
		colorLabels.g.Text = format(value.G)
		colorLabels.b.Text = format(value.B)
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
		boolLabels.value.Text = tostring(value)
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
	
	ui.easingButton.Text = "Easing: " .. keyframeData.Easing
end

function updateAnimationFromPlayhead()
	local pixelsPerFrame = ui.PIXELS_PER_FRAME_INTERVAL / ui.FRAMES_PER_INTERVAL
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
	
	local pixelsPerFrame = ui.PIXELS_PER_FRAME_INTERVAL / ui.FRAMES_PER_INTERVAL
	local pixelsPerSecond = pixelsPerFrame * FRAMES_PER_SECOND
	
	local currentX = ui.playhead.Position.X.Offset
	local newX = currentX + (pixelsPerSecond * deltaTime)
	
	local maxFrame = 0
	for _, objectData in pairs(animationData) do
		for _, propTrack in pairs(objectData.Properties) do
			for frame, _ in pairs(propTrack.keyframes) do
				if frame > maxFrame then
					maxFrame = frame
				end
			end
		end
	end
	local endX = maxFrame * pixelsPerFrame
	
	if newX >= endX and endX > 0 then
		newX = endX
		isPlaying = false
		print("Playback selesai.")
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


-- === EVENT CONNECTIONS & INITIALIZATION ===

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
			local animButton = Instance.new("TextButton")
			animButton.Name = animModule.Name
			animButton.Text = animModule.Name
			animButton.Size = UDim2.new(1, 0, 0, 28)
			animButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
			animButton.TextColor3 = Color3.fromRGB(220,220,220)
			animButton.Font = Enum.Font.SourceSans
			animButton.Parent = ui.loadDialog.list
			
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
	print("Mengekspor animasi...")

	local success, result = pcall(function()
		local animation = Instance.new("Animation")
		animation.Name = "ExportedAnimation" -- TODO: Ask for a name

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
			local time = frame / FRAMES_PER_SECOND
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
						local time = frame / FRAMES_PER_SECOND
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
	else
		warn("Ekspor animasi gagal:", result)
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

ui.timelineRuler.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		-- Guard clause: Jangan mulai menyeret playhead jika sudah menyeret keyframe
		if draggingKeyframeInfo then return end

		isDraggingPlayhead = true
		local mouseX = input.Position.X - ui.timelineRuler.AbsolutePosition.X
		ui.playhead.Position = UDim2.new(0, math.clamp(mouseX, 0, ui.timelineRuler.AbsoluteSize.X), 0, 0)
		updateAnimationFromPlayhead()
	end
end)

inputService.InputChanged:Connect(function(input)
	if isDraggingPlayhead and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local mouseX = input.Position.X - ui.timelineRuler.AbsolutePosition.X
		mouseX = math.clamp(mouseX, 0, ui.timelineRuler.AbsoluteSize.X)
		ui.playhead.Position = UDim2.new(0, mouseX, 0, 0)
		updateAnimationFromPlayhead()
	elseif draggingKeyframeInfo and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local mouseX = input.Position.X - ui.keyframeAreaFrame.AbsolutePosition.X + ui.keyframeAreaFrame.CanvasPosition.X
		mouseX = math.clamp(mouseX, 0, ui.timelineRuler.AbsoluteSize.X)
		draggingKeyframeInfo.marker.Position = UDim2.new(0, mouseX, 0, draggingKeyframeInfo.marker.Position.Y.Offset)
	end
end)

inputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDraggingPlayhead = false
		if draggingKeyframeInfo then
			local marker = draggingKeyframeInfo.marker
			local oldFrame = draggingKeyframeInfo.originalFrame
			local object = draggingKeyframeInfo.object
			local prop = draggingKeyframeInfo.property
			local comp = draggingKeyframeInfo.component
			
			local pixelsPerFrame = ui.PIXELS_PER_FRAME_INTERVAL / ui.FRAMES_PER_INTERVAL
			local newFrame = math.floor(marker.Position.X.Offset / pixelsPerFrame)

			if newFrame ~= oldFrame and object and animationData[object] then
				local propData = animationData[object].Properties[prop]
				local targetTrack = comp and propData.Components[comp] or propData
				
				targetTrack.keyframes[newFrame] = targetTrack.keyframes[oldFrame]
				targetTrack.markers[newFrame] = targetTrack.markers[oldFrame]
				targetTrack.keyframes[oldFrame] = nil
				targetTrack.markers[oldFrame] = nil
				if currentlySelectedKeyframe.marker == marker then
					currentlySelectedKeyframe.frame = newFrame
				end
				print(string.format("Keyframe dipindahkan dari %d ke %d", oldFrame, newFrame))
			else
				marker.Position = UDim2.new(0, oldFrame * pixelsPerFrame, 0, marker.Position.Y.Offset)
			end
			draggingKeyframeInfo = nil
		end
	end
end)

ui.addObjectButton.MouseButton1Click:Connect(function()
	local selectedObjects = selection:Get()
	if #selectedObjects == 0 then return end
	local objectToAdd = selectedObjects[1]
	createTrackForObject(objectToAdd, false)
	updateCanvasSize()
	updateSelectedObjectLabel()
end)

ui.addKeyframeButton.MouseButton1Click:Connect(function()
	if not currentlySelectedTrack.object or not currentlySelectedTrack.property then
		print("Pilih sebuah track properti terlebih dahulu.")
		return
	end

	local selectedObject = currentlySelectedTrack.object
	local fullPropName = currentlySelectedTrack.property
	
	local playheadX = ui.playhead.Position.X.Offset
	local pixelsPerFrame = ui.PIXELS_PER_FRAME_INTERVAL / ui.FRAMES_PER_INTERVAL
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
end)

selection.SelectionChanged:Connect(updateSelectedObjectLabel)

ui.playButton.MouseButton1Click:Connect(function()
	if not isPlaying then
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
	ui.playhead.Position = UDim2.new(0, 0, 0, 0)
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
			ui.propMenu.frame.Visible = false
		end
	end
end)

-- Isi menu dropdown easing
for _, styleName in ipairs(easingStyles) do
	local itemButton = Instance.new("TextButton")
	itemButton.Name = styleName
	itemButton.Text = styleName
	itemButton.Size = UDim2.new(1, 0, 0, 24)
	itemButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
	itemButton.TextColor3 = Color3.fromRGB(220,220,220)
	itemButton.Font = Enum.Font.SourceSans
	itemButton.TextSize = 14
	itemButton.Parent = ui.easingMenu

	itemButton.MouseButton1Click:Connect(function()
		local kfInfo = currentlySelectedKeyframe
		if not kfInfo.object or kfInfo.frame == -1 then return end
		
		local propTrack = animationData[kfInfo.object].Properties[kfInfo.property]
		if propTrack and propTrack.keyframes[kfInfo.frame] then
			propTrack.keyframes[kfInfo.frame].Easing = styleName
			ui.easingButton.Text = "Easing: " .. styleName
			ui.easingMenu.Visible = false
		end
	end)
end

inputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	
	if input.KeyCode == Enum.KeyCode.Delete then
		local kfInfo = currentlySelectedKeyframe
		if kfInfo.marker and kfInfo.object and kfInfo.frame ~= -1 then
			
			local propTrack = animationData[kfInfo.object].Properties[kfInfo.property]
			if propTrack then
				propTrack.keyframes[kfInfo.frame] = nil
				propTrack.markers[kfInfo.frame] = nil
			end

			kfInfo.marker:Destroy()
			currentlySelectedKeyframe = { object = nil, frame = -1, property = nil, marker = nil }
			updatePropertyDisplay(nil)
		end
	end
end)

updateSelectedObjectLabel()
updateCanvasSize()

-- Hubungkan event untuk pengeditan properti
local function connectPropEdit(textbox, component, axis)
	textbox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			updateKeyframeValue(textbox.Text, component, axis)
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
connectPropEdit(ui.propertyLabels.color3.r, nil, "R")
connectPropEdit(ui.propertyLabels.color3.g, nil, "G")
connectPropEdit(ui.propertyLabels.color3.b, nil, "B")

-- UDim2
connectPropEdit(ui.propertyLabels.udim2.xs, nil, "XS")
connectPropEdit(ui.propertyLabels.udim2.xo, nil, "XO")
connectPropEdit(ui.propertyLabels.udim2.ys, nil, "YS")
connectPropEdit(ui.propertyLabels.udim2.yo, nil, "YO")

-- Boolean
connectPropEdit(ui.propertyLabels.boolean.value, nil, nil)
