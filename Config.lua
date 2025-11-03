-- SuperiorAnimator/src/Config.lua

local Config = {
	TRACK_HEIGHT = 28,
	FRAMES_PER_SECOND = 24,
	PIXELS_PER_FRAME_INTERVAL = 60,
	FRAMES_PER_INTERVAL = 10,
	MAX_FRAMES = 1000,
	Colors = {
		-- Latar Belakang
		MainBackground = Color3.fromRGB(36, 36, 36),
		ContentBackground = Color3.fromRGB(42, 42, 42),
		PropertiesBackground = Color3.fromRGB(32, 32, 32),
		TopBarBackground = Color3.fromRGB(28, 28, 28),
		TrackListBackground = Color3.fromRGB(50, 50, 50),
		TrackBackground = Color3.fromRGB(48, 48, 48),
		SubTrackBackground = Color3.fromRGB(52, 52, 52),
		SubTrackLabelBackground = Color3.fromRGB(55, 55, 55),
		DialogBackground = Color3.fromRGB(45, 45, 45),
		DialogHeader = Color3.fromRGB(35, 35, 35),
		InputBackground = Color3.fromRGB(45, 45, 45),

		-- Teks
		TextPrimary = Color3.fromRGB(240, 240, 240),
		TextSecondary = Color3.fromRGB(200, 200, 200),
		TextMuted = Color3.fromRGB(160, 160, 160),
		TextDisabled = Color3.fromRGB(120, 120, 120),

		-- Tombol
		ButtonPrimary = Color3.fromRGB(80, 100, 130),
		ButtonSecondary = Color3.fromRGB(70, 70, 70),
		ButtonDanger = Color3.fromRGB(150, 60, 60),
		ButtonDelete = Color3.fromRGB(100, 50, 50),

		-- Timeline
		Playhead = Color3.fromRGB(255, 100, 100),
		KeyframeLinear = Color3.fromRGB(255, 255, 100),
		KeyframeEased = Color3.fromRGB(100, 255, 180),
		KeyframeSelected = Color3.fromRGB(100, 180, 255),
		TrackSelected = Color3.fromRGB(70, 80, 100),

		-- Lain-lain
		Border = Color3.fromRGB(60, 60, 60),
		Separator = Color3.fromRGB(50, 50, 50),
	}
}

return Config
