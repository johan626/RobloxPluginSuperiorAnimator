-- SuperiorAnimator/src/EasingFunctions.lua

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

return {
	Functions = EasingFunctions,
	Styles = easingStyles,
}
