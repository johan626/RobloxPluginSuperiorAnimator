-- SuperiorAnimator/src/TimelineLogic.lua

local EasingFunctions = require(script.Parent.EasingFunctions)

local TimelineLogic = {}
TimelineLogic.__index = TimelineLogic

function TimelineLogic.new(animationData, config, state)
	local self = setmetatable({}, TimelineLogic)

	self.animationData = animationData
	self.Config = config
	self.state = state

	self.isPlaying = false
	self.currentFrame = 0
	self.connection = nil
	self.startFrame = 0
	self.endFrame = config.MAX_FRAMES

	return self
end

function TimelineLogic:play(startFrame, endFrame)
	if self.isPlaying then return end
	self.isPlaying = true
	self.startFrame = startFrame or 0
	self.endFrame = endFrame or self.Config.MAX_FRAMES
end

function TimelineLogic:pause()
	self.isPlaying = false
end

function TimelineLogic:stop()
	self.isPlaying = false
	self:setCurrentFrame(self.startFrame or 0)
end

-- Function to get the value of a property at a specific frame
function TimelineLogic:getValueAtFrame(propertyTrack, frame)
	if not propertyTrack or not propertyTrack.keyframes then
		return nil
	end

	local keyframes = propertyTrack.keyframes

	-- Find the two keyframes to interpolate between
	local prevKeyframe, nextKeyframe
	local prevFrame, nextFrame = -1, -1

	for f, k in pairs(keyframes) do
		if f <= frame and f > prevFrame then
			prevFrame = f
			prevKeyframe = k
		end
		if f >= frame and (f < nextFrame or nextFrame == -1) then
			nextFrame = f
			nextKeyframe = k
		end
	end

	if not prevKeyframe then return nil end -- No keyframes before or at the current frame
	if prevFrame == nextFrame then return prevKeyframe.Value end -- Exact keyframe match
	if not nextKeyframe then return prevKeyframe.Value end -- At or after the last keyframe

	-- Interpolation
	local alpha = (frame - prevFrame) / (nextFrame - prevFrame)
	local easingFunction = EasingFunctions.Functions[prevKeyframe.Easing or "Linear"]
	alpha = easingFunction(alpha)

	local p_val = prevKeyframe.Value
	local n_val = nextKeyframe.Value
	local valueType = typeof(p_val)

	if valueType == "number" then
		return p_val + (n_val - p_val) * alpha
	elseif valueType == "CFrame" then
		return p_val:Lerp(n_val, alpha)
	elseif valueType == "Vector3" then
		return p_val:Lerp(n_val, alpha)
	elseif valueType == "Color3" then
		return p_val:Lerp(n_val, alpha)
	elseif valueType == "UDim2" then
		-- UDim2 doesn't have a built-in Lerp
		local xs = p_val.X.Scale + (n_val.X.Scale - p_val.X.Scale) * alpha
		local xo = p_val.X.Offset + (n_val.X.Offset - p_val.X.Offset) * alpha
		local ys = p_val.Y.Scale + (n_val.Y.Scale - p_val.Y.Scale) * alpha
		local yo = p_val.Y.Offset + (n_val.Y.Offset - p_val.Y.Offset) * alpha
		return UDim2.new(xs, xo, ys, yo)
	else
		-- For types that can't be interpolated (like booleans), just snap to the previous value
		return p_val
	end
end


-- Helper to check if a track or any of its component tracks have keyframes
local function trackHasKeyframes(track)
	if track.keyframes and next(track.keyframes) then
		return true
	end
	if track.Components then
		for _, compTrack in pairs(track.Components) do
			if compTrack.keyframes and next(compTrack.keyframes) then
				return true
			end
		end
	end
	return false
end


-- Sets the current frame and updates the objects in the scene to match
function TimelineLogic:setCurrentFrame(frame, isPlaying)
	self.currentFrame = math.clamp(frame, 0, self.Config.MAX_FRAMES)

	for uid, data in pairs(self.animationData) do
		if uid == "SuperiorAnimator_Camera" then continue end

		local object = data.object
		if not object or not object.Parent then continue end

		for propName, propTrack in pairs(data.Properties) do
			local finalValue

			-- Handle properties with animated components (expanded tracks)
			if propTrack.Components and next(propTrack.Components) then
				local baseValue = object[propName] -- Get the current value as a base
				local valueType = typeof(baseValue)

				if valueType == "Vector3" then
					local x = self:getValueAtFrame(propTrack.Components.X, self.currentFrame) or baseValue.X
					local y = self:getValueAtFrame(propTrack.Components.Y, self.currentFrame) or baseValue.Y
					local z = self:getValueAtFrame(propTrack.Components.Z, self.currentFrame) or baseValue.Z
					finalValue = Vector3.new(x, y, z)
				elseif valueType == "Color3" then
					local r = self:getValueAtFrame(propTrack.Components.R, self.currentFrame) or baseValue.R
					local g = self:getValueAtFrame(propTrack.Components.G, self.currentFrame) or baseValue.G
					local b = self:getValueAtFrame(propTrack.Components.B, self.currentFrame) or baseValue.B
					finalValue = Color3.new(r, g, b)
				elseif valueType == "UDim2" then
					local xs = self:getValueAtFrame(propTrack.Components.XScale, self.currentFrame) or baseValue.X.Scale
					local xo = self:getValueAtFrame(propTrack.Components.XOffset, self.currentFrame) or baseValue.X.Offset
					local ys = self:getValueAtFrame(propTrack.Components.YScale, self.currentFrame) or baseValue.Y.Scale
					local yo = self:getValueAtFrame(propTrack.Components.YOffset, self.currentFrame) or baseValue.Y.Offset
					finalValue = UDim2.new(xs, xo, ys, yo)
				end
			else
				-- Handle simple properties (non-expanded tracks)
				finalValue = self:getValueAtFrame(propTrack, self.currentFrame)
			end

			if finalValue ~= nil then
				-- Only set property if not playing, or if it has keyframes
				-- This prevents overriding physics/other scripts when not explicitly animated
				if not isPlaying or trackHasKeyframes(propTrack) then
					local targetObject = object
					if targetObject:IsA("Model") and propName == "CFrame" then
						targetObject = targetObject.PrimaryPart
					end

					if targetObject then
						targetObject[propName] = finalValue
					end
				end
			end
		end
	end
end

-- The main update function to be called every frame
function TimelineLogic:update(dt)
	if not self.isPlaying then return false end

	local frameIncrement = dt * self.Config.FRAMES_PER_SECOND
	local nextFrame = self.currentFrame + frameIncrement

	local animationFinished = false
	if nextFrame > self.endFrame then
		if self.state.isLoopingEnabled then
			nextFrame = self.startFrame
		else
			nextFrame = self.endFrame
			self:pause()
			animationFinished = true
		end
	end

	self:setCurrentFrame(nextFrame, true)
	return animationFinished
end

return TimelineLogic
