if not table.find then
	table.find = function(t, val, init)
		for i = init or 1, #t do
			if t[i] == val then
				return i
			end
		end
		return nil
	end
end

if not table.clear then
	table.clear = function(t)
		for k in pairs(t) do
			t[k] = nil
		end
	end
end

if not table.clone then
	table.clone = function(t)
		local new = {}
		for k, v in pairs(t) do
			new[k] = v
		end
		return new
	end
end

if not table.create then
	table.create = function(size, val)
		local t = {}
		if val ~= nil then
			for i = 1, size do
				t[i] = val
			end
		end
		return t
	end
end

if not table.freeze then
	table.freeze = function(t)
		return t
	end
end

if not table.isfrozen then
	table.isfrozen = function(t)
		return false
	end
end
