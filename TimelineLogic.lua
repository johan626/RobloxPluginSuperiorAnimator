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


-- Sets the current frame and updates the objects in the scene to match
function TimelineLogic:setCurrentFrame(frame, isPlaying)
	self.currentFrame = math.clamp(frame, 0, self.Config.MAX_FRAMES)

	for uid, data in pairs(self.animationData) do
		if uid == "SuperiorAnimator_Camera" then continue end

		local object = data.object
		if not object or not object.Parent then continue end

		local cframeComponents = {}

		for propName, propTrack in pairs(data.Properties) do
			local finalValue

			-- Handle composite properties like CFrame
			if propTrack.Components and next(propTrack.Components) then
				local componentValues = {}
				local allComponentsHaveValue = true
				for compName, compTrack in pairs(propTrack.Components) do
					local val = self:getValueAtFrame(compTrack, self.currentFrame)
					if val ~= nil then
						componentValues[compName] = val
					else
						-- If a component is missing a value, try to get it from the instance itself
						if propName == "CFrame" and (compName == "Position" or compName == "Rotation") then
							componentValues[compName] = object[propName][compName]
						else
							allComponentsHaveValue = false
							break 
						end
					end
				end

				if allComponentsHaveValue then
					if propName == "CFrame" then
						finalValue = CFrame.new(componentValues.Position) * CFrame.Angles(
							math.rad(componentValues.Rotation.X),
							math.rad(componentValues.Rotation.Y),
							math.rad(componentValues.Rotation.Z)
						)
					end
				end
			else
				-- Handle simple properties
				finalValue = self:getValueAtFrame(propTrack, self.currentFrame)
			end

			if finalValue ~= nil then
				-- Only set property if not playing, or if it has keyframes
				-- This prevents overriding physics/other scripts when not explicitly animated
				if not isPlaying or (propTrack.keyframes and next(propTrack.keyframes)) then
					object[propName] = finalValue
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
