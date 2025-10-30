Main.server.lua

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
	local genericPropValueX, genericPropValueXHolder = createPropertyDisplay("  - Val", 3)
	
	local posLabel, posHolder = createPropertyDisplay("Position", 4)
	local posX, posXHolder = createPropertyDisplay("  - X", 5)
	local posY, posYHolder = createPropertyDisplay("  - Y", 6)
	local posZ, posZHolder = createPropertyDisplay("  - Z", 7)
	
	local rotLabel, rotHolder = createPropertyDisplay("Rotation", 8)
	local rotX, rotXHolder = createPropertyDisplay("  - X", 9)
	local rotY, rotYHolder = createPropertyDisplay("  - Y", 10)
	local rotZ, rotZHolder = createPropertyDisplay("  - Z", 11)
	
	local easingButton = Instance.new("TextButton")
	easingButton.Name = "EasingButton"
	easingButton.Size = UDim2.new(1, -10, 0, 24)
	easingButton.Position = UDim2.new(0, 5, 0, 0)
	easingButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	easingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	easingButton.Font = Enum.Font.SourceSans
	easingButton.TextSize = 14
	easingButton.Text = "Easing: Linear"
	easingButton.LayoutOrder = 12
	easingButton.Visible = false
	easingButton.Parent = propertiesFrame
	
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
	local propMenu = Instance.new("Frame")
	propMenu.Name = "PropertyMenu"
	propMenu.Visible = false
	propMenu.Size = UDim2.new(0, 150, 0, 100)
	propMenu.BackgroundColor3 = Color3.fromRGB(60,60,60)
	propMenu.BorderColor3 = Color3.fromRGB(90,90,90)
	propMenu.ZIndex = 10
	propMenu.Parent = mainFrame
	
	local propListLayout = Instance.new("UIListLayout")
	propListLayout.Padding = UDim.new(0, 2)
	propListLayout.Parent = propMenu


	return {
		selectedObjectLabel = selectedObjectLabel,
		saveButton = saveButton,
		loadButton = loadButton,
		exportButton = exportButton,
		playButton = playButton,
		stopButton = stopButton,
		addObjectButton = addObjectButton,
		addKeyframeButton = addKeyframeButton,
		easingButton = easingButton,
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
	EaseIn = function(t) return t * t end,
	EaseOut = function(t) return 1 - (1 - t) * (1 - t) end,
}
local easingStyles = {"Linear", "EaseIn", "EaseOut"}
local animatableProperties = {"Transparency", "Size"}

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
local createKeyframeMarker

function lerp(a, b, alpha)
	local dataType = typeof(a)
	if dataType == "number" then
		return a + (b - a) * alpha
	elseif dataType == "Vector3" then
		return a:Lerp(b, alpha)
	elseif dataType == "CFrame" then
		return a:Lerp(b, alpha)
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
	trackLabel.Size = UDim2.new(1, -30, 1, 0)
	trackLabel.Position = UDim2.new(0, isSubTrack and 15 or 5, 0, 0)
	trackLabel.Text = propName or object.Name
	trackLabel.Font = Enum.Font.SourceSans
	trackLabel.TextSize = 14
	trackLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	trackLabel.BackgroundTransparency = 1
	trackLabel.TextXAlignment = Enum.TextXAlignment.Left
	trackLabel.Parent = trackLabelHolder
	
	if not isSubTrack then
		local addPropButton = Instance.new("TextButton")
		addPropButton.Size = UDim2.new(0, 20, 0, 20)
		addPropButton.Position = UDim2.new(1, -25, 0.5, -10)
		addPropButton.Text = "+"
		addPropButton.Font = Enum.Font.SourceSansBold
		addPropButton.TextSize = 16
		addPropButton.Parent = trackLabelHolder
		
		addPropButton.MouseButton1Click:Connect(function()
			objectForPropMenu = object
			ui.propMenu.frame.Position = UDim2.new(0, addPropButton.AbsolutePosition.X - 150, 0, addPropButton.AbsolutePosition.Y + 25)
			ui.propMenu.frame.Visible = true
		end)
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
end

function createKeyframeMarker(object, propName, frame, value, easing)
	local objectData = animationData[object]
	local propTrack = objectData.Properties[propName]
	
	propTrack.keyframes[frame] = {
		Value = value,
		Easing = easing
	}
	
	local container = (propName == "CFrame") and objectData.keyframeContainer or objectData.subTrackFrames[propName].keyframes
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
	propTrack.markers[frame] = keyframeMarker
	
	keyframeMarker.MouseButton1Click:Connect(function()
		if currentlySelectedKeyframe.marker then
			currentlySelectedKeyframe.marker.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
		end
		keyframeMarker.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		currentlySelectedKeyframe = { object = object, frame = frame, property = propName, marker = keyframeMarker }
		updatePropertyDisplay(propTrack.keyframes[frame], propName)
	end)
	
	keyframeMarker.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingKeyframeInfo = { object = object, originalFrame = frame, property = propName, marker = keyframeMarker }
			input:SetSupercededBy(keyframeMarker)
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
	ui.keyframeAreaFrame.CanvasSize = UDim2.new(0, ui.timelineRuler.AbsoluteSize.X.Offset, 0, totalHeight)
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
		local function format(num) return string.format("%.2f", num) end
		cframeLabels.posX.Text = format(pos.X)
		cframeLabels.posY.Text = format(pos.Y)
		cframeLabels.posZ.Text = format(pos.Z)
		cframeLabels.rotX.Text = format(math.deg(rot.X))
		cframeLabels.rotY.Text = format(math.deg(rot.Y))
		cframeLabels.rotZ.Text = format(math.deg(rot.Z))
	else
		local genericLabels = ui.propertyLabels.generic
		genericLabels.holder.Visible = true
		genericLabels.nameLabel.Text = propName
		
		local valueType = typeof(value)
		if valueType == "number" then
			genericLabels.xHolder.Visible = true
			genericLabels.x.Text = string.format("%.2f", value)
			genericLabels.yHolder.Visible = false
			genericLabels.zHolder.Visible = false
		elseif valueType == "Vector3" then
			genericLabels.xHolder.Visible = true
			genericLabels.yHolder.Visible = true
			genericLabels.zHolder.Visible = true
			genericLabels.x.Text = string.format("%.2f", value.X)
			genericLabels.y.Text = string.format("%.2f", value.Y)
			genericLabels.z.Text = string.format("%.2f", value.Z)
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
		
		for propName, propTrack in pairs(objectAnimData.Properties) do
			local sortedFrames = {}
			for frameNumber, _ in pairs(propTrack.keyframes) do
				table.insert(sortedFrames, frameNumber)
			end
			table.sort(sortedFrames)
			
			if #sortedFrames == 0 then continue end

			local prevFrame, nextFrame
			if currentFrame < sortedFrames[1] then
				prevFrame, nextFrame = sortedFrames[1], sortedFrames[1]
			elseif currentFrame >= sortedFrames[#sortedFrames] then
				prevFrame, nextFrame = sortedFrames[#sortedFrames], sortedFrames[#sortedFrames]
			else
				for i = 1, #sortedFrames - 1 do
					if sortedFrames[i] <= currentFrame and sortedFrames[i+1] > currentFrame then
						prevFrame, nextFrame = sortedFrames[i], sortedFrames[i+1]
						break
					end
				end
			end
			
			if prevFrame and nextFrame then
				local prevKeyframeData = propTrack.keyframes[prevFrame]
				local nextKeyframeData = propTrack.keyframes[nextFrame]
				
				local interpolatedValue
				if prevFrame == nextFrame then
					interpolatedValue = prevKeyframeData.Value
				else
					local alpha = (currentFrame - prevFrame) / (nextFrame - prevFrame)
					local easingStyle = prevKeyframeData.Easing or "Linear"
					local easingFunction = EasingFunctions[easingStyle] or EasingFunctions.Linear
					local easedAlpha = easingFunction(alpha)
					interpolatedValue = lerp(prevKeyframeData.Value, nextKeyframeData.Value, easedAlpha)
				end
				
				if interpolatedValue then
					object[propName] = interpolatedValue
				end
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
				end
				
				if valueToSave then
					keyframes[tostring(frame)] = {
						Value = valueToSave,
						Easing = keyframeData.Easing
					}
				end
			end
			properties[propName] = { Keyframes = keyframes }
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
								animationData[object].Properties[propName] = { keyframes = {}, markers = {} }
								createTrackForObject(object, true, propName)
							end
							
							for frameStr, keyframeData in pairs(propTrackData.Keyframes) do
								local frame = tonumber(frameStr)
								local savedValue = keyframeData.Value
								
								local value
								if savedValue.vType == "CFrame" then
									value = CFrame.new(unpack(savedValue.comps))
								elseif savedValue.vType == "Vector3" then
									value = Vector3.new(savedValue.x, savedValue.y, savedValue.z)
								elseif savedValue.vType == "number" then
									value = savedValue.val
								end

								if value then
									createKeyframeMarker(object, propName, frame, value, keyframeData.Easing)
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

		local function convertEasing(easingName)
			if easingName == "EaseIn" then
				return Enum.EasingStyle.Quad, Enum.EasingDirection.In
			elseif easingName == "EaseOut" then
				return Enum.EasingStyle.Quad, Enum.EasingDirection.Out
			else -- Default to Linear
				return Enum.EasingStyle.Linear, Enum.EasingDirection.InOut
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
					local style, direction = convertEasing(easingName)
					pose.EasingStyle = style
					pose.EasingDirection = direction
					
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
							local style, direction = convertEasing(easingName)
							propKeyframe.EasingStyle = style
							propKeyframe.EasingDirection = direction
							
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
			
			local pixelsPerFrame = ui.PIXELS_PER_FRAME_INTERVAL / ui.FRAMES_PER_INTERVAL
			local newFrame = math.floor(marker.Position.X.Offset / pixelsPerFrame)

			if newFrame ~= oldFrame and object and animationData[object] then
				local propTrack = animationData[object].Properties[prop]
				propTrack.keyframes[newFrame] = propTrack.keyframes[oldFrame]
				propTrack.markers[newFrame] = propTrack.markers[oldFrame]
				propTrack.keyframes[oldFrame] = nil
				propTrack.markers[oldFrame] = nil
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
	local propName = currentlySelectedTrack.property
	local propTrack = animationData[selectedObject].Properties[propName]
	
	local playheadX = ui.playhead.Position.X.Offset
	local pixelsPerFrame = ui.PIXELS_PER_FRAME_INTERVAL / ui.FRAMES_PER_INTERVAL
	local currentFrame = math.floor(playheadX / pixelsPerFrame)
	
	if propTrack.keyframes[currentFrame] then
		print("Keyframe untuk " .. propName .. " sudah ada di frame ini.")
		return
	end

	createKeyframeMarker(selectedObject, propName, currentFrame, selectedObject[propName], "Linear")
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
	local kfInfo = currentlySelectedKeyframe
	if not kfInfo.object or kfInfo.frame == -1 or not kfInfo.property then return end
	
	local propTrack = animationData[kfInfo.object].Properties[kfInfo.property]
	if not propTrack or not propTrack.keyframes[kfInfo.frame] then return end
	
	local currentEasing = propTrack.keyframes[kfInfo.frame].Easing
	local currentIndex = table.find(easingStyles, currentEasing) or 1
	local nextIndex = (currentIndex % #easingStyles) + 1
	local newEasing = easingStyles[nextIndex]

	propTrack.keyframes[kfInfo.frame].Easing = newEasing
	ui.easingButton.Text = "Easing: " .. newEasing
end)

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

for _, propName in ipairs(animatableProperties) do
	local propButton = Instance.new("TextButton")
	propButton.Name = propName
	propButton.Text = propName
	propButton.Size = UDim2.new(1, 0, 0, 24)
	propButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
	propButton.TextColor3 = Color3.fromRGB(220,220,220)
	propButton.Parent = ui.propMenu.layout.Parent
	
	propButton.MouseButton1Click:Connect(function()
		if objectForPropMenu and not animationData[objectForPropMenu].Properties[propName] then
			animationData[objectForPropMenu].Properties[propName] = { keyframes = {}, markers = {} }
			local mainTrack = animationData[objectForPropMenu].trackFrame
			createTrackForObject(objectForPropMenu, true, propName)
			updateCanvasSize()
		end
		ui.propMenu.frame.Visible = false
	end)
end

updateSelectedObjectLabel()
updateCanvasSize()
