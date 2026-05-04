local original_os_time = os.time
os.time = function(t)
	if t then
		return original_os_time(t)
	end
	return math.floor(os.epoch("utc") / 1000)
end
