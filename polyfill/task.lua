if not task then
	task = {}
end

do
	local cancelled = setmetatable({}, { __mode = "k" })

	if not task.spawn then
		task.spawn = function(f, ...)
			local thread
			if type(f) == "function" then
				thread = coroutine.create(f)
			else
				thread = f
			end
			local success, result = coroutine.resume(thread, ...)
			if not success then
				print(debug.traceback(thread, result))
			end
			return thread
		end
	end

	if not task.cancel then
		task.cancel = function(thread)
			cancelled[thread] = true
		end
	end

	if not task.wait then
		task.wait = function(duration)
			local thread = coroutine.running()
			sleep(duration or 0)
			if cancelled[thread] then
				while true do coroutine.yield() end
			end
		end
	end

	if not task.delay then
		task.delay = function(duration, f, ...)
			local args = { ... }
			local thread
			thread = task.spawn(function()
				task.wait(duration)
				if not cancelled[thread] then
					f(table.unpack(args))
				end
			end)
			return thread
		end
	end

	if not task.defer then
		task.defer = function(f, ...)
			local args = { ... }
			local thread
			thread = task.spawn(function()
				task.wait(0)
				if not cancelled[thread] then
					f(table.unpack(args))
				end
			end)
			return thread
		end
	end
end
