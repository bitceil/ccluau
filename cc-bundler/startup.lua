-- ccluau startup script
-- hooks environment to support .luau files

if not _G.luau then
	local bundlePath = "ccluau.lua"
	local f = fs.open(bundlePath, "r")
	if not f then
		bundlePath = "/ccluau.lua"
		f = fs.open(bundlePath, "r")
	end
	
	if f then
		local content = f.readAll()
		f.close()
		local fn, err = loadstring(content, "@/" .. bundlePath)
		if fn then
			pcall(fn, require)
		end
	end
end

if _G.luau then
	local function transpile_if_luau(content, chunkname)
		if type(chunkname) == "string" and chunkname:match("%.luau$") then
			local ok, res = pcall(_G.luau.transpile, content)
			if ok then return res end
			printError("Luau: Transpilation failed for " .. chunkname)
			printError(res)
		end
		return content
	end

	local function get_shell()
		return _G.shell or shell or (multishell and multishell.getCurrent and multishell.getTabEnv and multishell.getTabEnv(multishell.getCurrent()).shell)
	end

	local native_load = _G.load
	local native_loadfile = _G.loadfile

	local function luau_searcher(package, env)
		return function(name)
			local s = get_shell()
			local dir = s and s.dir and s.dir() or ""

			if name:match("%.lua[u]?$") then
				local path = name
				if path:sub(1, 1) ~= "/" then
					path = fs.combine(dir, path)
				end
				if fs.exists(path) and not fs.isDir(path) then
					local fnFile, sError = _G.loadfile(path, nil, env)
					if fnFile then return fnFile, path end
					return nil, sError
				end
				return nil, "no file '" .. path .. "'"
			end

			local luau_path = "?.luau;?/init.luau"
			local searchpath = package.searchpath
			local sPath, sError = searchpath(name, luau_path)
			if sPath then
				local fnFile, sError = _G.loadfile(sPath, nil, env)
				if fnFile then return fnFile, sPath end
				return nil, sError
			end
			return nil, sError
		end
	end

	local injected_envs = setmetatable({}, { __mode = "k" })

	_G.load = function(chunk, chunkname, mode, env)
		if type(chunk) == "string" then
			chunk = transpile_if_luau(chunk, chunkname)
		end
		if type(env) == "table" and not injected_envs[env] then
			if type(env.package) == "table" and type(env.package.loaders) == "table" then
				table.insert(env.package.loaders, 2, luau_searcher(env.package, env))
				injected_envs[env] = true
			end
		end
		return native_load(chunk, chunkname, mode, env)
	end

	local native_loadstring = _G.loadstring
	_G.loadstring = function(content, chunkname)
		content = transpile_if_luau(content, chunkname)
		return native_loadstring(content, chunkname)
	end

	_G.loadfile = function(filename, mode, env)
		if type(mode) == "table" and env == nil then
			mode, env = nil, mode
		end
		local targetFile = filename
		local s = get_shell()
		if not fs.exists(targetFile) and s and s.resolve then
			targetFile = s.resolve(filename)
		end
		if not fs.exists(targetFile) and not targetFile:match("%.lua[u]?$") then
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

	if get_shell() and get_shell().resolveProgram then
		local native_resolve = get_shell().resolveProgram
		get_shell().resolveProgram = function(name)
			local res = native_resolve(name)
			if res then return res end
			if not name:match("%.lua[u]?$") then
				res = native_resolve(name .. ".luau")
				if res then return res end
			end
			return nil
		end
	end

	print("Luau support enabled.")
end
