local fs = require("@lune/fs")
local process = require("@lune/process")

local function bundle(entryPath)
	local content = fs.readFile(entryPath)

	-- basic replace for relative requires
	content = content:gsub('require%("./engine"%)', 'require("./transpiler/engine")')

	local engineContent = fs.readFile("transpiler/engine.luau")
	engineContent = engineContent:gsub('require%("../parser/engine"%)', 'require("./parser/engine")')

	local parserContent = fs.readFile("parser/engine.luau")
	parserContent = parserContent:gsub('require%("./syntax"%)', 'require("./parser/syntax")')
	parserContent = parserContent:gsub('require%("./confusables"%)', 'require("./parser/confusables")')

	local syntaxContent = fs.readFile("parser/syntax.luau")
	local confusablesContent = fs.readFile("parser/confusables.luau")

	local polyfills = {}
	if fs.isDir("polyfill") then
		for _, item in fs.readDir("polyfill") do
			if item:sub(-4) == ".lua" then
				local name = item:sub(1, -5)
				polyfills[name] = fs.readFile("polyfill/" .. item)
			end
		end
	end

	local output = {}
	table.insert(output, "local _MODULES = {}")
	table.insert(output, "local _EMBEDDED_POLYFILLS = {}")

	for name, text in pairs(polyfills) do
		table.insert(output, string.format("_EMBEDDED_POLYFILLS[%q] = %q", name, text))
	end

	table.insert(
		output,
		[[
local _fs = require("@lune/fs")
local _fakeFs = {}
for k, v in pairs(_fs) do
    _fakeFs[k] = v
end
local originalReadFile = _fs.readFile
local originalIsFile = _fs.isFile

_fakeFs.readFile = function(path)
    if path:sub(1, 9) == "polyfill/" then
        local name = path:sub(10, -5)
        if _EMBEDDED_POLYFILLS[name] then
            return _EMBEDDED_POLYFILLS[name]
        end
    end
    return originalReadFile(path)
end

_fakeFs.isFile = function(path)
    if path:sub(1, 9) == "polyfill/" then
        local name = path:sub(10, -5)
        if _EMBEDDED_POLYFILLS[name] then
            return true
        end
    end
    return originalIsFile(path)
end

local _ORG_REQUIRE = require
local function require(path)
    if _MODULES[path] then return _MODULES[path] end
    if path == "@lune/fs" then return _fakeFs end
    return _ORG_REQUIRE(path)
end
]]
	)

	table.insert(output, string.format("_MODULES['./parser/syntax'] = (function()\n%s\nend)()", syntaxContent))
	table.insert(output, string.format("_MODULES['./parser/confusables'] = (function()\n%s\nend)()", confusablesContent))
	table.insert(output, string.format("_MODULES['./parser/engine'] = (function()\n%s\nend)()", parserContent))
	table.insert(output, string.format("_MODULES['./transpiler/engine'] = (function()\n%s\nend)()", engineContent))

	table.insert(output, "-- Main\n" .. content)

	return table.concat(output, "\n")
end

if not fs.isDir("dist") then
	fs.writeDir("dist")
end

print("bundling standalone luau...")
local bundled = bundle("transpiler/main.luau")
fs.writeFile("dist/standalone.luau", bundled)

print("standalone luau created at dist/standalone.luau")
print("you can now build it with: lune build dist/standalone.luau -o ccluau")
