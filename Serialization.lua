-- SuperiorAnimator/src/Serialization.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Serialization = {}

-- Helper function to convert a table to a string for saving
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

function Serialization.save(animationData, animName, httpService)
	if animName == "" or animName:match("^%s*$") then
		-- TODO: Ganti dengan UI notifikasi
		print("Superior Animator: Nama animasi tidak boleh kosong.")
		return false
	end

	local serializableData = { 
		Version = 2, -- Tandai format baru
		Objects = {} 
	}

	for uid, data in pairs(animationData) do
		if not data.object then continue end

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
			if propTrack.Components then
				for compName, compTrackData in pairs(propTrack.Components) do
					local compKeyframes = {}
					for frame, keyframeData in pairs(compTrackData.keyframes) do
						compKeyframes[tostring(frame)] = {
							Value = {vType="number", val=keyframeData.Value}, -- Komponen selalu angka
							Easing = keyframeData.Easing
						}
					end
					components[compName] = { Keyframes = compKeyframes }
				end
			end

			properties[propName] = { 
				Keyframes = keyframes, 
				Components = components, 
				ValueType = propTrack.ValueType,
				IsExpanded = propTrack.IsExpanded or false -- Simpan status expand
			}
		end

		local objectName = (uid == "SuperiorAnimator_Camera") and "Camera" or data.object.Name
		serializableData.Objects[uid] = { 
			Name = objectName, -- Simpan nama untuk referensi
			Properties = properties 
		}
	end

	local success, jsonString = pcall(httpService.JSONEncode, httpService, serializableData)
	if not success then
		-- TODO: Tampilkan notifikasi error
		warn("Gagal meng-encode data animasi ke JSON:", jsonString)
		return false
	end

	local savesFolder = ReplicatedStorage:FindFirstChild("SuperiorAnimator_Saves")
	if not savesFolder then
		savesFolder = Instance.new("Folder")
		savesFolder.Name = "SuperiorAnimator_Saves"
		savesFolder.Parent = ReplicatedStorage
	end

	-- Hapus file lama jika ada
	local existingSave = savesFolder:FindFirstChild(animName)
	if existingSave then
		existingSave:Destroy()
	end

	-- Gunakan StringValue untuk menyimpan data JSON
	local saveInstance = Instance.new("StringValue")
	saveInstance.Name = animName
	saveInstance.Value = jsonString
	saveInstance.Parent = savesFolder

	return true
end

function Serialization.export(animationData, animName, fps)
	if animName == "" or animName:match("^%s*$") then
		print("Superior Animator: Nama animasi untuk ekspor tidak boleh kosong.")
		return false
	end

	print("Mengekspor animasi sebagai '" .. animName .. "'...")

	local success, result = pcall(function()
		local animation = Instance.new("Animation")
		animation.Name = animName

		local keyframeSequence = Instance.new("KeyframeSequence")
		keyframeSequence.Parent = animation

		local function parseEasingStyleFromName(easingName)
			local name = easingName or "Linear"
			if name:find("InOut") then name = name:gsub("InOut", "")
			else name = name:gsub("In", ""):gsub("Out", "") end
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
			if easingName:find("InOut") then return Enum.EasingDirection.InOut
			elseif easingName:find("In") then return Enum.EasingDirection.In
			elseif easingName:find("Out") then return Enum.EasingDirection.Out
			else return Enum.EasingDirection.InOut end
		end

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

		for _, frame in ipairs(sortedFrames) do
			local time = frame / fps
			local keyframe = Instance.new("Keyframe")
			keyframe.Time = time

			local hasPoses = false
			for object, objectData in pairs(animationData) do
				if objectData.Properties.CFrame and objectData.Properties.CFrame.keyframes[frame] then
					local keyframeCFrameData = objectData.Properties.CFrame.keyframes[frame]
					local pose = Instance.new("Pose")
					pose.Name = object.Name
					pose.CFrame = keyframeCFrameData.Value
					local easingName = keyframeCFrameData.Easing or "Linear"
					pose.EasingStyle = parseEasingStyleFromName(easingName)
					pose.EasingDirection = parseEasingDirectionFromName(easingName)
					pose.Parent = keyframe
					hasPoses = true
				end
			end

			if hasPoses then keyframe.Parent = keyframeSequence
			else keyframe:Destroy() end
		end

		for object, objectData in pairs(animationData) do
			for propName, propTrack in pairs(objectData.Properties) do
				if propName ~= "CFrame" then
					for frame, keyframeData in pairs(propTrack.keyframes) do
						local time = frame / fps
						local valueType = typeof(keyframeData.Value)
						local propKeyframe
						if valueType == "number" then propKeyframe = Instance.new("NumberKeyframe")
						elseif valueType == "Vector3" then propKeyframe = Instance.new("Vector3Keyframe") end

						if propKeyframe then
							propKeyframe.Value = keyframeData.Value
							propKeyframe.Time = time
							propKeyframe.Name = object.Name .. "." .. propName
							local easingName = keyframeData.Easing or "Linear"
							propKeyframe.EasingStyle = parseEasingStyleFromName(easingName)
							propKeyframe.EasingDirection = parseEasingDirectionFromName(easingName)
							propKeyframe.Parent = keyframeSequence
						end
					end
				end
			end
			if objectData.Events then
				for frame, eventData in pairs(objectData.Events.keyframes) do
					local time = frame / fps
					local marker = Instance.new("KeyframeMarker")
					marker.Name = eventData.Name
					marker.Time = time
					marker.Parent = keyframeSequence
				end
			end
		end

		local exportsFolder = ReplicatedStorage:FindFirstChild("SuperiorAnimator_Exports")
		if not exportsFolder then
			exportsFolder = Instance.new("Folder")
			exportsFolder.Name = "SuperiorAnimator_Exports"
			exportsFolder.Parent = ReplicatedStorage
		end
		animation.Parent = exportsFolder
	end)

	if success then
		return true
	else
		warn("Ekspor animasi gagal:", result)
		return false
	end
end

return Serialization
