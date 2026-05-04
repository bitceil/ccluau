if not vector then
	vector = {}
end

if not vector.create then
	vector.create = vector.new
end

if not vector.magnitude then
	vector.magnitude = function(v)
		return v:length()
	end
end

if not vector.normalize then
	vector.normalize = function(v)
		return v:normalize()
	end
end
