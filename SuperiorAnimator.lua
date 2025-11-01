--SuperiorAnimator.lua

local PLUGIN_NAME = "SuperiorAnimator"
local PLUGIN_VERSION = "0.1.0"

-- === KONFIGURASI ===
local Config = require(script.src.Config)

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
local addKeyframeAction

-- Fungsi ini HANYA membuat dan mengembalikan elemen-elemen UI.
local UIManager = require(script.src.UIManager)

-- === LOGIKA UTAMA PLUGIN ===
local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float, true, false, 800, 600, 600, 400
)
local mainWidget = plugin:CreateDockWidgetPluginGui("SuperiorAnimator_Main", widgetInfo)
mainWidget.Title = PLUGIN_NAME
mainWidget.Name = "SuperiorAnimator"

local ui = UIManager.create(mainWidget, Config)

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local newAnimationButton = toolbar:CreateButton(
	"Superior Animator", "Buka Superior Animator", "rbxassetid://448737683"
)

-- === DATA & STATE VARIABLES ===
local RunService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
local selection = game:GetService("Selection")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Definisikan OutBounce secara terpisah untuk mengatasi masalah forward declaration
local EasingModule = require(script.src.EasingFunctions)
local EasingFunctions = EasingModule.Functions
local easingStyles = EasingModule.Styles

local state = {
	animationData = {},
	currentSelection = {
		type = nil, -- "Keyframe", "Event"
		data = {} -- List of selected items (kfInfo or eventInfo)
	},
	currentlySelectedTrack = { object = nil, property = nil, label = nil },
	draggingKeyframeInfo = nil,
	isDraggingPlayhead = false,
	draggingPlaybackHandle = nil, -- "Start" or "End"
	currentlySelectedObject = nil,
	playbackConnection = nil,
	objectForPropMenu = nil,
	confirmAction = nil,
	contextMenuTarget = nil,
	keyframeClipboard = nil,
	isAutoKeyingEnabled = false,
	autoKeyConnections = {}, -- [Instance] = RBXScriptConnection
	debounceThreads = {}, -- [Instance][propName] = thread
	isMarqueeSelecting = false,
	marqueeStartPoint = Vector2.new(0, 0),
	zoomLevel = 1.0, -- 1.0 = 100% zoom
	playbackSpeed = 1.0, -- 1.0 = 100% speed
	isLoopingEnabled = false,
	originalCameraType = nil,
}

-- === MODUL LOGIKA ===
local TimelineLogic = require(script.src.TimelineLogic)
local timeline = TimelineLogic.new(state.animationData, Config, state)

-- === PENGELOLA RIWAYAT TINDAKAN (UNDO/REDO) ===
local ActionHistoryManager = require(script.src.ActionHistory)
local ActionHistory = ActionHistoryManager.new(ui, Config)


-- === FUNCTION DEFINITIONS ===

local function createEventMarkerUI(object, frame, name)
	local objectUID = object:GetAttribute("SuperiorAnimator_UID")
	if not objectUID or not state.animationData[objectUID] then return nil end

	local eventTrack = state.animationData[objectUID].Events
	local container = state.animationData[objectUID].eventTrackUI.keyframes
	if not container then return nil end

	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
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
		if state.currentSelection.type ~= "Event" then
			for _, selectedInfo in ipairs(state.currentSelection.data) do
				if selectedInfo.marker and selectedInfo.marker.Parent then
				local selectedObjectUID = selectedInfo.object:GetAttribute("SuperiorAnimator_UID")
				if not selectedObjectUID then continue end
				local prevPropData = state.animationData[selectedObjectUID].Properties[selectedInfo.property]
					if prevPropData then
						local prevKeyframeData = (selectedInfo.component and prevPropData.Components[selectedInfo.component] or prevPropData).keyframes[selectedInfo.frame]
						if prevKeyframeData then
							selectedInfo.marker.BackgroundColor3 = if prevKeyframeData.Easing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
						end
					end
				end
			end
			state.currentSelection = { type = "Event", data = {} }
		end

		for _, sel in ipairs(state.currentSelection.data) do
			if sel.marker and sel.marker.Parent then
				sel.marker.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
			end
		end
		state.currentSelection.data = {}

		table.insert(state.currentSelection.data, { object = object, frame = frame, marker = marker })
		marker.BackgroundColor3 = Config.Colors.KeyframeSelected

		updatePropertyDisplay(nil, nil, eventTrack.keyframes[frame])
	end)

	marker.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			local options = {
				{ Text = "Delete Event", Callback = function(target)
					local objectUID = target.object:GetAttribute("SuperiorAnimator_UID")
					if not objectUID then return end
					local eventTrack = state.animationData[objectUID].Events
					local eventData = eventTrack.keyframes[target.frame]
					if not eventData then return end

					local action = {
						redo = function()
							if eventTrack.markers[target.frame] then
								eventTrack.markers[target.frame]:Destroy()
								eventTrack.markers[target.frame] = nil
								eventTrack.keyframes[target.frame] = nil
							end
							state.currentSelection = { type = nil, data = {} }
							updatePropertyDisplay(nil,nil,nil)
							updateTimelineRuler()
						end,
						undo = function()
							createEventMarkerUI(target.object, target.frame, eventData.Name)
							updateTimelineRuler()
						end
					}
					ActionHistory:register(action)
					action.redo()
				end}
			}
			openContextMenu({object = object, frame = frame, marker = marker}, options)
		end
	end)

	return marker
end



local function connectAutoKeyListener(object)
	local objectUID = object:GetAttribute("SuperiorAnimator_UID")
	if not state.isAutoKeyingEnabled or state.autoKeyConnections[object] or not (objectUID and state.animationData[objectUID]) then
		return
	end

	state.autoKeyConnections[object] = object.Changed:Connect(function(propName)
		local objectData = state.animationData[objectUID]
		if not objectData or not objectData.Properties[propName] then
			return
		end

		if not state.debounceThreads[object] then state.debounceThreads[object] = {} end

		if state.debounceThreads[object][propName] then
			task.cancel(state.debounceThreads[object][propName])
		end

		state.debounceThreads[object][propName] = task.delay(0.1, function()
			local playheadX = ui.playhead.Position.X.Offset
			local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
			local currentFrame = math.floor(playheadX / pixelsPerFrame)

			local propData = objectData.Properties[propName]
			local newValue = object[propName]

			local existingKeyframe = propData.keyframes[currentFrame]
			if existingKeyframe then
				existingKeyframe.Value = newValue
			else
				addKeyframeData(object, propName, currentFrame, newValue, "Linear", nil)
				createKeyframeMarkerUI(object, propName, currentFrame, nil)
				updateTimelineRuler()
			end

			if state.currentSelection.type == "Keyframe" and #state.currentSelection.data == 1 and state.currentSelection.data[1].object == object and state.currentSelection.data[1].property == propName and state.currentSelection.data[1].frame == currentFrame then
				updatePropertyDisplay(propData.keyframes[currentFrame], propName)
			end

			state.debounceThreads[object][propName] = nil
		end)
	end)
end

local function disconnectAutoKeyListener(object)
	if state.autoKeyConnections[object] then
		state.autoKeyConnections[object]:Disconnect()
		state.autoKeyConnections[object] = nil
	end

	if state.debounceThreads[object] then
		for propName, thread in pairs(state.debounceThreads[object]) do
			if thread then
				task.cancel(thread)
			end
		end
		state.debounceThreads[object] = nil
	end
end

local function showNotification(title, message)
	ui.notificationDialog.title.Text = title
	ui.notificationDialog.message.Text = message
	ui.notificationDialog.gui.Enabled = true
end

local function showConfirmation(title, message, onConfirm)
	ui.confirmDialog.title.Text = title
	ui.confirmDialog.message.Text = message
	state.confirmAction = onConfirm
	ui.confirmDialog.gui.Enabled = true
end

function handleKeyframeSelection(kfInfo, forceShift)
	local keyframeMarker = kfInfo.marker
	local object = kfInfo.object
	local mainPropName = kfInfo.property
	local componentName = kfInfo.component
	local frame = kfInfo.frame

	local objectUID = object:GetAttribute("SuperiorAnimator_UID")
	if not objectUID then return end

	local objectData = state.animationData[objectUID]
	if not objectData then return end

	local propData = objectData.Properties[mainPropName]
	if not propData then return end

	local targetTrack = componentName and propData.Components[componentName] or propData
	if not targetTrack then return end

	local isShiftDown = forceShift or inputService:IsKeyDown(Enum.KeyCode.LeftShift) or inputService:IsKeyDown(Enum.KeyCode.RightShift)

	if not isShiftDown or state.currentSelection.type ~= "Keyframe" then
		for _, selectedInfo in ipairs(state.currentSelection.data) do
			if selectedInfo.marker ~= keyframeMarker and selectedInfo.marker and selectedInfo.marker.Parent then
				local objectUID = selectedInfo.object:GetAttribute("SuperiorAnimator_UID")
				if objectUID and state.animationData[objectUID] then
					local prevPropData = state.animationData[objectUID].Properties[selectedInfo.property]
					if prevPropData then
						local prevTargetTrack = selectedInfo.component and prevPropData.Components[selectedInfo.component] or prevPropData
						if prevTargetTrack and prevTargetTrack.keyframes[selectedInfo.frame] then
							local prevKeyframeData = prevTargetTrack.keyframes[selectedInfo.frame]
							selectedInfo.marker.BackgroundColor3 = if prevKeyframeData.Easing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
						end
					end
				end
			end
		end
		state.currentSelection = { type = "Keyframe", data = {} }
	end

	local alreadySelected = false
	local selectionIndex = -1
	for i, selectedInfo in ipairs(state.currentSelection.data) do
		if selectedInfo.marker == keyframeMarker then
			alreadySelected = true
			selectionIndex = i
			break
		end
	end

	if isShiftDown and alreadySelected then
		local selectedInfo = state.currentSelection.data[selectionIndex]
		local objectUID = selectedInfo.object:GetAttribute("SuperiorAnimator_UID")
		if not (objectUID and state.animationData[objectUID]) then return end
		local prevPropData = state.animationData[objectUID].Properties[selectedInfo.property]
		local prevTargetTrack = selectedInfo.component and prevPropData.Components[selectedInfo.component] or prevPropData
		local prevKeyframeData = prevTargetTrack.keyframes[selectedInfo.frame]
		selectedInfo.marker.BackgroundColor3 = if prevKeyframeData.Easing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
		table.remove(state.currentSelection.data, selectionIndex)
	elseif not alreadySelected then
		table.insert(state.currentSelection.data, kfInfo)
		keyframeMarker.BackgroundColor3 = Config.Colors.KeyframeSelected
	end

	if #state.currentSelection.data == 1 then
		local info = state.currentSelection.data[1]
		local objectUID = info.object:GetAttribute("SuperiorAnimator_UID")
		if not (objectUID and state.animationData[objectUID]) then return end
		local data = state.animationData[objectUID].Properties[info.property]
		local track = info.component and data.Components[info.component] or data
		updatePropertyDisplay(track.keyframes[info.frame], info.component or info.property, nil)
	else
		updatePropertyDisplay(nil, nil, nil)
	end
end

function openContextMenu(target, options)
	state.contextMenuTarget = target
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
	if state.currentSelection.type == "Keyframe" and #state.currentSelection.data == 1 then
		kfInfo = state.currentSelection.data[1]
	elseif state.currentSelection.type == "Event" and #state.currentSelection.data == 1 then
		local eventInfo = state.currentSelection.data[1]
		local objectUID = eventInfo.object:GetAttribute("SuperiorAnimator_UID")
		if not objectUID then return end
		local eventTrack = state.animationData[objectUID].Events
		local eventData = eventTrack.keyframes[eventInfo.frame]
		if not eventData then return end

		local oldName = eventData.Name
		local newName = tostring(newValue)
		if oldName == newName or newName == "" then return end

		local action = {
			redo = function()
				state.animationData[objectUID].Events.keyframes[eventInfo.frame].Name = newName
				updatePropertyDisplay(nil, nil, { Name = newName })
			end,
			undo = function()
				state.animationData[objectUID].Events.keyframes[eventInfo.frame].Name = oldName
				updatePropertyDisplay(nil, nil, { Name = oldName })
			end
		}
		ActionHistory:register(action)
		action.redo()
		return
	else
		return
	end

	local val
	if typeof(newValue) == "string" then
		val = tonumber(newValue)
		if not val then return end
	else
		val = newValue
	end

	local objectUID = kfInfo.object:GetAttribute("SuperiorAnimator_UID")
	if not objectUID then return end

	local propData = state.animationData[objectUID].Properties[kfInfo.property]
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
			local objectUID = kfInfo.object:GetAttribute("SuperiorAnimator_UID")
			if not (objectUID and state.animationData[objectUID]) then return end
			local kf = state.animationData[objectUID].Properties[kfInfo.property].keyframes[kfInfo.frame]
			kf.Value = finalNewValue
			updatePropertyDisplay(kf, kfInfo.component or kfInfo.property)
			timeline:setCurrentFrame(timeline.currentFrame) -- Force update
		end,
		undo = function()
			local objectUID = kfInfo.object:GetAttribute("SuperiorAnimator_UID")
			if not (objectUID and state.animationData[objectUID]) then return end
			local kf = state.animationData[objectUID].Properties[kfInfo.property].keyframes[kfInfo.frame]
			kf.Value = oldValue
			updatePropertyDisplay(kf, kfInfo.component or kfInfo.property, nil)
			timeline:setCurrentFrame(timeline.currentFrame) -- Force update
		end
	}
	ActionHistory:register(action)
	action.redo()
end

function deleteTrack(object, propName)
	local objectUID
	if object:IsA("Camera") then
		objectUID = "SuperiorAnimator_Camera"
	else
		objectUID = object:GetAttribute("SuperiorAnimator_UID")
	end

	if not objectUID then return end

	local objectData = state.animationData[objectUID]
	if not objectData then return end

	local trackDataToSave = {}
	local isFullObjectDeletion = not propName

	if isFullObjectDeletion then
		trackDataToSave = state.animationData[objectUID]
	elseif objectData.Properties[propName] and propName ~= "CFrame" then
		trackDataToSave[propName] = objectData.Properties[propName]
	else
		return
	end

	local action = {
		redo = function()
			local objData = state.animationData[objectUID]
			if not objData then return end

			if isFullObjectDeletion then
				for name, _ in pairs(objData.Properties) do
					if name ~= "CFrame" then
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
				state.animationData[objectUID] = nil
			else
				local subTrackUi = objData.subTrackFrames[propName]
				if subTrackUi then
					subTrackUi.label:Destroy()
					subTrackUi.keyframes:Destroy()
				end
				objData.Properties[propName] = nil
				objData.subTrackFrames[propName] = nil
			end

			if state.currentlySelectedTrack.object == object and (isFullObjectDeletion or state.currentlySelectedTrack.property == propName) then
				state.currentlySelectedTrack = { object = nil, property = nil, label = nil }
			end
			updateCanvasSize()
		end,
		undo = function()
			if isFullObjectDeletion then
				state.animationData[objectUID] = trackDataToSave
				createTrackForObject(object, false)
				for name, propData in pairs(trackDataToSave.Properties) do
					if name ~= "CFrame" then
						createTrackForObject(object, true, name)
						for frame, _ in pairs(propData.keyframes) do
							createKeyframeMarkerUI(object, name, frame, nil)
						end
					end
				end
				for frame, _ in pairs(trackDataToSave.Properties.CFrame.keyframes) do
					createKeyframeMarkerUI(object, "CFrame", frame, nil)
				end
				connectAutoKeyListener(object)
			else
				local objData = state.animationData[objectUID]
				objData.Properties[propName] = trackDataToSave[propName]
				createTrackForObject(object, true, propName)
				for frame, _ in pairs(trackDataToSave[propName].keyframes) do
					createKeyframeMarkerUI(object, propName, frame, nil)
				end
			end
			updateCanvasSize()
		end
	}

	ActionHistory:register(action)
	action.redo()
end

function clearTimeline()
	for _, child in ipairs(ui.trackListFrame:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UIListLayout") then child:Destroy() end
	end
	for _, child in ipairs(ui.keyframeTracksContainer:GetChildren()) do
		if child:IsA("GuiObject") and not child:IsA("UIListLayout") then child:Destroy() end
	end
	state.animationData = {}
	state.currentSelection = { type = nil, data = {} }
	state.currentlySelectedTrack = { object = nil, property = nil, label = nil }
	updatePropertyDisplay(nil)
	updateCanvasSize()
	timeline:stop()
	updateScrubberFromTimeline()
end

function createTrackForObject(object, isSubTrack, propName, uid)
	-- Gunakan UID sebagai kunci utama untuk pengecekan
	if not isSubTrack and uid and state.animationData[uid] then return end

	-- Dapatkan UID jika belum ada
	local objectUID = uid
	if object:IsA("Camera") then
		objectUID = "SuperiorAnimator_Camera"
	else
		objectUID = objectUID or object:GetAttribute("SuperiorAnimator_UID")
		if not objectUID then
			objectUID = HttpService:GenerateGUID(false)
			object:SetAttribute("SuperiorAnimator_UID", objectUID)
		end
	end

	if not isSubTrack then
		print("Membuat track untuk: " .. object.Name .. " (UID: " .. objectUID .. ")")
		state.animationData[objectUID] = {
			object = object, -- Simpan referensi objek
			uid = objectUID,    -- Simpan UID
			Properties = {
				CFrame = { keyframes = {}, markers = {} }
			},
			Events = { keyframes = {}, markers = {} },
			trackFrame = nil,
			subTrackFrames = {},
		}
		connectAutoKeyListener(object)
	end

	local trackLabelHolder = Instance.new("Frame")
	trackLabelHolder.Name = (propName or object.Name) .. "_TrackLabel"
	trackLabelHolder.Size = UDim2.new(1, 0, 0, Config.TRACK_HEIGHT)
	trackLabelHolder.BackgroundColor3 = isSubTrack and Config.Colors.SubTrackLabelBackground or Config.Colors.TrackListBackground
	trackLabelHolder.BorderSizePixel = 1
	trackLabelHolder.BorderColor3 = Config.Colors.ContentBackground
	trackLabelHolder.Parent = ui.trackListFrame

	local selectionButton = Instance.new("TextButton")
	selectionButton.Name = "SelectionButton"
	selectionButton.Size = UDim2.new(1, 0, 1, 0)
	selectionButton.Text = ""
	selectionButton.BackgroundTransparency = 1
	selectionButton.ZIndex = 1
	selectionButton.Parent = trackLabelHolder

	local trackLabel = Instance.new("TextLabel")
	trackLabel.Position = UDim2.new(0, isSubTrack and 15 or 5, 0, 0)
	trackLabel.Text = propName or object.Name
	trackLabel.Font = Enum.Font.SourceSans
	trackLabel.TextSize = 14
	trackLabel.TextColor3 = Config.Colors.TextSecondary
	trackLabel.BackgroundTransparency = 1
	trackLabel.TextXAlignment = Enum.TextXAlignment.Left
	trackLabel.ZIndex = 2
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
	deleteTrackButton.ZIndex = 3
	deleteTrackButton.Parent = trackLabelHolder

	deleteTrackButton.MouseButton1Click:Connect(function()
		local trackName = isSubTrack and propName or object.Name
		local title = "Hapus Track"
		local message = "Apakah Anda yakin ingin menghapus track '" .. trackName .. "'?"

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
		addPropButton.ZIndex = 3
		addPropButton.Parent = trackLabelHolder

		addPropButton.MouseButton1Click:Connect(function()
			for _, child in ipairs(ui.propMenu.list:GetChildren()) do
				if not child:IsA("UIListLayout") then
					child:Destroy()
				end
			end
			ui.propMenu.searchBox.Text = ""

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

			for className, props in pairs(animatablePropertiesByClass) do
				if object:IsA(className) then
					for _, propName in ipairs(props) do
						propsToShow[propName] = true
					end
				end
			end

			local sortedPropNames = {}
			for name, _ in pairs(propsToShow) do
				table.insert(sortedPropNames, name)
			end
			table.sort(sortedPropNames)

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
							if object and not state.animationData[objectUID].Properties[propName] then
								local action = {
									redo = function()
										state.animationData[objectUID].Properties[propName] = {
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
								ActionHistory:register(action)
								action.redo()
							end
							ui.propMenu.frame.Visible = false
						end)
					end
				end
			end

			state.objectForPropMenu = object
			local numItems = #ui.propMenu.list:GetChildren() - 1
			local listHeight = math.min(numItems * 26, 250 - 32)
			ui.propMenu.frame.Size = UDim2.new(0, 180, 0, listHeight + 32)
			ui.propMenu.frame.Position = UDim2.new(0, addPropButton.AbsolutePosition.X - 180, 0, addPropButton.AbsolutePosition.Y + 25)
			ui.propMenu.frame.Visible = true
		end)
	else
		local expandableTypes = {Vector3 = {"X", "Y", "Z"}, Color3 = {"R", "G", "B"}, UDim2 = {"XScale", "XOffset", "YScale", "YOffset"}}
		local propData = state.animationData[objectUID] and state.animationData[objectUID].Properties[propName]
		local isExpandable = propData and expandableTypes[propData.ValueType]

		if isExpandable then
			trackLabel.Size = UDim2.new(1, -55, 1, 0)

			local expandButton = Instance.new("TextButton")
			expandButton.Name = "ExpandButton"
			expandButton.Size = UDim2.new(0, 20, 0, 20)
			expandButton.Position = UDim2.new(0, 5, 0.5, -10)
			expandButton.Text = ">"
			expandButton.Font = Enum.Font.SourceSansBold
			expandButton.TextSize = 14
			expandButton.TextColor3 = Config.Colors.TextMuted
			expandButton.BackgroundTransparency = 1
			expandButton.ZIndex = 2
			expandButton.Parent = trackLabelHolder

			trackLabel.Position = UDim2.new(0, 25, 0, 0)

			expandButton.MouseButton1Click:Connect(function()
				propData.IsExpanded = not propData.IsExpanded
				expandButton.Text = propData.IsExpanded and "v" or ">"

				if propData.IsExpanded then
					local components = expandableTypes[propData.ValueType]
					for i, compName in ipairs(components) do
						local componentTrackName = propName .. "." .. compName
						local compTrackLabel, compKeyframeTrack = createTrackForObject(object, true, componentTrackName)
						propData.ComponentTracks[compName] = {label = compTrackLabel, keyframes = compKeyframeTrack}

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
			trackLabel.Size = UDim2.new(1, -30, 1, 0)
		end
	end

	local keyframeTrack = Instance.new("Frame")
	keyframeTrack.Name = (propName or object.Name) .. "_KeyframeTrack"
	keyframeTrack.Size = UDim2.new(1, 0, 0, Config.TRACK_HEIGHT)
	keyframeTrack.BackgroundColor3 = isSubTrack and Config.Colors.SubTrackBackground or Config.Colors.TrackBackground
	keyframeTrack.BorderSizePixel = 0
	keyframeTrack.ClipsDescendants = true
	keyframeTrack.Parent = ui.keyframeTracksContainer

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
		eventTrackLabel.LayoutOrder = trackLabelHolder.LayoutOrder + 1
		eventTrackLabel.Parent = ui.trackListFrame

		local eventKeyframeTrack = Instance.new("Frame")
		eventKeyframeTrack.Name = object.Name .. "_EventKeyframeTrack"
		eventKeyframeTrack.Size = UDim2.new(1, 0, 0, Config.TRACK_HEIGHT)
		eventKeyframeTrack.BackgroundColor3 = Config.Colors.SubTrackBackground
		eventKeyframeTrack.BorderSizePixel = 0
		eventKeyframeTrack.ClipsDescendants = true
		eventKeyframeTrack.LayoutOrder = keyframeTrack.LayoutOrder + 1
		eventKeyframeTrack.Parent = ui.keyframeTracksContainer

		state.animationData[objectUID].eventTrackUI = {
			label = eventTrackLabel,
			keyframes = eventKeyframeTrack
		}

		eventKeyframeTrack.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
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
								local eventTrack = state.animationData[target.object].Events
								if eventTrack.markers[target.frame] then
									eventTrack.markers[target.frame]:Destroy()
									eventTrack.markers[target.frame] = nil
									eventTrack.keyframes[target.frame] = nil
								end
								updateTimelineRuler()
							end
						}
						ActionHistory:register(action)
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

	selectionButton.MouseButton1Click:Connect(function()
		if state.currentlySelectedTrack.label then
			state.currentlySelectedTrack.label.BackgroundColor3 = state.currentlySelectedTrack.isSub and Config.Colors.SubTrackLabelBackground or Config.Colors.TrackListBackground
		end
		trackLabelHolder.BackgroundColor3 = Config.Colors.TrackSelected
		state.currentlySelectedTrack = {object = object, property = propName or "CFrame", label = trackLabelHolder, isSub = isSubTrack}
		print("Track dipilih:", state.currentlySelectedTrack.property)
	end)

	if isSubTrack then
		state.animationData[objectUID].subTrackFrames[propName] = {label = trackLabelHolder, keyframes = keyframeTrack}
		local mainTrackOrder = state.animationData[objectUID].trackFrame.LayoutOrder
		trackLabelHolder.LayoutOrder = mainTrackOrder + #state.animationData[objectUID].subTrackFrames
		keyframeTrack.LayoutOrder = trackLabelHolder.LayoutOrder
	else
		state.animationData[objectUID].trackFrame = trackLabelHolder
		state.animationData[objectUID].keyframeContainer = keyframeTrack
		trackLabelHolder.LayoutOrder = (#ui.trackListFrame:GetChildren() - 1) * 10
		keyframeTrack.LayoutOrder = trackLabelHolder.LayoutOrder
	end

	return trackLabelHolder, keyframeTrack
end

-- Hanya menambahkan data keyframe ke tabel animationData
function addKeyframeData(object, mainPropName, frame, value, easing, componentName)
	local objectUID = object:GetAttribute("SuperiorAnimator_UID")
	if not objectUID then return nil, nil end

	local objectData = state.animationData[objectUID]
	if not objectData then return nil, nil end

	local propData = objectData.Properties[mainPropName]
	if not propData then return nil, nil end

	local targetTrack
	if componentName then
		if not propData.Components[componentName] then
			propData.Components[componentName] = { keyframes = {}, markers = {} }
		end
		targetTrack = propData.Components[componentName]
		if not targetTrack.markers then
			targetTrack.markers = {}
		end
	else
		targetTrack = propData
	end

	targetTrack.keyframes[frame] = {
		Value = value,
		Easing = easing
	}
	return targetTrack, propData
end

function createKeyframeMarkerUI(object, mainPropName, frame, componentName)
	local objectUID = object:GetAttribute("SuperiorAnimator_UID")
	if not objectUID then return nil end

	local objectData = state.animationData[objectUID]
	if not objectData then return nil end

	local propData = objectData.Properties[mainPropName]
	if not propData then return nil end

	local targetTrack, container
	if componentName then
		targetTrack = propData.Components[componentName]
		container = propData.ComponentTracks[componentName].keyframes
	else
		targetTrack = propData
		container = (mainPropName == "CFrame") and objectData.keyframeContainer or objectData.subTrackFrames[mainPropName].keyframes
	end

	if not container then
		return nil
	end

	local keyframeData = targetTrack and targetTrack.keyframes[frame]
	if not keyframeData then return nil end

	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
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
			local isClickedInSelection = false
			for _, selected in ipairs(state.currentSelection.data) do
				if selected.marker == keyframeMarker then
					isClickedInSelection = true
					break
				end
			end
			if not isClickedInSelection then
				handleKeyframeSelection(kfInfo)
			end

			local selectionCopy = {}
			for _, selInfo in ipairs(state.currentSelection.data) do
				table.insert(selectionCopy, {
					object = selInfo.object,
					originalFrame = selInfo.frame,
					property = selInfo.property,
					component = selInfo.component,
					marker = selInfo.marker,
				})
			end

			state.draggingKeyframeInfo = { 
				selection = selectionCopy,
				originalFrame = frame
			}
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			local keyframeTarget = { object = object, frame = frame, property = mainPropName, component = componentName, marker = keyframeMarker }
			local options = {
				{ Text = "Hapus Keyframe", Callback = function(target)
					local objectUID = target.object:GetAttribute("SuperiorAnimator_UID")
					if not objectUID then return end
					local propData = state.animationData[objectUID].Properties[target.property]
					local targetTrack = target.component and propData.Components[target.component] or propData
					targetTrack.keyframes[target.frame] = nil
					targetTrack.markers[target.frame] = nil
					target.marker:Destroy()
					for i, kfInfo in ipairs(state.currentSelection.data) do
						if kfInfo.marker == target.marker then
							table.remove(state.currentSelection.data, i)
							break
						end
					end
					updatePropertyDisplay(nil)
					updateTimelineRuler()
				end },
			}
			openContextMenu(keyframeTarget, options)
		end
	end)

	return keyframeMarker
end


function updateTimelineRuler()
	local maxFrame = 100
	for _, objectData in pairs(state.animationData) do
		if not objectData.Properties then continue end
		for _, propTrack in pairs(objectData.Properties) do
			for frame, _ in pairs(propTrack.keyframes) do
				if frame > maxFrame then
					maxFrame = frame
				end
			end
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

	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
	local newWidth = (maxFrame + Config.FRAMES_PER_INTERVAL * 2) * pixelsPerFrame

	local currentCanvasSize = ui.keyframeAreaFrame.CanvasSize
	ui.keyframeAreaFrame.CanvasSize = UDim2.new(0, newWidth, 0, currentCanvasSize.Y.Offset)

	if ui.playbackRange.endHandle.Position.X.Offset < newWidth then
		ui.playbackRange.endHandle.Position = UDim2.new(0, newWidth, 0, 0)
	end
	if ui.playbackRange.startHandle.Position.X.Offset > newWidth then
		ui.playbackRange.startHandle.Position = UDim2.new(0, newWidth, 0, 0)
	end

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
	local currentCanvasSize = ui.keyframeAreaFrame.CanvasSize
	ui.keyframeAreaFrame.CanvasSize = UDim2.new(0, currentCanvasSize.X.Offset, 0, totalHeight)
end

function updatePropertyDisplay(keyframeData, propName, eventData)
	local isKeyframeSelected = (keyframeData ~= nil) or (eventData ~= nil)

	ui.placeholderLabel.Visible = not isKeyframeSelected
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
	else
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
		ui.deleteKeyframeButton.Visible = true
	elseif keyframeData then
		ui.easingButton.Text = "Easing: " .. keyframeData.Easing
	end
end

function updateScrubberFromTimeline()
	-- 1. Dapatkan rumus pixel per frame yang benar (termasuk zoom)
	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel

	-- 2. Hitung posisi pixel (Offset) berdasarkan frame saat ini
	local newPixelPosition = timeline.currentFrame * pixelsPerFrame

	-- 3. Atur posisi playhead menggunakan Offset (argumen ke-2), bukan Scale (argumen ke-1)
	ui.playhead.Position = UDim2.new(0, newPixelPosition, 0, 0)
end

function onHeartbeat(deltaTime)
	timeline:update(deltaTime * state.playbackSpeed)
	updateScrubberFromTimeline()

	-- Handle camera animation
	local cameraUID = "SuperiorAnimator_Camera"
	if state.animationData[cameraUID] and timeline.isPlaying then
		local camera = workspace.CurrentCamera
		if not state.originalCameraType then
			state.originalCameraType = camera.CameraType
		end
		camera.CameraType = Enum.CameraType.Scriptable

		local animatedCFrame = timeline:getValueAtFrame("SuperiorAnimator_Camera", "CFrame", timeline.currentFrame)
		if animatedCFrame then
			camera.CFrame = animatedCFrame
		end
	end
end

function updateSelectedObjectLabel()
	local selectedObjects = selection:Get()
	if #selectedObjects > 0 then
		if selectedObjects[1] ~= state.currentlySelectedObject then
			state.currentlySelectedObject = selectedObjects[1]
			ui.selectedObjectLabel.Text = "Terpilih: " .. state.currentlySelectedObject.Name
		end
	else
		state.currentlySelectedObject = nil
		ui.selectedObjectLabel.Text = "Tidak ada objek yang dipilih"
	end
end

local function redrawTimeline()
	for _, child in ipairs(ui.timelineRuler:GetChildren()) do
		if child.Name:find("RulerMarker") then
			child:Destroy()
		end
	end

	local pixelsPerInterval = Config.PIXELS_PER_FRAME_INTERVAL * state.zoomLevel
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

	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
	for _, objectData in pairs(state.animationData) do
		if not objectData.Properties then continue end
		for _, propData in pairs(objectData.Properties) do
			local function reposition(track)
				if not track or not track.markers then return end
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

	updateTimelineRuler()
end


-- === EVENT CONNECTIONS & INITIALIZATION ===

ui.zoomInButton.MouseButton1Click:Connect(function()
	state.zoomLevel = math.clamp(state.zoomLevel * 1.5, 0.2, 5)
	redrawTimeline()
end)

ui.zoomOutButton.MouseButton1Click:Connect(function()
	state.zoomLevel = math.clamp(state.zoomLevel / 1.5, 0.2, 5)
	redrawTimeline()
end)

ui.saveButton.MouseButton1Click:Connect(function()
	ui.saveDialog.gui.Enabled = true
end)

ui.saveDialog.cancelButton.MouseButton1Click:Connect(function()
	ui.saveDialog.gui.Enabled = false
end)

local Serialization = require(script.src.Serialization)

ui.saveDialog.confirmButton.MouseButton1Click:Connect(function()
	local animName = ui.saveDialog.nameBox.Text
	-- Loloskan HttpService ke fungsi save
	if Serialization.save(state.animationData, animName, HttpService) then
		ui.saveDialog.gui.Enabled = false
		showNotification("Sukses", "Animasi '" .. animName .. "' berhasil disimpan!")
	end
end)

ui.notificationDialog.okButton.MouseButton1Click:Connect(function()
	ui.notificationDialog.gui.Enabled = false
end)

ui.loadButton.MouseButton1Click:Connect(function()
	for _, child in ipairs(ui.loadDialog.list:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end

	local savesFolder = ReplicatedStorage:FindFirstChild("SuperiorAnimator_Saves")
	if not savesFolder then return end

	for _, animSave in ipairs(savesFolder:GetChildren()) do
		-- Ubah untuk mencari StringValue
		if animSave:IsA("StringValue") then
			local itemFrame = Instance.new("Frame")
			itemFrame.Name = animSave.Name .. "_Item"
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
			animButton.Name = animSave.Name
			animButton.Text = animSave.Name
			animButton.Size = UDim2.new(1, -30, 1, 0)
			animButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
			animButton.TextColor3 = Color3.fromRGB(220,220,220)
			animButton.Font = Enum.Font.SourceSans
			animButton.TextXAlignment = Enum.TextXAlignment.Left
			animButton.Parent = itemFrame

			deleteButton.MouseButton1Click:Connect(function()
				showConfirmation(
					"Hapus Animasi",
					"Apakah Anda yakin ingin menghapus animasi '" .. animSave.Name .. "' secara permanen?",
					function()
						animSave:Destroy()
						itemFrame:Destroy()
						print("Animasi '" .. animSave.Name .. "' telah dihapus.")
					end
				)
			end)

			animButton.MouseButton1Click:Connect(function()
				local function doLoad()
					clearTimeline()

					local success, decodedData = pcall(HttpService.JSONDecode, HttpService, animSave.Value)
					if not success then
						warn("Gagal mendekode data animasi:", decodedData)
						showNotification("Error", "Gagal memuat file animasi. Lihat konsol output untuk detailnya.")
						return
					end

					local missingObjectsInfo = {}

					-- 1. Buat peta semua objek yang dapat dianimasikan di workspace
					local uidToObjectMap = {}
					for _, descendant in ipairs(workspace:GetDescendants()) do
						local uid = descendant:GetAttribute("SuperiorAnimator_UID")
						if uid then
							uidToObjectMap[uid] = descendant
						end
					end

					-- 2. Iterasi melalui data yang dimuat dan tautkan kembali
					for uid, data in pairs(decodedData.Objects) do
						local object
						if uid == "SuperiorAnimator_Camera" then
							object = workspace.CurrentCamera
						else
							object = uidToObjectMap[uid]
						end

						if object then
							-- Objek ditemukan, buat kembali tracknya
							createTrackForObject(object, false, nil, uid)

							-- Buat ulang semua sub-track properti terlebih dahulu
							for propName, propTrackData in pairs(data.Properties) do
								if propName ~= "CFrame" then
									state.animationData[uid].Properties[propName] = {
										keyframes = {}, markers = {},
										Components = {}, ComponentTracks = {}, IsExpanded = false,
										ValueType = propTrackData.ValueType or typeof(object[propName]) -- Fallback
									}
									createTrackForObject(object, true, propName)
								end
							end

							-- Sekarang, isi keyframe-nya
							for propName, propTrackData in pairs(data.Properties) do
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
											createKeyframeMarkerUI(object, propName, frame, nil)
										end
									end
								end

								if propTrackData.Components then
									for compName, compTrackData in pairs(propTrackData.Components) do
										for frameStr, keyframeData in pairs(compTrackData.Keyframes) do
											local frame = tonumber(frameStr)
											local value = keyframeData.Value.val
											addKeyframeData(object, propName, frame, value, keyframeData.Easing, compName)
											createKeyframeMarkerUI(object, propName, frame, compName)
										end
									end
								end
							end
						else
							-- Objek tidak ditemukan
							table.insert(missingObjectsInfo, "- " .. (data.Name or "Tanpa Nama") .. " (UID: " .. uid .. ")")
						end
					end

					updateCanvasSize()
					updateTimelineRuler()
					ui.loadDialog.gui.Enabled = false

					if #missingObjectsInfo > 0 then
						local message = "Gagal memuat trek untuk objek berikut karena tidak dapat ditemukan di workspace:\n\n" .. table.concat(missingObjectsInfo, "\n")
						showNotification("Peringatan Pemuatan", message)
					end
				end

				if next(state.animationData) then
					showConfirmation(
						"Konfirmasi Muat",
						"Memuat animasi baru akan menghapus pekerjaan Anda yang belum disimpan. Apakah Anda yakin ingin melanjutkan?",
						doLoad
					)
				else
					doLoad()
				end
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
	if Serialization.export(state.animationData, animName, Config.FRAMES_PER_SECOND) then
		ui.exportDialog.gui.Enabled = false
		showNotification("Sukses", "Animasi '" .. animName .. "' berhasil diekspor!")
	end
end)

ui.confirmDialog.cancelButton.MouseButton1Click:Connect(function()
	state.confirmAction = nil
	ui.confirmDialog.gui.Enabled = false
end)

ui.confirmDialog.yesButton.MouseButton1Click:Connect(function()
	if state.confirmAction then
		state.confirmAction()
	end
	state.confirmAction = nil
	ui.confirmDialog.gui.Enabled = false
end)

ui.loopButton.MouseButton1Click:Connect(function()
	state.isLoopingEnabled = not state.isLoopingEnabled
	if state.isLoopingEnabled then
		ui.loopButton.BackgroundColor3 = Config.Colors.ButtonPrimary
	else
		ui.loopButton.BackgroundColor3 = Config.Colors.ButtonSecondary
	end
end)

ui.autoKeyButton.MouseButton1Click:Connect(function()
	state.isAutoKeyingEnabled = not state.isAutoKeyingEnabled
	if state.isAutoKeyingEnabled then
		ui.autoKeyButton.BackgroundColor3 = Config.Colors.ButtonPrimary
		ui.autoKeyButton.Text = "Auto: On"
		for _, data in pairs(state.animationData) do
			connectAutoKeyListener(data.object)
		end
	else
		ui.autoKeyButton.BackgroundColor3 = Config.Colors.ButtonSecondary
		ui.autoKeyButton.Text = "Auto"
		for object, _ in pairs(state.autoKeyConnections) do
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
		state.draggingPlaybackHandle = "Start"
	end
end)

ui.playbackRange.endHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		state.draggingPlaybackHandle = "End"
	end
end)

ui.timelineRuler.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if state.draggingKeyframeInfo or state.draggingPlaybackHandle then return end

		state.isDraggingPlayhead = true
		local mouseX = input.Position.X - ui.timelineRuler.AbsolutePosition.X
		local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
		local frame = mouseX / pixelsPerFrame

		timeline:setCurrentFrame(frame)
		updateScrubberFromTimeline()
	end
end)

ui.keyframeAreaFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if state.draggingKeyframeInfo or state.draggingPlaybackHandle or state.isDraggingPlayhead then return end

		state.isMarqueeSelecting = true
		state.marqueeStartPoint = Vector2.new(input.Position.X, input.Position.Y)

		for _, selectedInfo in ipairs(state.currentSelection.data) do
			if selectedInfo.marker and selectedInfo.marker.Parent then
				local objectUID = selectedInfo.object:GetAttribute("SuperiorAnimator_UID")
				if not (objectUID and state.animationData[objectUID]) then continue end
				local prevPropData = state.animationData[objectUID].Properties[selectedInfo.property]
				if prevPropData then
					local prevKeyframeData = (selectedInfo.component and prevPropData.Components[selectedInfo.component] or prevPropData).keyframes[selectedInfo.frame]
					if prevKeyframeData then
						selectedInfo.marker.BackgroundColor3 = if prevKeyframeData.Easing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
					end
				end
			end
		end
		state.currentSelection = { type = nil, data = {} }
		updatePropertyDisplay(nil)

		local relativePos = state.marqueeStartPoint - ui.keyframeAreaFrame.AbsolutePosition
		ui.marqueeSelectionBox.Position = UDim2.new(0, relativePos.X + ui.keyframeAreaFrame.CanvasPosition.X, 0, relativePos.Y + ui.keyframeAreaFrame.CanvasPosition.Y)
		ui.marqueeSelectionBox.Size = UDim2.new(0, 0, 0, 0)
		ui.marqueeSelectionBox.Visible = true
	end
end)


inputService.InputChanged:Connect(function(input)
	if state.isDraggingPlayhead and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local mouseX = input.Position.X - ui.keyframeAreaFrame.AbsolutePosition.X + ui.keyframeAreaFrame.CanvasPosition.X
		mouseX = math.clamp(mouseX, 0, ui.keyframeAreaFrame.CanvasSize.X.Offset)
		local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
		local frame = mouseX / pixelsPerFrame
		timeline:setCurrentFrame(frame)
		updateScrubberFromTimeline()
	elseif state.isMarqueeSelecting and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local currentPos = input.Position
		local startPos = state.marqueeStartPoint

		local topLeft = Vector2.new(math.min(startPos.X, currentPos.X), math.min(startPos.Y, currentPos.Y))
		local bottomRight = Vector2.new(math.max(startPos.X, currentPos.X), math.max(startPos.Y, currentPos.Y))

		local relativePos = topLeft - ui.keyframeAreaFrame.AbsolutePosition
		local size = bottomRight - topLeft

		ui.marqueeSelectionBox.Position = UDim2.new(0, relativePos.X + ui.keyframeAreaFrame.CanvasPosition.X, 0, relativePos.Y + ui.keyframeAreaFrame.CanvasPosition.Y)
		ui.marqueeSelectionBox.Size = UDim2.new(0, size.X, 0, size.Y)

		local selectionRect = Rect.new(topLeft, bottomRight)

		local function checkIntersection(kfInfo, marker)
			local markerRect = Rect.new(marker.AbsolutePosition, marker.AbsoluteSize)
			local intersects = not (selectionRect.Min.X > markerRect.Max.X or selectionRect.Max.X < markerRect.Min.X or selectionRect.Min.Y > markerRect.Max.Y or selectionRect.Max.Y < markerRect.Min.Y)

			local alreadySelected = false
			for _, selInfo in ipairs(state.currentSelection.data) do
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

		for _, objData in pairs(state.animationData) do
			local obj = objData.object
			if obj then
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
		end

	elseif state.draggingKeyframeInfo and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local mouseX = input.Position.X - ui.keyframeAreaFrame.AbsolutePosition.X + ui.keyframeAreaFrame.CanvasPosition.X
		mouseX = math.clamp(mouseX, 0, ui.timelineRuler.AbsoluteSize.X)

		local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
		local originalPixelX = state.draggingKeyframeInfo.originalFrame * pixelsPerFrame
		local deltaX = mouseX - originalPixelX

		for _, kfInfo in ipairs(state.draggingKeyframeInfo.selection) do
			local kfOriginalX = kfInfo.originalFrame * pixelsPerFrame
			local newKfX = math.clamp(kfOriginalX + deltaX, 0, ui.timelineRuler.AbsoluteSize.X)
			kfInfo.marker.Position = UDim2.new(0, newKfX, 0, kfInfo.marker.Position.Y.Offset)
		end

	elseif state.draggingPlaybackHandle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local mouseX = input.Position.X - ui.timelineRuler.AbsolutePosition.X
		mouseX = math.clamp(mouseX, 0, ui.timelineRuler.AbsoluteSize.X)

		local startHandle = ui.playbackRange.startHandle
		local endHandle = ui.playbackRange.endHandle

		if state.draggingPlaybackHandle == "Start" then
			startHandle.Position = UDim2.new(0, math.min(mouseX, endHandle.Position.X.Offset), 0, 0)
		elseif state.draggingPlaybackHandle == "End" then
			endHandle.Position = UDim2.new(0, math.max(mouseX, startHandle.Position.X.Offset), 0, 0)
		end

		local startX = startHandle.Position.X.Offset
		local endX = endHandle.Position.X.Offset
		ui.playbackRange.frame.Position = UDim2.new(0, startX, 0, 0)
		ui.playbackRange.frame.Size = UDim2.new(0, endX - startX, 1, 0)
	end
end)

inputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if state.isMarqueeSelecting then
			state.isMarqueeSelecting = false
			ui.marqueeSelectionBox.Visible = false
		end
		state.isDraggingPlayhead = false
		state.draggingPlaybackHandle = nil
		if state.draggingKeyframeInfo then
			local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel

			local updates = {}

			for _, kfDragInfo in ipairs(state.draggingKeyframeInfo.selection) do
				local newFrame = math.floor(kfDragInfo.marker.Position.X.Offset / pixelsPerFrame)
				local objectUID = kfDragInfo.object:GetAttribute("SuperiorAnimator_UID")

				if newFrame ~= kfDragInfo.originalFrame and objectUID and state.animationData[objectUID] then
					local propData = state.animationData[objectUID].Properties[kfDragInfo.property]
					if propData then
						local targetTrack = kfDragInfo.component and propData.Components[kfDragInfo.component] or propData
						if targetTrack and targetTrack.keyframes[kfDragInfo.originalFrame] then
							table.insert(updates, {
								info = kfDragInfo,
								newFrame = newFrame,
								keyframeData = targetTrack.keyframes[kfDragInfo.originalFrame]
							})
						end
					end
				else
					kfDragInfo.marker.Position = UDim2.new(0, kfDragInfo.originalFrame * pixelsPerFrame, 0, kfDragInfo.marker.Position.Y.Offset)
				end
			end

			if #updates == 0 then
				state.draggingKeyframeInfo = nil
				return
			end

			local action = {
				redo = function()
					local newSelectionData = {}

					for _, update in ipairs(updates) do
						local kfInfo = update.info
						local objectUID = kfInfo.object:GetAttribute("SuperiorAnimator_UID")
						if objectUID and state.animationData[objectUID] then
							local propData = state.animationData[objectUID].Properties[kfInfo.property]
							if propData then
								local targetTrack = kfInfo.component and propData.Components[kfInfo.component] or propData
								if targetTrack then
									targetTrack.keyframes[kfInfo.originalFrame] = nil
									targetTrack.markers[kfInfo.originalFrame] = nil
								end
							end
						end
					end

					for _, update in ipairs(updates) do
						local kfInfo = update.info
						local newFrame = update.newFrame
						local objectUID = kfInfo.object:GetAttribute("SuperiorAnimator_UID")

						if objectUID and state.animationData[objectUID] then
							local propData = state.animationData[objectUID].Properties[kfInfo.property]
							if propData then
								local targetTrack = kfInfo.component and propData.Components[kfInfo.component] or propData
								if targetTrack then
									targetTrack.keyframes[newFrame] = update.keyframeData
									targetTrack.markers[newFrame] = kfInfo.marker
									kfInfo.marker.Position = UDim2.new(0, newFrame * pixelsPerFrame, 0, kfInfo.marker.Position.Y.Offset)

									local newKfInfo = {
										object = kfInfo.object, frame = newFrame, property = kfInfo.property,
										component = kfInfo.component, marker = kfInfo.marker
									}
									table.insert(newSelectionData, newKfInfo)
								end
							end
						end
					end
					state.currentSelection.data = newSelectionData
					updateTimelineRuler()
				end,
				undo = function()
					local oldSelectionData = {}
					for _, update in ipairs(updates) do
						local kfInfo = update.info
						local newFrame = update.newFrame
						local objectUID = kfInfo.object:GetAttribute("SuperiorAnimator_UID")
						if objectUID and state.animationData[objectUID] then
							local propData = state.animationData[objectUID].Properties[kfInfo.property]
							if propData then
								local targetTrack = kfInfo.component and propData.Components[kfInfo.component] or propData
								if targetTrack then
									targetTrack.keyframes[newFrame] = nil
									targetTrack.markers[newFrame] = nil
								end
							end
						end
					end

					for _, update in ipairs(updates) do
						local kfInfo = update.info
						local originalFrame = kfInfo.originalFrame
						local objectUID = kfInfo.object:GetAttribute("SuperiorAnimator_UID")

						if objectUID and state.animationData[objectUID] then
							local propData = state.animationData[objectUID].Properties[kfInfo.property]
							if propData then
								local targetTrack = kfInfo.component and propData.Components[kfInfo.component] or propData
								if targetTrack then
									targetTrack.keyframes[originalFrame] = update.keyframeData
									targetTrack.markers[originalFrame] = kfInfo.marker
									kfInfo.marker.Position = UDim2.new(0, originalFrame * pixelsPerFrame, 0, kfInfo.marker.Position.Y.Offset)

									local oldKfInfo = {
										object = kfInfo.object, frame = originalFrame, property = kfInfo.property,
										component = kfInfo.component, marker = kfInfo.marker
									}
									table.insert(oldSelectionData, oldKfInfo)
								end
							end
						end
					end
					state.currentSelection.data = oldSelectionData
					updateTimelineRuler()
				end
			}
			ActionHistory:register(action)
			action.redo()

			state.draggingKeyframeInfo = nil
		end
	end
end)

ui.addObjectButton.MouseButton1Click:Connect(function()
	local selectedObjects = selection:Get()
	if #selectedObjects == 0 then
		showNotification("Peringatan", "Silakan pilih objek di workspace terlebih dahulu.")
		return
	end

	local objectToAdd = selectedObjects[1]

	-- Periksa apakah objek sudah ada dalam data animasi
	for _, data in pairs(state.animationData) do
		if data.object == objectToAdd then
			showNotification("Info", "Objek '" .. objectToAdd.Name .. "' sudah ada di timeline.")
			return
		end
	end

	local objectUID = objectToAdd:GetAttribute("SuperiorAnimator_UID")
	if not objectUID then
		objectUID = HttpService:GenerateGUID(false)
		objectToAdd:SetAttribute("SuperiorAnimator_UID", objectUID)
	end

	-- Gunakan UID sebagai kunci utama untuk mencegah duplikasi
	if state.animationData[objectUID] then return end

	local action = {
		redo = function()
			-- Loloskan UID ke fungsi createTrack
			createTrackForObject(objectToAdd, false, nil, objectUID)
			updateCanvasSize()
			updateSelectedObjectLabel()
		end,
		undo = function()
			deleteTrack(objectToAdd, nil)
		end
	}
	ActionHistory:register(action)
	action.redo()
end)

local function addKeyframeAction(selectedObject, fullPropName, currentFrame)
	local mainPropName, componentName = fullPropName:match("([^.]+)%.([^.]+)")
	mainPropName = mainPropName or fullPropName

	local objectUID
	if selectedObject:IsA("Camera") then
		objectUID = "SuperiorAnimator_Camera"
	else
		objectUID = selectedObject:GetAttribute("SuperiorAnimator_UID")
	end

	if not (objectUID and state.animationData[objectUID]) then return end

	local propData = state.animationData[objectUID].Properties[mainPropName]
	if not propData then return end

	-- We need this for the undo function, so we define it here
	local expandableTypes = {Vector3 = {"X", "Y", "Z"}, Color3 = {"R", "G", "B"}, UDim2 = {"XScale", "XOffset", "YScale", "YOffset"}}

	local action = {
		info = "Add Keyframe(s)",
		redo = function()
			if componentName then
				if not propData.Components[componentName] then
					propData.Components[componentName] = { keyframes = {}, markers = {} }
				end
				local compTrack = propData.Components[componentName]
				if compTrack.keyframes[currentFrame] then return end

				local currentValue = selectedObject[mainPropName]
				local componentValue
				if propData.ValueType == "UDim2" then
					local udimComp = componentName:match("([XY])(Scale|Offset)")
					componentValue = currentValue[udimComp:sub(1,1)][udimComp:sub(2)]
				else
					componentValue = currentValue[componentName]
				end

				addKeyframeData(selectedObject, mainPropName, currentFrame, componentValue, "Linear", componentName)
				createKeyframeMarkerUI(selectedObject, mainPropName, currentFrame, componentName)
			elseif propData.IsExpanded then
				local components = expandableTypes[propData.ValueType]
				local currentValue = selectedObject[mainPropName]

				for _, compName in ipairs(components) do
					if not propData.Components[compName] then
						propData.Components[compName] = { keyframes = {}, markers = {} }
					end
					local compTrack = propData.Components[compName]
					if compTrack.keyframes and compTrack.keyframes[currentFrame] then continue end

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
			else
				if propData.keyframes[currentFrame] then return end
				addKeyframeData(selectedObject, mainPropName, currentFrame, selectedObject[mainPropName], "Linear", nil)
				createKeyframeMarkerUI(selectedObject, mainPropName, currentFrame, nil)
			end
			updateTimelineRuler()
		end,
		undo = function()
			local objectUID = selectedObject:GetAttribute("SuperiorAnimator_UID")
			if not objectUID then return end

			local function removeKeyframe(uid, prop, frame, comp)
				local pData = state.animationData[uid].Properties[prop]
				if not pData then return end
				local track = comp and pData.Components[comp] or pData
				if track and track.markers and track.markers[frame] then
					track.markers[frame]:Destroy()
					track.markers[frame] = nil
					track.keyframes[frame] = nil
				end
			end

			if componentName then
				removeKeyframe(objectUID, mainPropName, currentFrame, componentName)
			elseif propData.IsExpanded then
				local components = expandableTypes[propData.ValueType]
				for _, compName in ipairs(components) do
					removeKeyframe(objectUID, mainPropName, currentFrame, compName)
				end
			else
				removeKeyframe(objectUID, mainPropName, currentFrame, nil)
			end
			updateTimelineRuler()
		end
	}
	ActionHistory:register(action)
	action.redo()
end

ui.addCameraButton.MouseButton1Click:Connect(function()
	local cameraUID = "SuperiorAnimator_Camera"

	if state.animationData[cameraUID] then
		showNotification("Info", "Track kamera sudah ada di timeline.")
		return
	end

	local camera = workspace.CurrentCamera
	-- Kita tidak bisa menyetel atribut pada kamera, jadi kita akan menanganinya secara khusus

	local action = {
		redo = function()
			createTrackForObject(camera, false, nil, cameraUID)
			updateCanvasSize()
		end,
		undo = function()
			deleteTrack(camera, nil) -- Ini mungkin perlu penyesuaian
		end
	}
	ActionHistory:register(action)
	action.redo()
end)

ui.addKeyframeButton.MouseButton1Click:Connect(function()
	if not state.currentlySelectedTrack.object or not state.currentlySelectedTrack.property then
		print("Pilih sebuah track properti terlebih dahulu.")
		return
	end

	local selectedObject = state.currentlySelectedTrack.object
	local fullPropName = state.currentlySelectedTrack.property

	local playheadX = ui.playhead.Position.X.Offset
	local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
	local currentFrame = math.floor(playheadX / pixelsPerFrame)

	addKeyframeAction(selectedObject, fullPropName, currentFrame)
end)

selection.SelectionChanged:Connect(updateSelectedObjectLabel)

ui.playButton.MouseButton1Click:Connect(function()
	if not timeline.isPlaying then
		local startFrame = (ui.playbackRange.startHandle.Position.X.Offset / ((Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel))
		local endFrame = (ui.playbackRange.endHandle.Position.X.Offset / ((Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel))

		if timeline.currentFrame >= endFrame then
			timeline:setCurrentFrame(startFrame)
		end

		timeline:play()

		if not state.playbackConnection then
			state.playbackConnection = RunService.Heartbeat:Connect(onHeartbeat)
		end
	else
		timeline:pause()
	end
end)

ui.stopButton.MouseButton1Click:Connect(function()
	timeline:stop()
	updateScrubberFromTimeline()
	if state.originalCameraType then
		workspace.CurrentCamera.CameraType = state.originalCameraType
		state.originalCameraType = nil
	end
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
				totalHeight = totalHeight + 26
				visibleCount = visibleCount + 1
			end
		end
	end
	local listHeight = math.min(totalHeight, 250 - 32)
	ui.propMenu.frame.Size = UDim2.new(0, 180, 0, listHeight + 32)
	ui.propMenu.list.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end)

for _, category in ipairs(easingStyles) do
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
		itemButton.Text = "    " .. styleName
		itemButton.Size = UDim2.new(1, 0, 0, 24)
		itemButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
		itemButton.TextColor3 = Color3.fromRGB(220,220,220)
		itemButton.Font = Enum.Font.SourceSans
		itemButton.TextSize = 14
		itemButton.TextXAlignment = Enum.TextXAlignment.Left
		itemButton.Parent = ui.easingMenu

		itemButton.MouseButton1Click:Connect(function()
			if state.currentSelection.type ~= "Keyframe" or #state.currentSelection.data ~= 1 then return end
			local kfInfo = state.currentSelection.data[1]
			local objectUID = kfInfo.object:GetAttribute("SuperiorAnimator_UID")
			if not objectUID then return end

			local propTrack = state.animationData[objectUID].Properties[kfInfo.property]
			if not (propTrack and propTrack.keyframes[kfInfo.frame]) then return end

			local keyframe = propTrack.keyframes[kfInfo.frame]
			local oldEasing = keyframe.Easing
			local newEasing = styleName

			if oldEasing == newEasing then return end

			local action = {
				redo = function()
					local kf = state.animationData[objectUID].Properties[kfInfo.property].keyframes[kfInfo.frame]
					kf.Easing = newEasing
					ui.easingButton.Text = "Easing: " .. newEasing
					if kfInfo.marker then
						kfInfo.marker.BackgroundColor3 = if newEasing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
					end
					ui.easingMenu.Visible = false
				end,
				undo = function()
					local kf = state.animationData[objectUID].Properties[kfInfo.property].keyframes[kfInfo.frame]
					kf.Easing = oldEasing
					ui.easingButton.Text = "Easing: " .. oldEasing
					if kfInfo.marker then
						kfInfo.marker.BackgroundColor3 = if oldEasing == "Linear" then Config.Colors.KeyframeLinear else Config.Colors.KeyframeEased
					end
				end
			}
			ActionHistory:register(action)
			action.redo()
		end)
	end
end

local function deleteSelectedKeyframes()
	if state.currentSelection.type ~= "Keyframe" and state.currentSelection.type ~= "Event" or #state.currentSelection.data == 0 then
		return
	end

	local deletedData = {}
	for _, selInfo in ipairs(state.currentSelection.data) do
		if selInfo.marker and selInfo.object then
			local objectUID = selInfo.object:GetAttribute("SuperiorAnimator_UID")
			if not objectUID or not state.animationData[objectUID] then continue end

			if state.currentSelection.type == "Keyframe" then
				local propTrack = state.animationData[objectUID].Properties[selInfo.property]
				if propTrack then
					local targetTrack = selInfo.component and propTrack.Components[selInfo.component] or propTrack
					if targetTrack and targetTrack.keyframes[selInfo.frame] then
						table.insert(deletedData, {
							type = "Keyframe",
							object = selInfo.object,
							uid = objectUID,
							property = selInfo.property,
							component = selInfo.component,
							frame = selInfo.frame,
							data = targetTrack.keyframes[selInfo.frame]
						})
					end
				end
			elseif state.currentSelection.type == "Event" then
				local eventTrack = state.animationData[objectUID].Events
				if eventTrack and eventTrack.keyframes[selInfo.frame] then
					table.insert(deletedData, {
						type = "Event",
						object = selInfo.object,
						uid = objectUID,
						frame = selInfo.frame,
						data = eventTrack.keyframes[selInfo.frame]
					})
				end
			end
		end
	end

	if #deletedData == 0 then return end

	local action = {
		redo = function()
			for _, deletedInfo in ipairs(deletedData) do
				if deletedInfo.type == "Keyframe" then
					local propTrack = state.animationData[deletedInfo.uid].Properties[deletedInfo.property]
					local targetTrack = deletedInfo.component and propTrack.Components[deletedInfo.component] or propTrack
					if targetTrack and targetTrack.markers[deletedInfo.frame] then
						targetTrack.markers[deletedInfo.frame]:Destroy()
						targetTrack.markers[deletedInfo.frame] = nil
						targetTrack.keyframes[deletedInfo.frame] = nil
					end
				elseif deletedInfo.type == "Event" then
					local eventTrack = state.animationData[deletedInfo.uid].Events
					if eventTrack and eventTrack.markers[deletedInfo.frame] then
						eventTrack.markers[deletedInfo.frame]:Destroy()
						eventTrack.markers[deletedInfo.frame] = nil
						eventTrack.keyframes[deletedInfo.frame] = nil
					end
				end
			end
			state.currentSelection = { type = nil, data = {} }
			updatePropertyDisplay(nil)
			updateTimelineRuler()
		end,
		undo = function()
			for _, deletedInfo in ipairs(deletedData) do
				if deletedInfo.type == "Keyframe" then
					addKeyframeData(deletedInfo.object, deletedInfo.property, deletedInfo.frame, deletedInfo.data.Value, deletedInfo.data.Easing, deletedInfo.component)
					createKeyframeMarkerUI(deletedInfo.object, deletedInfo.property, deletedInfo.frame, deletedInfo.component)
				elseif deletedInfo.type == "Event" then
					createEventMarkerUI(deletedInfo.object, deletedInfo.frame, deletedInfo.data.Name)
				end
			end
			updateTimelineRuler()
		end
	}
	ActionHistory:register(action)
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
		if state.currentSelection.type == "Keyframe" and #state.currentSelection.data == 1 then
			local kfInfo = state.currentSelection.data[1]
			local objectUID = kfInfo.object:GetAttribute("SuperiorAnimator_UID")
			if not objectUID then return end
			local propData = state.animationData[objectUID].Properties[kfInfo.property]
			if not propData then return end

			local targetTrack = kfInfo.component and propData.Components[kfInfo.component] or propData
			local keyframeData = targetTrack.keyframes[kfInfo.frame]

			if keyframeData then
				state.keyframeClipboard = {
					Value = keyframeData.Value,
					Easing = keyframeData.Easing,
					ValueType = typeof(keyframeData.Value)
				}
				print("Keyframe disalin.")
			end
		end
	elseif input.KeyCode == Enum.KeyCode.K and not isCtrlDown and not isShiftDown then
		local selectedObjects = selection:Get()
		if #selectedObjects == 0 then return end

		local playheadX = ui.playhead.Position.X.Offset
		local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
		local currentFrame = math.floor(playheadX / pixelsPerFrame)

		for _, object in ipairs(selectedObjects) do
			local objectUID = object:GetAttribute("SuperiorAnimator_UID")
			local isCamera = object:IsA("Camera")
			if isCamera then
				objectUID = "SuperiorAnimator_Camera"
			end

			-- Jika objek belum ada di timeline, tambahkan
			if not (objectUID and state.animationData[objectUID]) then
				createTrackForObject(object, false, nil, nil)

				if not isCamera then
					-- Dapatkan UID yang mungkin baru dibuat oleh fungsi di atas
					local newUID = object:GetAttribute("SuperiorAnimator_UID")
					if object:IsA("BasePart") and newUID and state.animationData[newUID] and not state.animationData[newUID].Properties["Size"] then
						state.animationData[newUID].Properties["Size"] = {
							keyframes = {}, markers = {}, Components = {},
							ComponentTracks = {}, IsExpanded = false, ValueType = "Vector3"
						}
						createTrackForObject(object, true, "Size")
					end
				end
				updateCanvasSize()
			end

			-- Tambahkan keyframe untuk CFrame dan Size (jika ada)
			addKeyframeAction(object, "CFrame", currentFrame)
			if object:IsA("BasePart") and not isCamera then
				addKeyframeAction(object, "Size", currentFrame)
			end
		end

	elseif input.KeyCode == Enum.KeyCode.V and isCtrlDown then
		if not state.keyframeClipboard then return end
		if not state.currentlySelectedTrack.object or not state.currentlySelectedTrack.property then return end

		local object = state.currentlySelectedTrack.object
		local objectUID = object:GetAttribute("SuperiorAnimator_UID")
		if not objectUID then return end
		local fullPropName = state.currentlySelectedTrack.property

		local mainPropName, componentName = fullPropName:match("([^.]+)%.([^.]+)")
		mainPropName = mainPropName or fullPropName

		local propData = state.animationData[objectUID].Properties[mainPropName]
		if not propData then return end

		local isCompatible = false
		if componentName then
			if state.keyframeClipboard.ValueType == "number" then
				isCompatible = true
			end
		else
			if state.keyframeClipboard.ValueType == propData.ValueType then
				isCompatible = true
			end
		end

		if not isCompatible then
			warn("Tipe keyframe tidak kompatibel.")
			return
		end

		local playheadX = ui.playhead.Position.X.Offset
		local pixelsPerFrame = (Config.PIXELS_PER_FRAME_INTERVAL / Config.FRAMES_PER_INTERVAL) * state.zoomLevel
		local currentFrame = math.floor(playheadX / pixelsPerFrame)

		local targetTrackForDeletion = componentName and propData.Components[componentName] or propData
		if targetTrackForDeletion and targetTrackForDeletion.markers[currentFrame] then
			targetTrackForDeletion.markers[currentFrame]:Destroy()
			targetTrackForDeletion.keyframes[currentFrame] = nil
			targetTrackForDeletion.markers[currentFrame] = nil
		end

		addKeyframeData(object, mainPropName, currentFrame, state.keyframeClipboard.Value, state.keyframeClipboard.Easing, componentName)
		createKeyframeMarkerUI(object, mainPropName, currentFrame, componentName)
		updateTimelineRuler()
	end
end)

updateSelectedObjectLabel()
updateCanvasSize()

-- === KONEKSI UNDO/REDO ===
ui.undoButton.MouseButton1Click:Connect(function() ActionHistory:undo() end)
ui.redoButton.MouseButton1Click:Connect(function() ActionHistory:redo() end)

-- Panggil sekali di awal untuk mengatur keadaan awal
ActionHistory:updateButtonStates()

ui.speedDropdown.MouseButton1Click:Connect(function()
	local speeds = {0.25, 0.5, 1.0, 2.0}
	local currentIndex = table.find(speeds, state.playbackSpeed) or 3
	local nextIndex = (currentIndex % #speeds) + 1
	state.playbackSpeed = speeds[nextIndex]
	ui.speedDropdown.Text = tostring(state.playbackSpeed) .. "x"
end)

ui.propertyLabels.color3.swatch.MouseButton1Click:Connect(function()
	if state.currentSelection.type ~= "Keyframe" or #state.currentSelection.data ~= 1 then return end
	local kfInfo = state.currentSelection.data[1]
	local keyframe = state.animationData[kfInfo.object].Properties[kfInfo.property].keyframes[kfInfo.frame]
	if not keyframe or typeof(keyframe.Value) ~= "Color3" then return end

	local success, newColor = plugin:GetColor3(keyframe.Value)
	if success then
		updateKeyframeValue(newColor, nil, nil)
	end
end)

ui.propertyLabels.boolean.checkbox.MouseButton1Click:Connect(function()
	if state.currentSelection.type ~= "Keyframe" or #state.currentSelection.data ~= 1 then return end
	local kfInfo = state.currentSelection.data[1]
	local keyframe = state.animationData[kfInfo.object].Properties[kfInfo.property].keyframes[kfInfo.frame]
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
