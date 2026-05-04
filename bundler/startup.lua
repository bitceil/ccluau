-- ccluau startup script
-- this script enables luau support by hooking loadfile and load

local bundlePath = "ccluau.lua"

if fs.exists(bundlePath) then
	local h = fs.open(bundlePath, "r")
	local content = h.readAll()
	h.close()

	local f, err = loadstring(content, "@/" .. bundlePath)
	if f then
		local ok, err = pcall(f, require)
		if not ok then
			printError("Failed to initialize ccluau: " .. err)
		end
	else
		printError("Failed to parse ccluau: " .. err)
	end
end

if _G.luau then
	local function transpile_if_luau(content, chunkname)
		if type(chunkname) == "string" and chunkname:match("%.luau$") then
			-- print("Luau: Transpiling " .. chunkname)
			local ok, res = pcall(_G.luau.transpile, content)
			if ok then
				-- print("Luau: Success (" .. #res .. " bytes)")
				return res
			end
			printError("Luau: Transpilation failed for " .. chunkname)
			printError(res)
		end
		return content
	end

	-- Hook load
	local native_load = _G.load
	_G.load = function(chunk, chunkname, mode, env)
		if type(chunk) == "string" then
			chunk = transpile_if_luau(chunk, chunkname)
		elseif type(chunk) == "function" then
			-- If it's a function (file reader), we have to be careful.
			-- For now, if the chunkname is luau, read it all and transpile.
			if type(chunkname) == "string" and chunkname:match("%.luau$") then
				local t = {}
				while true do
					local s = chunk()
					if not s or s == "" then
						break
					end
					table.insert(t, s)
				end
				local content = table.concat(t)
				return native_load(transpile_if_luau(content, chunkname), chunkname, mode, env)
			end
		end
		return native_load(chunk, chunkname, mode, env)
	end

	-- Hook loadstring
	local native_loadstring = _G.loadstring
	if native_loadstring then
		_G.loadstring = function(str, chunkname)
			str = transpile_if_luau(str, chunkname)
			return native_loadstring(str, chunkname)
		end
	end

	-- Hook loadfile
	local native_loadfile = _G.loadfile
	_G.loadfile = function(filename, mode, env)
		if type(mode) == "table" and env == nil then
			mode, env = nil, mode
		end
		local targetFile = filename
		if not fs.exists(targetFile) and shell and shell.resolve then
			targetFile = shell.resolve(filename)
		end
		if not fs.exists(targetFile) and not targetFile:find("%.") then
			if fs.exists(targetFile .. ".luau") then
				targetFile = targetFile .. ".luau"
			end
		end

		if fs.exists(targetFile) and targetFile:match("%.luau$") then
			local file = fs.open(targetFile, "r")
			local contents = file.readAll()
			file.close()
			local transpiled = transpile_if_luau(contents, "@/" .. targetFile)
			return native_load(transpiled, "@/" .. targetFile, mode, env)
		end
		return native_loadfile(filename, mode, env)
	end

	-- Hook require
	local native_require = _G.require
	_G.require = function(name)
		-- Try native require first (handles .lua and already loaded modules)
		local ok, res = pcall(native_require, name)
		if ok then
			return res
		end

		if package and package.loaded[name] then
			return package.loaded[name]
		end

		-- We use loadfile because we've already hooked it to handle .luau transpilation
		local f, err = loadfile(name) -- loadfile hook handles appending .luau
		if f then
			local res = f()
			if package then
				package.loaded[name] = res or true
			end
			return res or true
		end

		-- Fallback to the original error if we still can't find anything
		error(err or ("module '" .. name .. "' not found"), 2)
	end

	-- Hook shell.resolveProgram to find .luau files
	if shell and shell.resolveProgram then
		local native_resolve = shell.resolveProgram
		shell.resolveProgram = function(name)
			local res = native_resolve(name)
			if res then
				return res
			end
			if not name:find("%.") then
				res = native_resolve(name .. ".luau")
				if res then
					return res
				end
			end
			return nil
		end
	end

	print("Luau support enabled.")

	-- Run startup.luau if it exists
	if fs.exists("startup.luau") then
		shell.run("startup.luau")
	end

	-- Support .luau files in the startup directory
	if fs.exists("startup") and fs.isDir("startup") then
		for _, file in ipairs(fs.list("startup")) do
			if file:match("%.luau$") then
				local path = fs.combine("startup", file)
				if not fs.isDir(path) then
					shell.run(path)
				end
			end
		end
	end
end
