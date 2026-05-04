print("hi")

type Point = { x: number, y: number }
local p: Point = { x = 10, y = 20 }

--[[
	multiline comment
	with
	multiple
	lines
]]
--[==[
	funny comment with
	2 equal signs
]==]

-- 0. string interpolation with backticks
local testnum = 96
print(`num = {testnum}`)

-- 1. math lib
print("math.clamp:", math.clamp(15, 0, 10))
print("math.round:", math.round(5.6))
print("math.sign:", math.sign(-42))
print("math.noise:", math.noise(1.5, 2.5, 3.5))

-- 2. string lib
local parts = string.split("apple,banana,cherry", ",")
print("string.split count:", #parts)

-- 3. table lib
local t = table.create(3, "val")
print("table.find:", table.find(t, "val"))
local cloned = table.clone(t)
table.clear(cloned)
print("table.clear count:", #cloned)
table.freeze(t)

-- 4. os lib
print("os.time:", os.time())

-- 5. task lib
task.spawn(function(msg)
	print("task.spawned:", msg)
end, "hello from thread")

-- 6. vector lib
print("Vector magnitude:", vector.magnitude(vector.create(3, 4, 0)))

-- 7. buffer lib
local buf = buffer.create(8)
buffer.writeu32(buf, 0, 0xDEADBEEF)
print("Buffer read:", string.format("0x%X", buffer.readu32(buf, 0)))

-- 8. luau syntax features
-- compound assignment
local count = 0
count += 10
count *= 2
print("Compound count:", count)

-- if-then-else expression
local status = if count > 15 then "high" else "low"
print("Status:", status)

-- nested loops with continue
for i = 1, 2 do
	for j = 1, 2 do
		if j == 2 then
			continue
		end
		print("Loop:", i, j)
	end
	if i == 2 then
		continue
	end
end

print("All tests completed!")
error("test")
