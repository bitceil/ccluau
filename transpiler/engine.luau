local parser = require("../parser/engine")

local BinaryOpMap = {
	[0] = "+",
	[1] = "-",
	[2] = "*",
	[3] = "/",
	[4] = "//",
	[5] = "%",
	[6] = "^",
	[7] = "..",
	[8] = "~=",
	[9] = "==",
	[10] = "<",
	[11] = "<=",
	[12] = ">",
	[13] = ">=",
	[14] = "and",
	[15] = "or",
}

local UnaryOpMap = {
	[0] = "not ",
	[1] = "-",
	[2] = "#",
}

local Transpiler = {}
Transpiler.__index = Transpiler

function Transpiler.new(options)
	options = options or {}
	return setmetatable({
		indent = 0,
		tempCount = 0,
		loopDepth = 0,
		loopStack = {},
		nextLoopId = 0,
		output = {},
		preStatements = {},
		usedPolyfills = {},
		currentLine = 1,
		scopes = {},
		noSync = options.noSync or false,
	}, Transpiler)
end

function Transpiler:pushScope()
	table.insert(self.scopes, {
		vars = {},
		count = 0,
		isSpilled = false,
		spillInjected = false,
	})
end

function Transpiler:popScope()
	table.remove(self.scopes)
end

function Transpiler:addLocal(name)
	local scope = self.scopes[#self.scopes]
	if not scope then
		return
	end

	scope.count += 1
	if scope.count >= 150 then
		scope.isSpilled = true
	end
	scope.vars[name] = scope.isSpilled
end

function Transpiler:isSpilled(name)
	for i = #self.scopes, 1, -1 do
		local scope = self.scopes[i]
		if scope.vars[name] ~= nil then
			return scope.vars[name]
		end
	end
	return false
end

function Transpiler:usePolyfill(name)
	self.usedPolyfills[name] = true
end

function Transpiler:nextTemp()
	self.tempCount += 1
	return "_tmp" .. self.tempCount
end

function Transpiler:pushPre(s)
	table.insert(self.preStatements, s)
end

function Transpiler:write(s)
	table.insert(self.output, s)
	local _, count = s:gsub("\n", "\n")
	self.currentLine += count
end

function Transpiler:sync(node)
	if self.noSync then
		return
	end
	local target = node.location.begin.line + 1
	while self.currentLine < target do
		self:write("\n")
	end
end

function Transpiler:syncEnd(node)
	if self.noSync then
		return
	end
	local target = node.location.end_.line + 1
	while self.currentLine < target do
		self:write("\n")
	end
end

function Transpiler:walkExpr(node): string
	if not node then
		return "nil"
	end
	if node.kind == "ExprGroup" then
		return "(" .. self:walkExpr(node.expr) .. ")"
	elseif node.kind == "ExprConstantNil" then
		return "nil"
	elseif node.kind == "ExprConstantBool" then
		return tostring(node.value)
	elseif node.kind == "ExprConstantNumber" then
		return tostring(node.value)
	elseif node.kind == "ExprConstantString" then
		local s = node.value:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t"):gsub('"', '\\"')
		return '"' .. s .. '"'
	elseif node.kind == "ExprLocal" then
		local name = node["local"].name
		if self:isSpilled(name) then
			return "_L." .. name
		end
		return name
	elseif node.kind == "ExprGlobal" then
		local name = node.name
		if name == "task" or name == "vector" or name == "buffer" then
			self:usePolyfill(name)
		elseif name == "getfenv" or name == "setfenv" then
			self:usePolyfill("fenv")
		end
		return name
	elseif node.kind == "ExprVarargs" then
		return "..."
	elseif node.kind == "ExprCall" then
		local s = self:walkExpr(node.func)
		local args = {}
		for _, arg in ipairs(node.args) do
			table.insert(args, self:walkExpr(arg))
		end
		return s .. "(" .. table.concat(args, ", ") .. ")"
	elseif node.kind == "ExprIndexName" then
		local expr = self:walkExpr(node.expr)
		if expr == "math" or expr == "os" or expr == "table" or expr == "string" then
			self:usePolyfill(expr)
		end
		return expr .. (node.op == 58 and ":" or ".") .. node.index
	elseif node.kind == "ExprIndexExpr" then
		local expr = self:walkExpr(node.expr)
		if expr == "math" or expr == "os" or expr == "table" or expr == "string" then
			self:usePolyfill(expr)
		end
		return expr .. "[" .. self:walkExpr(node.index) .. "]"
	elseif node.kind == "ExprFunction" then
		local args = {}
		for _, arg in ipairs(node.args) do
			table.insert(args, arg.name)
		end
		if node.vararg then
			table.insert(args, "...")
		end

		local header = "function(" .. table.concat(args, ", ") .. ")\n"
		local oldOutput = self.output
		local oldLine = self.currentLine
		self.output = {}
		self.currentLine += 1
		self.indent += 1
		self:pushScope()
		for _, arg in ipairs(node.args) do
			self:addLocal(arg.name)
		end
		
		local fScope = self.scopes[#self.scopes]
		if fScope.isSpilled and not fScope.spillInjected then
			self:write(string.rep("\t", self.indent) .. "local _L = {}\n")
			fScope.spillInjected = true
		end

		self:walkStat(node.body)
		local body = table.concat(self.output)
		self.output = oldOutput
		self.currentLine = oldLine
		self:popScope()
		self.indent -= 1
		return header .. body .. string.rep("\t", self.indent) .. "end"
	elseif node.kind == "ExprTable" then
		local items = {}
		for _, item in ipairs(node.items) do
			if item.kind == "List" then
				table.insert(items, self:walkExpr(item.value))
			elseif item.kind == "Record" then
				table.insert(items, item.key.value .. " = " .. self:walkExpr(item.value))
			elseif item.kind == "General" then
				table.insert(items, "[" .. self:walkExpr(item.key) .. "] = " .. self:walkExpr(item.value))
			end
		end
		return "{" .. table.concat(items, ", ") .. "}"
	elseif node.kind == "ExprUnary" then
		return UnaryOpMap[node.op] .. self:walkExpr(node.expr)
	elseif node.kind == "ExprBinary" then
		return self:walkExpr(node.left) .. " " .. BinaryOpMap[node.op] .. " " .. self:walkExpr(node.right)
	elseif node.kind == "ExprTypeAssertion" then
		return self:walkExpr(node.expr)
	elseif node.kind == "ExprIfElse" then
		local id = self.tempCount
		self.tempCount += 1
		local temp = "_tmp" .. id
		local cond = self:walkExpr(node.condition)
		local trueVal = self:walkExpr(node.trueExpr)
		local falseVal = self:walkExpr(node.falseExpr)
		self:pushPre(
			"local " .. temp .. "; if " .. cond .. " then " .. temp .. " = " .. trueVal .. " else " .. temp .. " = " .. falseVal .. " end"
		)
		return temp
	elseif node.kind == "ExprInterpString" then
		local id = self.tempCount
		self.tempCount += 1
		local parts = {}
		local counter = 1
		for i, part in ipairs(node.strings) do
			table.insert(parts, "_interpolate" .. id .. "[" .. counter .. "] = " .. string.format("%q", part))
			counter += 1
			if node.expressions[i] then
				table.insert(parts, "_interpolate" .. id .. "[" .. counter .. "] = tostring(" .. self:walkExpr(node.expressions[i]) .. ")")
				counter += 1
			end
		end
		self:pushPre(
			"local _interpolate" .. id .. " = {}; " .. table.concat(parts, "; ") .. "; local _tmp" .. id .. " = table.concat(_interpolate" .. id .. ")"
		)
		return "_tmp" .. id
	end
	return "[[ UNKNOWN EXPR " .. tostring(node.kind) .. " ]]"
end

function Transpiler:walkStat(node)
	if not node then
		return
	end
	if node.kind == "StatBlock" then
		for _, stat in ipairs(node.body) do
			if stat then
				self:walkStat(stat)
			end
		end
		return
	end

	self:sync(node)

	if node.kind == "StatIf" then
		local cond = self:walkExpr(node.condition)
		self:write(string.rep("\t", self.indent) .. "if " .. cond .. " then\n")
		self.indent += 1
		self:walkStat(node.thenbody)
		self.indent -= 1
		if node.elsebody then
			self:write(string.rep("\t", self.indent) .. "else\n")
			self.indent += 1
			self:walkStat(node.elsebody)
			self.indent -= 1
		end
		self:syncEnd(node)
		self:write(string.rep("\t", self.indent) .. "end\n")
	elseif node.kind == "StatWhile" then
		local cond = self:walkExpr(node.condition)
		local loopId = self.nextLoopId
		self.nextLoopId += 1
		table.insert(self.loopStack, loopId)
		self:write(string.rep("\t", self.indent) .. "while " .. cond .. " do\n")
		self.indent += 1
		self.loopDepth += 1
		self:walkStat(node.body)
		self.loopDepth -= 1
		self.indent -= 1
		table.remove(self.loopStack)
		self:syncEnd(node)
		self:write(string.rep("\t", self.indent) .. "::_continue" .. loopId .. ":: end ")
	elseif node.kind == "StatRepeat" then
		local loopId = self.nextLoopId
		self.nextLoopId += 1
		table.insert(self.loopStack, loopId)
		self:write(string.rep("\t", self.indent) .. "repeat\n")
		self.indent += 1
		self.loopDepth += 1
		self:walkStat(node.body)
		local cond = self:walkExpr(node.condition)
		self.loopDepth -= 1
		self.indent -= 1
		table.remove(self.loopStack)
		self:write(string.rep("\t", self.indent) .. "::_continue" .. loopId .. ":: until " .. cond .. " ")
	elseif node.kind == "StatBreak" then
		self:write(string.rep("\t", self.indent) .. "break\n")
	elseif node.kind == "StatContinue" then
		local loopId = self.loopStack[#self.loopStack]
		self:write(string.rep("\t", self.indent) .. "goto _continue" .. loopId .. "\n")
	elseif node.kind == "StatReturn" then
		local vals = {}
		for _, v in ipairs(node.list) do
			table.insert(vals, self:walkExpr(v))
		end
		self:write(string.rep("\t", self.indent) .. "return " .. table.concat(vals, ", ") .. "\n")
	elseif node.kind == "StatExpr" then
		local expr = self:walkExpr(node.expr)
		local pre = table.concat(self.preStatements, "; ")
		if #pre > 0 then
			pre ..= "; "
		end
		self.preStatements = {}
		self:write(string.rep("\t", self.indent) .. pre .. expr .. "\n")
	elseif node.kind == "StatLocal" then
		local scope = self.scopes[#self.scopes]
		local vars = {}
		local spilledVars = {}
		local vals = {}
		if node.values then
			for _, v in ipairs(node.values) do
				table.insert(vals, self:walkExpr(v))
			end
		end

		for i, v in ipairs(node.vars) do
			self:addLocal(v.name)
			if scope.isSpilled then
				table.insert(spilledVars, { name = v.name, val = vals[i] or "nil" })
			else
				table.insert(vars, v.name)
			end
		end

		local pre = table.concat(self.preStatements, "; ")
		if #pre > 0 then
			pre ..= "; "
		end
		self.preStatements = {}

		if #vars > 0 then
			local s = string.rep("\t", self.indent) .. "local " .. table.concat(vars, ", ")
			if #vals > 0 then
				-- Special case: if the last value is a call, don't pad with nil to preserve multi-returns
				local isLastCall = node.values
					and node.values[#node.values]
					and (
						node.values[#node.values].kind == "ExprCall"
						or node.values[#node.values].kind == "ExprIndexName"
					)
				local actualVals = {}
				if isLastCall then
					for i = 1, #vals do
						table.insert(actualVals, vals[i])
					end
				else
					for i = 1, #vars do
						table.insert(actualVals, vals[i] or "nil")
					end
				end
				s ..= " = " .. table.concat(actualVals, ", ")
			end
			self:write(pre .. s .. "\n")
		end

		if #spilledVars > 0 then
			if not scope.spillInjected then
				self:write(string.rep("\t", self.indent) .. "local _L = {}\n")
				scope.spillInjected = true
			end
			for _, sv in ipairs(spilledVars) do
				self:write(string.rep("\t", self.indent) .. "_L." .. sv.name .. " = " .. sv.val .. "\n")
			end
		end
	elseif node.kind == "StatFor" then
		local from = self:walkExpr(node.from)
		local to = self:walkExpr(node.to)
		local step = node.step and self:walkExpr(node.step)
		local loopId = self.nextLoopId
		self.nextLoopId += 1
		table.insert(self.loopStack, loopId)
		self:pushScope()
		self:addLocal(node["var"].name)
		local s = string.rep("\t", self.indent) .. "for " .. node["var"].name .. " = " .. from .. ", " .. to
		if step then
			s ..= ", " .. step
		end
		s ..= " do\n"
		self:write(s)
		self.indent += 1
		self.loopDepth += 1
		self:walkStat(node.body)
		self.loopDepth -= 1
		self.indent -= 1
		table.remove(self.loopStack)
		self:syncEnd(node)
		self:write(string.rep("\t", self.indent) .. "::_continue" .. loopId .. ":: end ")
		self:popScope()
	elseif node.kind == "StatForIn" then
		self:pushScope()
		local varNames = {}
		for _, v in ipairs(node.vars) do
			self:addLocal(v.name)
			table.insert(varNames, v.name)
		end
		local vals = {}
		for _, v in ipairs(node.values) do
			table.insert(vals, self:walkExpr(v))
		end

		-- Generalized iteration support for Lua 5.1
		if #vals == 1 then
			local val = vals[1]
			if not val:match("^pairs%(") and not val:match("^ipairs%(") then
				vals[1] = "pairs(" .. val .. ")"
			end
		end

		local loopId = self.nextLoopId
		self.nextLoopId += 1
		table.insert(self.loopStack, loopId)
		local s = string.rep("\t", self.indent)
			.. "for "
			.. table.concat(varNames, ", ")
			.. " in "
			.. table.concat(vals, ", ")
			.. " do\n"
		self:write(s)
		self.indent += 1
		self.loopDepth += 1
		self:walkStat(node.body)
		self.loopDepth -= 1
		self.indent -= 1
		table.remove(self.loopStack)
		self:syncEnd(node)
		self:write(string.rep("\t", self.indent) .. "::_continue" .. loopId .. ":: end ")
		self:popScope()
	elseif node.kind == "StatAssign" then
		local vars = {}
		for _, v in ipairs(node.vars) do
			table.insert(vars, self:walkExpr(v))
		end
		local vals = {}
		for _, v in ipairs(node.values) do
			table.insert(vals, self:walkExpr(v))
		end
		local pre = table.concat(self.preStatements, "; ")
		if #pre > 0 then
			pre ..= "; "
		end
		self.preStatements = {}
		local s = string.rep("\t", self.indent) .. pre .. table.concat(vars, ", ") .. " = "
		local isLastCall = node.values
			and node.values[#node.values]
			and (node.values[#node.values].kind == "ExprCall" or node.values[#node.values].kind == "ExprIndexName")
		local actualVals = {}
		if isLastCall then
			for i = 1, #vals do
				table.insert(actualVals, vals[i])
			end
		else
			for i = 1, #vars do
				table.insert(actualVals, vals[i] or "nil")
			end
		end
		self:write(s .. table.concat(actualVals, ", ") .. "\n")
	elseif node.kind == "StatCompoundAssign" then
		local var = self:walkExpr(node.var)
		local val = self:walkExpr(node.value)
		local op = BinaryOpMap[node.op]
		if op == "//" then
			self:write(string.rep("\t", self.indent) .. var .. " = math.floor(" .. var .. " / " .. val .. ")\n")
		else
			self:write(string.rep("\t", self.indent) .. var .. " = " .. var .. " " .. op .. " " .. val .. "\n")
		end
	elseif node.kind == "StatFunction" then
		local name = self:walkExpr(node.name)
		self:pushScope()
		local args = {}
		for _, arg in ipairs(node.func.args) do
			self:addLocal(arg.name)
			table.insert(args, arg.name)
		end
		if node.func.vararg then
			table.insert(args, "...")
		end
		self:write(string.rep("\t", self.indent) .. "function " .. name .. "(" .. table.concat(args, ", ") .. ")\n")
		self.indent += 1

		local scope = self.scopes[#self.scopes]
		if scope.isSpilled and not scope.spillInjected then
			self:write(string.rep("\t", self.indent) .. "local _L = {}\n")
			scope.spillInjected = true
		end

		self:walkStat(node.func.body)
		self.indent -= 1
		self:syncEnd(node)
		self:write(string.rep("\t", self.indent) .. "end\n")
		self:popScope()
	elseif node.kind == "StatLocalFunction" then
		local scope = self.scopes[#self.scopes]
		self:addLocal(node.name.name)

		local prefix = "local "
		if scope.isSpilled then
			if not scope.spillInjected then
				self:write(string.rep("\t", self.indent) .. "local _L = {}\n")
				scope.spillInjected = true
			end
			prefix = "_L."
		end

		self:write(string.rep("\t", self.indent) .. prefix .. node.name.name .. " = ")

		self:pushScope()
		local args = {}
		for _, arg in ipairs(node.func.args) do
			self:addLocal(arg.name)
			table.insert(args, arg.name)
		end
		if node.func.vararg then
			table.insert(args, "...")
		end
		self:write("function(" .. table.concat(args, ", ") .. ")\n")
		self.indent += 1

		local fScope = self.scopes[#self.scopes]
		if fScope.isSpilled and not fScope.spillInjected then
			self:write(string.rep("\t", self.indent) .. "local _L = {}\n")
			fScope.spillInjected = true
		end

		self:walkStat(node.func.body)
		self.indent -= 1
		self:syncEnd(node)
		self:write(string.rep("\t", self.indent) .. "end\n")
		self:popScope()
	elseif node.kind == "StatTypeAlias" or node.kind == "StatTypeFunction" then
		self:syncEnd(node)
		return
	end
end

function Transpiler:transpile(source: string, options): string
	local oldNoSync = self.noSync
	if options and options.noSync ~= nil then
		self.noSync = options.noSync
	end

	local success, result = parser.parse(source)
	if not success then
		if type(result) == "table" and result.errors then
			local errs = {}
			for _, e in ipairs(result.errors) do
				table.insert(errs, e.message)
			end
			error("Parse error: " .. table.concat(errs, ", "))
		else
			error("Parse error: " .. tostring(result))
		end
	end

	self:pushScope()
	self:walkStat(result.root)
	self:popScope()

	local out = table.concat(self.output)
	self.output = {}
	self.currentLine = 1
	self.noSync = oldNoSync
	return out
end

return {
	new = Transpiler.new,
}
