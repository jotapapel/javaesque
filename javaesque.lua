local gmt, smt, empty, javaesque = getmetatable, setmetatable, function() end, {}

local function string_parse(str, token)
	local t = {}
	for m in string.gmatch(str .. token, '(.-)' .. token) do table.insert(t, string.match(m, '^%s*(.-)%s*$')) end
	return t
end

local function catch_error(...)
	local args = {...}
	if ((#args == 2 and (type(args[1]) == 'nil' or args[1] == true)) or (#args == 3 and type(args[1]) ~= args[2])) then error(args[#args], 2) end 
	return args[1]
end


local function new_metatype(new_table, table_type, table_name)
	local hex, p, _ = tostring(new_table), string.find(tostring(new_table), ':')
	if (table_type == 'object') then gmt(new_table).__protected.id = string.sub(hex, p + 2) end
	gmt(new_table).__tostring = function(_) return gmt(new_table).__type .. string.sub(hex, p) end
	gmt(new_table).__weak = not(not(table_type == 'object') and table_name) and not(table_type == 'object')
	if (table_name or false) then
		_G[table_name] = new_table
		return _G[table_name]
	else
		return new_table
	end
end

-------------------------------------
-- The following functions allow table association.
-------------------------------------
function stash_index(t, k)
	local v
	for _, t in ipairs(gmt(t).__stash) do if t[k] then v = t[k] end end 
	return v
end
	
function stash_new()
	local function clone(var)
		local c = var
		if (type(var) == 'table') then
			c = {}
			for k, v in pairs(var) do c[clone(k)] = clone(v) end
			smt(c, clone(gmt(var)))
		end
		return c
	end
	
	return smt({}, {
		__stash = {};
		__index = stash_index,
		__add = function(self, other)
			table.insert(gmt(self).__stash, clone(other))
			return self
		end
	})
end

-------------------------------------
-- Find local variables when enums, interfaces and classes have weak definitions.
-------------------------------------
local function get_local_variable(level, name)
	local i = 1
	while true do
		local k, v = debug.getlocal(level, i)
		if (k) then
			if (k == name) then return v end
		else
			break
		end
		i = 1 + i
	end
	return nil
end

-------------------------------------
-- SWITCH is an statement that evaluates a variable, matching it's value to a case clause 
-- and then executing the function paired to such clause, if it exists.
-------------------------------------
javaesque.switch = smt({}, {
	__protected = {
		default = 0xdef404
	};
	__call = function(self, var)
		local default = self.default
		return smt({var}, {
			__call = function(self, cases)
				local item = (#self == 0) and empty or self[1]
				return (cases[item] or cases[default] or empty)(item)
			end
		})
	end,
	__index = function(t, k) return gmt(t).__protected[k] end,
	__newindex = empty
})

-------------------------------------
-- An ENUM is a set of defined constants.
-- Every variable of the enum must be a string.
-------------------------------------
javaesque.enum = smt({}, {
	__call = function(self, name)
		local enum = smt({}, {
			__type = 'enum',
			__protected = {};
			__call = function(self, prototype)
				local mt = gmt(self).__protected
				for _, v in next, prototype do
					catch_error(v, 'string', 'Enum variable definition must be a string.')
					rawset(mt, v, v)
				end
				return self
			end,
			__index = function(t, k) return gmt(t).__protected[k] end,
			__newindex = empty
		})	
		return new_metatype(enum, 'enum', name)
	end,
	__newindex = empty
})

-------------------------------------
-- An INTERFACE is a blueprint of variables wich can be later implemented by classes.
-- You can EXTEND interfaces just as you would extend classes.
-- You can declare interfaces as STATIC on definition, this means that when implemented,
-- all variables of the interface will be registered as class variables.
-------------------------------------
javaesque.interface = smt({}, {
	__call = function(self, name)
		local interface = smt({}, {
			__type = 'interface',
			__defined = false,
			__static = false,
			__ptype = stash_new(),
			__protected = {
				extends = function(self, names)
					for _, name in ipairs(string_parse(names, ',')) do
						local intfc = catch_error(_G[name] or get_local_variable(3, name), 'Interface "' .. name .. '" not found.')
						gmt(self).__ptype = gmt(self).__ptype + gmt(intfc).__ptype
					end
					return self
				end,
				static = function(self, prototype)
					return self(prototype, true)
				end
			};
			__call = function(self, prototype, static)
				local mt = gmt(self)
				catch_error(prototype, 'table', 'Interface "' .. tostring(mt.__name) .. '" definition must be table.')
				mt.__static, mt.__defined, mt.__ptype = static or false, true, mt.__ptype + prototype
				return self
			end,
			__index = function(t, k) return not(gmt(t).__defined) and (gmt(t).__protected[k] or gmt(t).__ptype[k]) end,
			__newindex = function(t, k, v) if stash_index(gmt(t).__ptype, k) then rawset(gmt(t).__ptype, k, v) end end
		})
		return new_metatype(interface, 'interface', name)
	end,
	__newindex = empty
})

-------------------------------------
-- A CLASS is an object constructor that contains a set of variables that will be passed on to objects. 
-- On definition a class can define static variables (or class variables) or object variables.
-- Object variables are defined just like any other variable on a regular table 'key = value'.
-- Static variables are defined using brackets and a special keyword '[static.key] = value'.
-- Classes can EXTEND other classes and IMPLEMENT interfaces.
-- You can declare a class as FINAL which means that other classes can't extend it.
-------------------------------------
javaesque.class = smt({}, {
	__call = function(self, name)
		local class = smt({}, {
			__type = 'class',
			__defined = false,
			__final = false,
			__ptype = stash_new(),
			__static = stash_new(),
			__ctor = function() end,
			__protected = {
				implements = function(self, names)
					for _, name in ipairs(string_parse(names, ',')) do
						local intfc = catch_error(_G[name] or get_local_variable(3, name), 'Interface "' .. name .. '" not found.')
						local k = gmt(intfc).__static and '__static' or '__ptype'
						gmt(self)[k] = gmt(self)[k] + gmt(intfc).__ptype
					end
					return self
				end,
				extends = function(self, name)
					local superclass = catch_error(_G[name] or get_local_variable(3, name), 'Class "' .. name .. '" not found.')
					local mt, supermt = gmt(self), gmt(superclass)
					catch_error((supermt.__final == true), 'Cannot extend class "' .. name .. '", class is final.')
					mt.__protected.super, mt.__ctor = superclass, gmt(superclass).__ctor
					mt.__ptype, mt.__static = mt.__ptype + supermt.__ptype, mt.__static + supermt.__static
					return self
				end,
				final = function(self, prototype)
					return self(prototype, true)
				end
			};
			__call = function(self, ...)
				local mt = gmt(self)
				if (mt.__defined) then 
					local obj = smt({}, {
						__type = 'object',
						__protected = {
							class = self,
							instanceof = function(t, class) return (type(class) == 'table') and (t.class == class) or ((type(c) == 'string') and (gmt(t.class).__name == class)) end,
						};
						__index = function(t, k) return gmt(t).__protected[k] or stash_index(gmt(self).__ptype, k) end,
						__newindex = function(t, k, v) if not((gmt(t).__protected)[k]) then rawset(t, k, v) end end
					})
					if obj.class.super then super = function(...) gmt(obj.class.super).__ctor(obj, ...) end end
					mt.__ctor(obj, ...)
					super = nil
					return new_metatype(obj, 'object')
				else
					catch_error((#{...} == 0), 'Class definition must end with {}.')
					local static, ptype, final = {}, ...
					for k, v in pairs(ptype) do
						switch(string.sub(k, 1, 11)) {
							['constructor'] = function()
								catch_error(ptype.constructor, 'function', 'Class "' .. tostring(mt.__name) .. '" constructor must be a function.')
								mt.__ctor, ptype.constructor = ptype.constructor, nil
							end,
							['*[(STATIC)]'] = function()
								static[string.sub(k, 12)], ptype[k] = v, nil
							end
						}
					end
					mt.__final, mt.__defined, mt.__ptype, mt.__static = final or false, true, mt.__ptype + ptype, mt.__static + static
					return self
				end
			end,
			__index = function(t, k) return ((k == 'super') or not(gmt(t).__defined)) and gmt(t).__protected[k] or gmt(t).__static[k] end,
			__newindex = function(t, k, v) if stash_index(gmt(t).__static, k) then rawset(t, k, v) end end
		})
		return new_metatype(class, 'class', name)
	end,
	__newindex = empty
})

-------------------------------------
-- Special keyword used as a way of adding static variables on class definition.
-------------------------------------
javaesque.static = smt({}, {
	__index = function(t, k) return '*[(STATIC)]' .. tostring(k) end,
	__newindex = empty
})

-------------------------------------
-- Special functions to catch error in variable types, existance and general statement testing.
-------------------------------------
javaesque.catch_error = catch_error

-------------------------------------
-- New implementation of the "require" function.
-- When the string ends with *, it loads all the files in the directory.
-------------------------------------
javaesque.import = function(n)
	if (string.sub(n, -1) == '*') then
		local dir = string.gsub(string.sub(n, 1, -2), '%.', '/')
		for _, fname in ipairs(love.filesystem.getDirectoryItems(dir)) do
			if (love.filesystem.getInfo(dir .. fname, 'file') and string.sub(fname, -3) == 'lua') then require(dir .. string.sub(fname, 1, -5)) end
		end
	else
		for _, fname in ipairs(string_parse(n, ',')) do 
			((string.sub(fname, -1) == '*') and import or require)(fname)
		end
	end
end

-------------------------------------
-- Add javaesque tables to global environment.
-------------------------------------
smt(_G, {
	__index = function(t, k) return javaesque[k] end,
	__newindex = function(t, k, v) if not((javaesque)[k]) and not(gmt(v) and gmt(v).__weak) then rawset(t, k, v) end end
})