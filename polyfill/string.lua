if not string.split then
	string.split = function(s, sep)
		sep = sep or ","
		local t = {}
		local n = 0
		if sep == "" then
			for i = 1, #s do
				n = n + 1
				t[n] = string.sub(s, i, i)
			end
			return t
		end
		local start = 1
		while true do
			local pStart, pEnd = string.find(s, sep, start, true)

			n = n + 1
			if not pStart then
				t[n] = string.sub(s, start)
				break
			end
			t[n] = string.sub(s, start, pStart - 1)
			start = pEnd + 1
		end
		return t
	end
end
