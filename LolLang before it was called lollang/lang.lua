require("utils/table")

-- Initializing the local functions
local function str_find(str, substr)
	return string.find(str, substr, 1, true)
end

-- Initializing the special string variables
local WHITESPACE = " \t\r\n"
local OPERATORS = "+-*/%"
local PARENTHESES = "()"
local BRACKETS = "[]"
local CURLY_BRACKETS = "{}"
local SYMBOLS = ".,:;="
local DIGITS = "1234567890"
local QUOTES = "\"'`"
local VALID_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
local KEYWORDS = { "var", "let", "if", "else", "for", "while", "function" }

--[[-------------------------------------------------------------------------]]
--[[ TOKEN ]]
--[[-------------------------------------------------------------------------]]
function lang_Token(type, value, posLeft, posRight)
	return {
		type = type,
		value = value,

		pos = {
			posLeft,
			posRight or posLeft
		}
	}
end

--[[-------------------------------------------------------------------------]]
--[[ POSITION ]]
--[[-------------------------------------------------------------------------]]
function lang_Position(filename, index, line, column)
	return {
		filename = filename,
		index = index,
		line = line,
		column = column,

		advance = function(self, char, delta)
			local delta = delta or 1
			self.index = self.index + delta
			self.column = self.column + delta

			if char == "\n" then
				self.column = 1
				self.line = self.line + 1
			end

			return self
		end,

		clone = function(self)
			return lang_Position(self.filename, self.index, self.line, self.column)
		end
	}
end

--[[-------------------------------------------------------------------------]]
--[[ ERROR ]]
--[[-------------------------------------------------------------------------]]
function lang_Error(pos, details)
	return {
		pos = pos,
		details = details,

		asString = function(self)
			local filename = self.pos.filename
			local line = self.pos.line
			local column = self.pos.column
			local details = self.details

			return filename .. ":" .. line .. ":" .. column .. ": " .. details
		end
	}
end

--[[-------------------------------------------------------------------------]]
--[[ LEXER ]]
--[[-------------------------------------------------------------------------]]
function lang_Lexer(filename, code)
	local lexer = {
		filename = filename,
		code = code,
		pos = lang_Position(filename, 0, 1, 0),

		------------------------------------------------------------------

		-- Returns the current character the lexer at
		at = function(self)
			return string.sub(self.code, self.pos.index, self.pos.index)
		end,

		-- Advanced to the next character
		advance = function(self, delta)
			self.pos:advance(self:at(), delta)
		end,

		-- Returns if the lexer didn't get to the end of the file
		notEof = function(self)
			return self:at() ~= ""
		end,

		------------------------------------------------------------------

		-- Makes tokens from the code
		makeTokens = function(self)
			local tokens = {}

			while self:notEof() do
				local char = self:at()

				if str_find(WHITESPACE, char) then
				elseif str_find(OPERATORS, char) then
					table.insert(tokens, lang_Token("BinOp", char, self.pos:clone()))

				elseif str_find(PARENTHESES, char) then
					table.insert(tokens, lang_Token("Paren", char, self.pos:clone()))

				elseif str_find(BRACKETS, char) or str_find(CURLY_BRACKETS, char) then
					table.insert(tokens, lang_Token("Bracket", char, self.pos:clone()))

				elseif str_find(SYMBOLS, char) then
					table.insert(tokens, lang_Token("Symbol", char, self.pos:clone()))

				elseif str_find(DIGITS, char) then
					table.insert(tokens, self:makeNumber())

				elseif str_find(QUOTES, char) then
					table.insert(tokens, self:makeString())

				elseif str_find(VALID_CHARS, char) then
					table.insert(tokens, self:makeIdentifier())

				else
					local char = self:at()
					local pos = self.pos:clone()
					self:advance()

					return {}, lang_Error(pos, "Undefined character found '" .. char .. "'")
				end

				self:advance()
			end

			table.insert(tokens, lang_Token("Eof", nil, self.pos:clone()))

			return tokens, nil
		end,

		makeNumber = function(self)
			local numStr = ""
			local float = false
			local posLeft = self.pos:clone()

			while self:notEof() and str_find(DIGITS, self:at()) or self:at() == "." do
				local char = self:at()

				if char == "." then
					if float then break end
					numStr = numStr .. "."
					float = true
				else
					numStr = numStr .. char
				end

				self:advance()
			end

			-- Advance back so the lexer won't skip the character next to the number
			self:advance(-1)

			return lang_Token("Number", tonumber(numStr), posLeft, self.pos:clone())
		end,

		makeString = function(self)
			local str = ""
			local quote = self:at()
			local posLeft = self.pos:clone()

			self:advance()

			while self:notEof() and self:at() ~= quote do
				local char = self:at()
				str = str .. char
				self:advance()
			end

			return lang_Token("String", str, posLeft, self.pos:clone())
		end,

		makeIdentifier = function(self)
			local ident = ""
			local posLeft = self.pos:clone()

			while self:notEof() and ( str_find(VALID_CHARS, self:at()) or str_find(DIGITS, self:at()) ) do
				local char = self:at()
				ident = ident .. char
				self:advance()
			end

			-- Advance back so the lexer won't skip the character next to the identifier
			self:advance(-1)

			if table_includes(KEYWORDS, ident) then
				return lang_Token("Keyword", ident, posLeft, self.pos:clone())
			end

			return lang_Token("Ident", ident, posLeft, self.pos:clone())
		end
	}

	lexer:advance()

	return lexer
end

--[[-------------------------------------------------------------------------]]
--[[ NODES ]]
--[[-------------------------------------------------------------------------]]
function lang_Node(type, values, pos)
	local node = {
		type = type,
		pos = pos
	}

	for key, value in pairs(values) do
		if not node[key] then
			node[key] = value
		end
	end

	return node
end

function lang_Node_Identifier(name, pos)
	local node = lang_Node("Identifier", {name = name}, pos)
	return node
end

function lang_Node_NumericLiteral(value, pos)
	local node = lang_Node("NumericLiteral", {value = value}, pos)
	return node
end

function lang_Node_NullLiteral(pos)
	local node = lang_Node("NullLiteral", {}, pos)
	return node
end

function lang_Node_BooleanLiteral(value, pos)
	local node = lang_Node("BooleanLiteral", {value = value}, pos)
	return node
end

function lang_Node_UndefinedLiteral(pos)
	local node = lang_Node("UndefinedLiteral", {}, pos)
	return node
end

function lang_Node_PropertyLiteral(key, value, pos)
	local node = lang_Node("PropertyLiteral", {key = key, value = value}, pos)
	return node
end

function lang_Node_ObjectLiteral(properties, pos)
	local node = lang_Node("ObjectLiteral", {properties = properties}, pos)
	return node
end

function lang_Node_BinaryExpr(left, operator, right, pos)
	local node = lang_Node("BinaryExpr", {left = left, operator = operator, right = right}, pos)
	return node
end

function lang_Node_VarDeclaration(identifier, value, pos)
	local node = lang_Node("VarDeclaration", {identifier = identifier, value = value}, pos)

	if node.value == nil then
		node.value = lang_Node_UndefinedLiteral(pos)
	end

	return node
end

function lang_Node_VarAssignment(assigne, value, pos)
	local node = lang_Node("AssignmentExpr", {assigne = assigne, value = value}, pos)
	return node
end

--[[-------------------------------------------------------------------------]]
--[[ PARSER ]]
--[[-------------------------------------------------------------------------]]
function lang_Parser(tokens)
	return {
		tokens = tokens,
		error = nil,

		------------------------------------------------------------------

		at = function(self)
			return tokens[1]
		end,

		yum = function(self)
			local prev = self:at()
			table.remove(tokens, 1)
			return prev
		end,

		expectType = function(self, type, err)
			local prev = self:yum()

			if not prev or prev.type ~= type then
				self.error = lang_Error(prev.pos[1], err)
				return
			end

			return prev
		end,

		expectValue = function(self, value, err)
			local prev = self:yum()

			if not prev or prev.value ~= value then
				self.error = lang_Error(prev.pos[1], err)
				return
			end

			return prev
		end,

		expect = function(self, type, value, err)
			local prev = self:yum()

			if not prev or prev.type ~= type and prev.value ~= value then
				self.error = lang_Error(prev.pos[1], err)
				return
			end

			return prev
		end,

		notEof = function(self)
			return self.tokens[1].type ~= "Eof"
		end,

		------------------------------------------------------------------

		makeAST = function(self)
			local program = {
				type = "Program",
				body = {}
			}

			while self:notEof() do
				local value = self:parseStmt()
				if value then
					table.insert(program.body, value)
				end

				if self.error then
					return {}, self.error
				end
			end

			return program, self.error
		end,

		parseStmt = function(self)
			if self:at().type == "Keyword" then
				if self:at().value == "var" or self:at().value == "let" then
					return self:parseVarDeclaration()
				end
			else
				return self:parseExpr()
			end
		end,

		parseExpr = function(self)
			-- return self:parseAdditiveExpr()
			return self:parseAssignmentExpr()
		end,

		parsePrimaryExpr = function(self)
			local token = self:at()

			if token.type == "Ident" then
				self:yum()

				if token.value == "null" then
					return lang_Node_NullLiteral(token.pos)
				elseif token.value == "undefined" then
					return lang_Node_UndefinedLiteral(token.pos)
				elseif token.value == "true" or token.value == "false" then
					return lang_Node_BooleanLiteral(token.value, token.pos)
				end

				return lang_Node_Identifier(token.value, token.pos)

			elseif token.type == "Number" then
				self:yum()
				return lang_Node_NumericLiteral(token.value, token.pos)

			elseif token.type == "BinOp" then
				self:yum()
				return self:parseAdditiveExpr()

			elseif token.type == "Paren" then
				self:yum()
				local value = self:parseExpr()
				local token = self:at()
				self:expect("Paren", ")", lang_Error(token.pos[1]:clone(), "Expected ')', instead got '" .. token.value .. "'"))
				return value

			else
				self.error = lang_Error(token.pos[1]:clone(), "This AST node has not been set up: " .. token.type .. "; Yell at programmer to fix this!")
				return self:yum()
			end
		end,

		parseObjectExpr = function(self)
			if self:at().type ~= "Bracket" and self:at().value ~= "{" then
				return self:parseAdditiveExpr()
			end

			local leftBracket = self:yum()
			-- self:yum()
			local properties = {}

			while self:notEof() and self:at().type ~= "Bracket" and self:at().value ~= "}" do
				-- { key: val, key2: val }

				local key = self:expectType(
					"Ident",
					lang_Error(self:at().pos[1]:clone(), "Expected an identifier, instead got " .. self:at().type)
				)

				if not key then
					return
				end

				if self:at().type == "Symbol" and self:at().value == "," then
					self:yum()
					table.insert(properties,
						lang_Node_PropertyLiteral(
							key,
							lang_Node_UndefinedLiteral({ self:at().pos[1], self:at().pos[2] })
						)
					)
				elseif self:at().type == "Symbol" and self:at().value == ";" then
					table.insert(properties,
						lang_Node_PropertyLiteral(
							key,
							lang_Node_UndefinedLiteral({ self:at().pos[1], self:at().pos[2] })
						)
					)
				else
					self:expect(
						"Symbol", ":",
						lang_Error(self:at().pos[1], "Expected ':', instead got '" .. self:at().value .. "'")
					)

					local value = self:parseExpr()
					table.insert(properties, lang_Node_PropertyLiteral(key, value, {key.pos[1], value.pos[2]}))

					if self:at().type ~= "Bracket" and self:at().value ~= "}" then
						self:expect("Symbol", ",", lang_Error(
							self:at().pos[1], "Expected comma or a closing bracket following property")
						)
					end
				end

			end

			local rightBracket = self:expect(
				"Bracket", "}",
				lang_Error(self:at().pos[1]:clone(), "Expected '}', instead got '" .. tostring(self:at().value) .. "'")
			)

			if not rightBracket then
				return
			end

			return lang_Node_ObjectLiteral(properties, {leftBracket.pos[1], rightBracket[2]})
		end,

		parseAdditiveExpr = function(self)
			local left = self:parseMultiplicativeExpr()

			while self:at().value == "+" or self:at().value == "-" do
				local operator = self:yum().value
				local right = self:parseMultiplicativeExpr()
				left = lang_Node_BinaryExpr(left, operator, right, {left.pos[1], right.pos[2]})
			end

			return left
		end,

		parseMultiplicativeExpr = function(self)
			local left = self:parsePrimaryExpr()

			while self:at().value == "*" or self:at().value == "/" or self:at().value == "%" do
				local operator = self:yum().value
				local right = self:parsePrimaryExpr()
				left = lang_Node_BinaryExpr(left, operator, right, {left.pos[1], right.pos[2]})
			end

			return left
		end,

		parseVarDeclaration = function(self)
			local keyword = self:yum()
			local ident = self:expectType("Ident", "Expected an identifier after the let | var keyword")

			if not ident then
				return
			end

			if self:at().type == "Symbol" and self:at().value == ";" then
				self:yum()
				return lang_Node_VarDeclaration(ident, nil, {keyword.pos, ident.pos})
			end

			self:expect("Symbol", "=", lang_Error(self:at().pos[1]:clone(), "Expected an equals sign after '" .. ident.value .. "'"))

			local declaration = lang_Node_VarDeclaration(ident.value, self:parseExpr(), {keyword.pos[1], ident.pos[2]})

			self:expect("Symbol", ";", lang_Error(self:at().pos[1]:clone(), "Expected a semicolon at the end of the statement"))

			return declaration
		end,

		parseAssignmentExpr = function(self)
			local left = self:parseObjectExpr()

			if self:notEof() and self:at().type == "Symbol" and self:at().value == "=" then
				self:yum()
				local value = self:parseAssignmentExpr()
				return lang_Node_VarAssignment(left, value, {left.pos[1], value.pos[2]})
			end

			return left
		end
	}
end

--[[-------------------------------------------------------------------------]]
--[[ ENVIRONMENT ]]
--[[-------------------------------------------------------------------------]]
function lang_Environment(parent)
	return {
		parent = parent,
		variables = {},

		newVar = function(self, var, value)
			if self.variables[var] then
				return false
			end

			self.variables[var] = value
		end,

		setVar = function(self, var, value)
			if not self.variables[var] then
				return false
			end

			self.variables[var] = value
		end,

		lookupVar = function(self, var)
			if not self.variables[var] then
				return
			end

			-- for key, val in pairs(self.variables) do
				-- print("- '" .. key .. "'", tostring(val) .. ": " .. val.type, val.value)
			-- end

			return self.variables[var]
		end
	}
end

--[[-------------------------------------------------------------------------]]
--[[ VALUES ]]
--[[-------------------------------------------------------------------------]]
function lang_Value(type, values)
	local val = {
		type = type
	}

	if not values or values == {} then
		return val
	end

	for key, _val in pairs(values) do
		if not val[key] then
			val[key] = _val
		end
	end

	return val
end

function lang_Value_Number(value)
	return lang_Value("number", {value = value})
end

function lang_Value_Ident(name)
	return lang_Value("identifier", {name = name})
end

function lang_Value_Null()
	return lang_Value("null", {value = "null"})
end

function lang_Value_Undefined()
	return lang_Value("undefined", {value = "undefined"})
end

function lang_Value_Bool(value)
	return lang_Value("boolean", {value = value})
end

--[[-------------------------------------------------------------------------]]
--[[ EVALUATE/INTERPRETER ]]
--[[-------------------------------------------------------------------------]]
function lang_evaluate(node, env)
	if node.type == "NullLiteral" then
		return lang_Value_Null()

	elseif node.type == "UndefinedLiteral" then
		return lang_Value_Undefined()

	elseif node.type == "BooleanLiteral" then
		return lang_Value_Bool(node.value)

	elseif node.type == "Identifier" then
		-- return lang_Value_Ident(node.name)
		local var = env:lookupVar(node.name)

		if not var then
			return lang_Value_Undefined()
		end

		return var
		
	elseif node.type == "NumericLiteral" then
		return lang_Value_Number(node.value)

	elseif node.type == "BinaryExpr" then
		return lang_evaluate_binExpr(node, env)

	elseif node.type == "VarDeclaration" then
		return lang_evaluate_varDeclaration(node, env)

	elseif node.type == "AssignmentExpr" then
		return lang_evaluate_assignment(node, env)

	elseif node.type == "Program" then
		return lang_evaluate_program(node, env)

	else
		return {}, lang_Error(
			node.pos[1],
			"This AST node has not been setup for interpretation: " .. node.type .. "; Yell at programmer to fix this!"
		)
	end
end

function lang_evaluate_program(node, env)
	local lastEvaluated = lang_Value_Null()
	local err

	for _, stmt in pairs(node.body) do
		lastEvaluated, err = lang_evaluate(stmt, env)
	end

	return lastEvaluated, err
end

function lang_evaluate_binExpr(node, env)
	local left = lang_evaluate(node.left, env)
	local right = lang_evaluate(node.right, env)

	if left.type == "number" and right.type == "number" then
		return lang_evaluate_numericBinExpr(left, right, node.operator)
	end

	return lang_Value_Null()
end

function lang_evaluate_numericBinExpr(left, right, operator)
	local result = 0

	if operator == "+" then
		result = left.value + right.value
	elseif operator == "-" then
		result = left.value - right.value
	elseif operator == "*" then
		result = left.value * right.value
	elseif operator == "/" then
		result = left.value / right.value
	elseif operator == "%" then
		result = left.value % right.value
	end

	return lang_Value_Number(result)
end

function lang_evaluate_varDeclaration(node, env)
	local value = node.value
	local var = env:newVar(node.identifier, lang_evaluate(node.value, env))

	if var == false then
		return nil, lang_Error(node.pos[1][1], "Cannot redeclare a variable")
	end

	return env:lookupVar(node.identifier)
end

function lang_evaluate_assignment(node, env)
	if node.assigne.type ~= "Identifier" then
		return nil, lang_Error(node.pos[1][1], "Cannot assign constant value " .. node.assigne.type)
	end

	local varname = node.assigne.name

	if var == false then
		return nil, lang_Error(node.pos[1][1], "Tried to assign an undeclared variable")
	end

	env:setVar(node.assigne.name, lang_evaluate(node.value))
	return env:lookupVar(node.assigne.name)
end

--[[-------------------------------------------------------------------------]]
--[[ RUN ]]
--[[-------------------------------------------------------------------------]]
function lang_run(filename, code)
	print("\nMaking tokens...")
	local lexer = lang_Lexer(filename, code)
	local tokens, err = lexer:makeTokens()

	if err then
		print(err:asString())
		return
	end

	for _, token in pairs(tokens) do
		local type = token.type or "unknown"
		local value = token.value or "unknown"
		local line1 = token.pos[1].line or "unknown"
		local column1 = token.pos[1].column or "unknown"
		local line2 = token.pos[2].line or "unknown"
		local column2 = token.pos[2].column or "unknown"
		print(type, value, line1 .. ":" .. column1, line2 .. ":" .. column2)
	end

	print("\nParsing tokens...")
	local parser = lang_Parser(tokens)
	local ast, err = parser:makeAST()

	if err then
		print(err:asString())
		return
	end

	for _, node in pairs(ast.body) do
		print(_, node.type, node.value, node.name, node.left, node.operator, node.right, node.identifier, node.value)
	end

	print("\nInterpreting/evaluating AST...")
	local env = lang_Environment()
	env:newVar("lol", lang_Value_Number(10))
	local result, err = lang_evaluate(ast, env)
	print(result, err)

	if err then
		print(err:asString())
		return
	end

	for _, value in pairs(result) do
		print(_, value)
	end
	-- print(result)
end