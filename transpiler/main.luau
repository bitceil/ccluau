local fs = require("@lune/fs")
local process = require("@lune/process")
local transpiler = require("./engine")

local inputPath
local outputPath = "out.lua"
local noSync = false

for _, arg in ipairs(process.args) do
	if arg == "--no-sync" then
		noSync = true
	elseif not inputPath then
		inputPath = arg
	else
		outputPath = arg
	end
end

if not inputPath then
	print("usage: lune run main.luau <input.luau> [output.lua] [--no-sync]")
	process.exit(1)
end

local source = fs.readFile(inputPath)

local t = transpiler.new({ noSync = noSync })
local code
local success, err = pcall(function()
	code = t:transpile(source)
end)

if not success then
	print("Transpilation failed:", err)
	process.exit(1)
end

local polyfillContent = ""
for name in pairs(t.usedPolyfills) do
	local path = "polyfill/" .. name .. ".lua"
	if fs.isFile(path) then
		local content = fs.readFile(path)
		content = content:gsub("\r", "")
		content = content:gsub("%-%-%[%=*%[.-%]%=*%]", "") -- remove block comments
		content = content:gsub("%-%-[^\n]*", "") -- remove line comments
		content = content:gsub("[\n\r\t]+", " ") -- collapse whitespace
		content = content:gsub("%s+", " ")
		polyfillContent ..= content .. " "
	end
end

local finalCode = code
if #polyfillContent > 0 then
	local escaped = polyfillContent:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r")
	finalCode = 'local _ = (loadstring or load)("' .. escaped .. '")(); ' .. code
end
fs.writeFile(outputPath, finalCode)
print("transpiled to " .. outputPath)
