-- Taken from Roblox's old Chat Script.
local OFFSET = 0
local SCALE = 10

local function getNameValue(name: string): number
	local value = 0
	for index = 1, #name do
		local cValue = string.byte(string.sub(name, index, index))
		local reverseIndex = #name - index + 1
		if #name%2 == 1 then
			reverseIndex = reverseIndex - 1
		end
		if reverseIndex%4 >= 2 then
			cValue = -cValue
		end
		value = value + cValue
	end
	return value
end

--[=[
    ULTRA BASED SIGMA CALCULATOR

    @param name string -- The name you want to check,
    @return number -- Returns a sigma percentage.
]=]
local function calculateSigma(name: string): number
	return math.round((((getNameValue(name) + OFFSET) % SCALE) / (SCALE - 1)) * 100)
end

return calculateSigma