local fs = require("@lune/fs")
local transpiler = require("../transpiler/engine")

local function cleanString(s)
	return string.format("%q", s):gsub("\\\n", "\\n"):gsub("\r", "\\r")
end

local function getFiles(dir, ext)
	local results = {}
	for _, item in fs.readDir(dir) do
		local path = dir .. "/" .. item
		if fs.isDir(path) then
			for _, sub in getFiles(path, ext) do
				table.insert(results, sub)
			end
		elseif item:sub(-#ext) == ext then
			table.insert(results, path)
		end
	end
	return results
end

local modulesCode = {}
local luauFiles = {}
for _, f in getFiles("parser", ".luau") do
	if not f:match("main%.luau$") then
		table.insert(luauFiles, f)
	end
end
for _, f in getFiles("transpiler", ".luau") do
	if not f:match("main%.luau$") then
		table.insert(luauFiles, f)
	end
end

for _, path in ipairs(luauFiles) do
	local name = path:sub(1, -6)
	print(`transpiling {path}...`)

	local source = fs.readFile(path)
	local code = transpiler.new():transpile(source, { noSync = true })

	table.insert(modulesCode, { name = name, code = code })
end

local polyfills = {}
for _, path in ipairs(getFiles("polyfill", ".lua")) do
	local name = path:match("([^/]+)%.lua$")
	print(`bundling polyfill {name}...`)

	local content = fs.readFile(path)
	content = content:gsub("\r", "")
	content = content:gsub("%-%-%[%=*%[.-%]%=*%]", "") -- remove block comments
	content = content:gsub("%-%-[^\n]*", "") -- remove line comments
	content = content:gsub("[\n\r\t]+", " ") -- collapse whitespace
	content = content:gsub("%s+", " ")
	polyfills[name] = content
end

local output = {}

table.insert(output, "local _MODULES = {}")
table.insert(output, "local _POLYFILLS = {}")
for name, content in pairs(polyfills) do
	table.insert(output, string.format("_POLYFILLS[%q] = %s", name, cleanString(content)))
end

table.insert(
	output,
	[[
-- Initialize polyfills into the environment
for name, code in pairs(_POLYFILLS) do
    local _F, _E = loadstring(code, "@polyfill/" .. name)
    if _F then 
        local ok, err = pcall(_F)
        if not ok then print("Warning: polyfill " .. name .. " failed: " .. err) end
    else 
        print("Warning: failed to parse polyfill " .. name .. ": " .. _E) 
    end
end
]]
)

table.insert(output, "local _PASSED_REQUIRE = ...")
table.insert(
	output,
	[[
local _ORG_REQUIRE = _PASSED_REQUIRE or _G.require or require
local function require(path)
    if path == "./syntax" or path == "./Syntax" then return _MODULES["parser/syntax"] end
    if path == "./confusables" or path == "./Confusables" then return _MODULES["parser/confusables"] end
    if path == "../parser/engine" or path == "./engine" then 
        return _MODULES["parser/engine"] or _MODULES["transpiler/engine"] 
    end
    if _MODULES[path] then return _MODULES[path] end
    if _ORG_REQUIRE then return _ORG_REQUIRE(path) end
    error("require not found: " .. path)
end

local function _DEFINE(name, code)
    local _M = {}
    local _ENV = setmetatable(_M, { __index = _G })
    
    local _F, _E = loadstring(code, "@/" .. name)
    if not _F then error("Failed to load module " .. name .. ": " .. _E) end
    
    _ENV.require = require
    if setfenv then setfenv(_F, _ENV) end
    local _R = _F()
    _MODULES[name] = _R or _M
end
]]
)

for _, m in ipairs(modulesCode) do
	table.insert(output, string.format("_DEFINE(%q, %s)", m.name, cleanString(m.code)))
end

table.insert(
	output,
	[[
local transpiler = _MODULES['transpiler/engine']

_G.luau = {
    transpile = function(source, options)
        local ok, t = pcall(transpiler.new, options)
        if not ok then 
            print("Luau: Error creating transpiler: " .. tostring(t))
            return "-- Error creating transpiler: " .. tostring(t) 
        end
        
        local ok2, code = pcall(t.transpile, t, source)
        if not ok2 then 
            print("Luau: Error during transpilation: " .. tostring(code))
            return "-- Error during transpilation: " .. tostring(code) 
        end
        
        local polyfillContent = ""
        local polyCount = 0
        for name in pairs(t.usedPolyfills) do
            if _POLYFILLS[name] then
                polyfillContent = polyfillContent .. _POLYFILLS[name] .. "\n"
                polyCount = polyCount + 1
            end
        end
        
        if #polyfillContent > 0 then
            local escaped = polyfillContent:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n"):gsub("\r", "\\r")
            return "local _ = (loadstring or load)(\"" .. escaped .. "\")(); " .. code
        else
            return code
        end
    end
}
]]
)

local bundleContent = table.concat(output, "\n")
fs.writeFile("dist/ccluau.lua", bundleContent)
print("bundle created at dist/ccluau.lua")

-- generate setup.lua
local startupContent = fs.readFile("dist/startup.lua")
local setupOutput = string.format(
	[[
local ccluau = %s
local startup = %s

local function save(path, content)
    local f = fs.open(path, "w")
    f.write(content)
    f.close()
    print("Installed " .. path)
end

save("ccluau.lua", ccluau)
save("startup.lua", startup)
print("Luau setup complete! Cleaning up and rebooting...")
os.reboot()
]],
	cleanString(bundleContent),
	cleanString(startupContent)
)

fs.writeFile("dist/setup.lua", setupOutput)
print("setup script created at dist/setup.lua")

local net = require("@lune/net")
local ok, res = pcall(function()
	local boundary = "----LuneBoundary" .. tostring(math.random(1000000, 9999999))
	local body = "--"
		.. boundary
		.. "\r\n"
		.. 'Content-Disposition: form-data; name="file"; filename="setup.lua"\r\n'
		.. "Content-Type: text/plain\r\n\r\n"
		.. setupOutput
		.. "\r\n"
		.. "--"
		.. boundary
		.. "--\r\n"

	return net.request({
		url = "https://x0.at/",
		method = "POST",
		body = body,
		headers = {
			["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
		},
	})
end)

if ok and res.statusCode == 200 then
	local url = res.body:gsub("%s+", "")
	print("run this in CraftOS:")
	print(`wget run {url}`)
else
	local errMsg = ok and (res and res.body or "unknown error") or tostring(res)
	print(`failed to upload to x0.at: {errMsg}`)
end
