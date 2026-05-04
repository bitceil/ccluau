if not buffer then
	buffer = {}
end

buffer.create = function(size)
	return {
		data = string.rep("\0", size),
		size = size,
	}
end

buffer.len = function(b)
	return b.size
end

buffer.fromstring = function(s)
	return {
		data = s,
		size = #s,
	}
end

buffer.tostring = function(b)
	return b.data
end

local function read(b, offset, fmt, size)
	return (string.unpack("<" .. fmt, b.data, offset + 1))
end

local function write(b, offset, fmt, val, size)
	local before = string.sub(b.data, 1, offset)
	local after = string.sub(b.data, offset + size + 1)
	b.data = before .. string.pack("<" .. fmt, val) .. after
end

buffer.readi8 = function(b, offset)
	return read(b, offset, "b", 1)
end
buffer.readu8 = function(b, offset)
	return read(b, offset, "B", 1)
end
buffer.readi16 = function(b, offset)
	return read(b, offset, "i2", 2)
end
buffer.readu16 = function(b, offset)
	return read(b, offset, "I2", 2)
end
buffer.readi32 = function(b, offset)
	return read(b, offset, "i4", 4)
end
buffer.readu32 = function(b, offset)
	return read(b, offset, "I4", 4)
end
buffer.readf32 = function(b, offset)
	return read(b, offset, "f", 4)
end
buffer.readf64 = function(b, offset)
	return read(b, offset, "d", 8)
end

buffer.writei8 = function(b, offset, val)
	write(b, offset, "b", val, 1)
end
buffer.writeu8 = function(b, offset, val)
	write(b, offset, "B", val, 1)
end
buffer.writei16 = function(b, offset, val)
	write(b, offset, "i2", val, 2)
end
buffer.writeu16 = function(b, offset, val)
	write(b, offset, "I2", val, 2)
end
buffer.writei32 = function(b, offset, val)
	write(b, offset, "i4", val, 4)
end
buffer.writeu32 = function(b, offset, val)
	write(b, offset, "I4", val, 4)
end
buffer.writef32 = function(b, offset, val)
	write(b, offset, "f", val, 4)
end
buffer.writef64 = function(b, offset, val)
	write(b, offset, "d", val, 8)
end

buffer.readstring = function(b, offset, count)
	return string.sub(b.data, offset + 1, offset + count)
end

buffer.writestring = function(b, offset, str, count)
	count = count or #str
	local before = string.sub(b.data, 1, offset)
	local after = string.sub(b.data, offset + count + 1)
	b.data = before .. string.sub(str, 1, count) .. after
end

buffer.copy = function(target, targetOffset, source, sourceOffset, count)
	sourceOffset = sourceOffset or 0
	count = count or (source.size - sourceOffset)
	local str = string.sub(source.data, sourceOffset + 1, sourceOffset + count)
	buffer.writestring(target, targetOffset, str, count)
end

buffer.fill = function(b, offset, val, count)
	count = count or (b.size - offset)
	local str = string.char(val):rep(count)
	buffer.writestring(b, offset, str, count)
end
