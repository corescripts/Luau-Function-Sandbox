--!native
--!optimize 2

SandboxSettings = {
	Logging = {
		Callback = print, -- Set this value to a function which will take a string as the first argument to log stuff such as function calls, property changes and etc. Default: print
		StringLengthLimit = 1000, -- Will truncate a string if the length of a string being logged is more than the specified amount in this setting. Useful for preventing crashes!
		
		LogInstancePropertyIndex = true, -- Logs whenever the sandboxed function tries to get the value of a property in an Instance, for example: trying to get the value of the property game.Capabilities will log "[game] Attempt to GET property .Capabilities"
		LogInstancePropertyNewIndex = true, -- Logs whenever the sandboxed function tries to set the value of a property in an Instance, for example: trying to do this `game.Capabilities = 0` will log "[game] Attempt to SET property .Capabilities"
		LogInstancePropertyNewIndexValue = true, -- Logs whenever the sandboxed function tries to set the value of a property in an Instance but includes the value that the property is set to, for example: trying to do this `game.Capabilities = 0` will log "[game] Attempt to SET property .Capabilities to 0"
		LogInstanceFunctionCall = true, -- Logs whenever the sandboxed function tries to call the function of an Instance, for example: trying to do this `game:GetService("StudioService")` will log "[game] Attempt to CALL function GetService (CALL ARGUMENT LOGGING DISABLED)"
		LogInstanceFunctionCallArguments = true, -- Logs whenever the sandboxed function tries to call the function of an Instance but includes the arguments passed into the function, for example: trying to do this `game:GetService("StudioService")` will log "[game] Attempt to CALL function GetService with arguments: 'StudioService' (Argument Type: STRING)"
		LogInstanceChildrenIndex = true, -- Logs whenever the sandboxed function tries to get its children, for example: trying to get the .ReplicatedStorage child of game `game.ReplicatedStorage` will print "[game] Attempt to GET child ReplicatedStorage"
		
		LogGlobalFunctionCall = true, -- Logs whenever the sandboxed function tries to call a global function, for example: trying to `printidentity()` will log the fact that it's being called.
		LogGlobalFunctionCallArguments = true, -- Logs whenever the sandboxed function tries to call a global function but includes the argumetns passed into the function, for example: trying to `printidentity("sd")` will log the fact that it's being called, and its arguments, which in this case, "sd".
	},
	Excluding = {
		ExcludedGlobalFunctions = {print}, -- A list of global functions which you want to exclude from being logged.
	},
	Hooking = {
		Enabled = true, -- Set this to true if you wish to hook the functions you listed in the table below, and false if not.
		HookedFunctions = { -- A list of functions that will be hooked. This will literally block the original functions from being called, and call your own function instead. Please keep note that this works by intercepting indexes to the function and checks if its memory address matches one of the functions listed in this dictionary, and this may not be a reliable approach.
			[game:GetService("HttpRbxApiService").GetAsync] = function()
				return error("")
			end,
			[game:GetService("HttpRbxApiService").GetAsyncFullUrl] = function()
				return error("")
			end,
		}
	},
	FunctionEnvironment = {}, -- Replace this table with a table full of your custom global functions. This is useful if you have a custom environment with your own custom functions, and you want to log calls to those functions. One example usage is for Roblox executors which have their own custom functions also knwon as the Unified Naming Convention functions. For executors, Do Environment = getgenv()
}

GeneralPurposeString = "MysqlBooleansLuaWebServiceInvokeServerFireRobloxEnvironmentBitdancerJumpInBase" -- A random string that you should not touch.

local ProtectedIndex = function(Table: {}, Key: string): any
	if Table == nil then
		return false
	end

	local Success = pcall(function()
		return Table[Key]
	end)

	if Success then
		return true
	else
		return false
	end
end

local StringLengthLimit = SandboxSettings.Logging.StringLengthLimit -- Optimization purposes.
local TruncateString = function(String: string)
	if #String > StringLengthLimit then
		String = String:sub(1, StringLengthLimit) .. " *TRUNCATED*"
	end
	
	return String
end

local ArgumentHandler = function(...)
	if ... == nil then
		return nil
	end

	local Table = {...}

	for Name, Value in pairs(Table) do
		if typeof(Value) == "userdata" then
			Table[Name] = Value[GeneralPurposeString]()
		elseif typeof(Value) == "table" then
			for Name2, Value2 in pairs(Value) do
				if typeof(Value2) == "userdata" then
					Value[Name2] = Value2[GeneralPurposeString]()
				end
			end
		end
	end

	return unpack(Table)
end

local ResponseHandler = function(Cloner, ...)
	if ... == nil then
		return nil
	end

	local Table = {...}

	for Name, Value in pairs(Table) do
		if typeof(Value) == "Instance" then
			Table[Name] = Cloner(Value)
		elseif typeof(Value) == "table" then
			for Name2, Value2 in pairs(Value) do
				if typeof(Value2) == "Instance" then
					Value[Name2] = Cloner(Value)
				end
			end
		end
	end

	return unpack(Table)
end

function Sandbox(func, ...)
	assert(typeof(func) == "function", "Expected function to be passed as the first argument to Sandbox.")
	assert(debug.info(func, "s") ~= "[C]", "Expected Lua function passed as the first argument, not C.")
	
	local OriginalFunction = func
	local Callback = SandboxSettings.Logging.Callback
	local CallArgs = {...}
	local FunctionEnvironmentOverride = {
		coroutine = coroutine,
		debug = debug,
		math = math,
		os = os,
		string = string,
		table = table,
		utf8 = utf8,
		bit32 = bit32,
		task = task,
		assert = assert,
		collectgarbage = collectgarbage,
		error = error,
		getmetatable = getmetatable,
		ipairs = ipairs,
		newproxy = newproxy,
		next = next,
		pairs = pairs,
		pcall = pcall,
		printidentity = printidentity,
		print = print,
		rawequal = rawequal,
		rawget = rawget,
		rawset = rawset,
		select = select,
		setmetatable = setmetatable,
		tonumber = tonumber,
		tostring = tostring,
		type = type,
		unpack = unpack,
		xpcall = xpcall,
		warn = warn,
		gcinfo = gcinfo,
		_G = _G,
		_VERSION = _VERSION,
		settings = settings,
		time = time,
		typeof = typeof,
		UserSettings = UserSettings,
		require = require,
		workspace = workspace,
		shared = shared,
		delay = task.delay,
		spawn = task.defer,
		wait = task.wait,
		elapsedTime = os.clock,
		stats = stats,
		tick = tick,
		Axes = Axes,
		BrickColor = BrickColor,
		CatalogSearchParams = CatalogSearchParams,
		CFrame = CFrame,
		Color3 = Color3,
		ColorSequence = ColorSequence,
		ColorSequenceKeypoint = ColorSequenceKeypoint,
		DateTime = DateTime,
		DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo,
		Enum = Enum,
		Faces = Faces,
		FloatCurveKey = FloatCurveKey,
		Instance = Instance,
		NumberRange = NumberRange,
		NumberSequence = NumberSequence,
		NumberSequenceKeypoint = NumberSequenceKeypoint,
		OverlapParams = OverlapParams,
		PathWaypoint = PathWaypoint,
		PhysicalProperties = PhysicalProperties,
		Random = Random,
		Ray = Ray,
		RaycastParams = RaycastParams,
		Rect = Rect,
		Region3 = Region3,
		Region3int16 = Region3int16,
		TweenInfo = TweenInfo,
		UDim = UDim,
		UDim2 = UDim2,
		Vector2 = Vector2,
		Vector2int16 = Vector2int16,
		Vector3 = Vector3,
		Vector3int16 = Vector3int16,
	}
	
	if getgenv ~= nil then -- Support for Roblox executors
		if typeof(getgenv) == "function" then
			local Environment = getgenv()

			if typeof(Environment) == "table" then
				for Name, Value in pairs(Environment) do
					if typeof(Value) == "table" or typeof(Value) == "function" then
						if FunctionEnvironmentOverride[Name] == nil then
							FunctionEnvironmentOverride[Name] = Value
						end
					end
				end
			end
		end
	end
	
	for Name, Function in pairs(SandboxSettings.FunctionEnvironment) do
		if Name == 1 then
			return error("Expected dictionary to be passed in FunctionEnvironment, not standard table.")
		end
		
		FunctionEnvironmentOverride[Name] = Function
	end
	
	for Name, Table in pairs(FunctionEnvironmentOverride) do
		if typeof(Table) == "table" then
			FunctionEnvironmentOverride[Name] = table.clone(Table)
		end
	end
	
	CloneInstance = function(Object: Instance) -- NO LOCAL FUCNTION
		if Object == nil then
			return nil
		end
		
		local ObjectName = tostring(Object) -- For optimization, instead of repeatedly calling the tostring function, we are going to save it in RAM so it will just jump to the memory address of where this value is stored instead of performing a Lua function call.
		local Proxy = newproxy(true)
		local MT = getmetatable(Proxy)
		
		MT.__type = "Instance"
		MT.__metatable = "No."
		
		MT.__tostring = function()
			return ObjectName
		end
		
		function MT:__index(Key) -- Alternative to __namecall due to not being able to get the namecall method in pure Luau.
			if ProtectedIndex(Object, Key) then
				local InQuestion = Object[Key]
				local InQuestionType = typeof(InQuestion)
				
				if InQuestionType ~= "function" then
					if InQuestionType ~= "Instance" then
						if SandboxSettings.Logging.LogInstancePropertyIndex then
							Callback("[" .. ObjectName .. "] Attempt to GET property ." .. Key)
						end

						return InQuestion
					else
						if SandboxSettings.Logging.LogInstanceChildrenIndex then
							Callback("[" .. ObjectName .. "] Attempt to GET child " .. Key)
						end

						return CloneInstance(InQuestion)
					end
				else
					return function(Self, ...)
						local temp = typeof(Self)
						
						if SandboxSettings.Logging.LogInstanceFunctionCall then
							local Arguments = {...}
							local ArgumentsStr = ""
							
							for _, Arg in pairs(Arguments) do
								ArgumentsStr = ArgumentsStr .. TruncateString(tostring(Arg)) .. " (Argument Type: " .. tostring(typeof(Arg)) .. "), "
							end
							
							if SandboxSettings.Logging.LogInstanceFunctionCallArguments then
								Callback("[" .. ObjectName .. "] Attempt to CALL function " .. Key .. " with arguments: " .. ArgumentsStr)
							else
								Callback("[" .. ObjectName .. "] Attempt to CALL function " .. Key .. " (CALL ARGUMENT LOGGING DISABLED)")
							end
							
							ArgumentsStr = nil
							Arguments = nil
						end
						
						if SandboxSettings.Hooking.Enabled then
							if SandboxSettings.Hooking.HookedFunctions[InQuestion] ~= nil then
								local Hook = SandboxSettings.Hooking.HookedFunctions[InQuestion]

								return ResponseHandler(CloneInstance, Hook(ArgumentHandler(...)))
							end
						end
						
						if temp == "userdata" or temp == "Instance" then
							temp = nil
							
							return ResponseHandler(CloneInstance, InQuestion(Object, ArgumentHandler(...)))
						else
							temp = nil
							
							return ResponseHandler(CloneInstance, InQuestion(ArgumentHandler(...)))
						end
					end
				end
			else
				if Key == GeneralPurposeString then
					return function()
						return Object
					end
				end
				
				return error(Key .. ' is not a valid member of ' .. tostring(typeof(Object)) .. ' "' .. ObjectName .. '"')
			end
		end
		
		function MT:__newindex(Key, Value)
			if ProtectedIndex(Object, Key) then
				if SandboxSettings.Logging.LogInstancePropertyNewIndex then
					if SandboxSettings.Logging.LogInstancePropertyNewIndexValue then
						Callback("[" .. ObjectName .. "] Attempt to SET property ." .. Key .. " to " .. TruncateString(tostring(Value)))
					else
						Callback("[" .. ObjectName .. "] Attempt to SET property ." .. Key .. " (PROPERTY SET VALUE LOGGING DISABLED)")
					end
				end
				
				if typeof(Value) == "userdata" then
					Value = Value[GeneralPurposeString]()
				end
				
				Object[Key] = Value
			else
				return error(Key .. ' is not a valid member of ' .. tostring(typeof(Object)) .. ' "' .. ObjectName .. '"')
			end
		end
		
		return Proxy
	end
	
	CloneDataModel = function(DataModel: DataModel) -- NO LOCAL FUCNTION
		SandboxSettings.Hooking.HookedFunctions[game.GetService] = function(ClassName: string)
			return CloneInstance(game:GetService(ClassName))
		end
		
		local ObjectName = tostring(DataModel) -- For optimization, instead of repeatedly calling the tostring function, we are going to save it in RAM so it will just jump to the memory address of where this value is stored instead of performing a Lua function call.
		local Proxy = newproxy(true)
		local MT = getmetatable(Proxy)

		MT.__type = "Instance"
		MT.__metatable = "No."

		MT.__tostring = function()
			return ObjectName
		end

		function MT:__index(Key) -- Alternative to __namecall due to not being able to get the namecall method in pure Luau.
			if ProtectedIndex(DataModel, Key) then
				local InQuestion = DataModel[Key]
				local InQuestionType = typeof(InQuestion)

				if InQuestionType ~= "function" then
					if InQuestionType ~= "Instance" then
						if SandboxSettings.Logging.LogInstancePropertyIndex then
							Callback("[game] Attempt to GET property ." .. Key)
						end

						return InQuestion
					else
						if SandboxSettings.Logging.LogInstanceChildrenIndex then
							Callback("[game] Attempt to GET child " .. Key)
						end

						return CloneInstance(InQuestion)
					end
				else
					return function(Self, ...)
						local temp = typeof(Self)

						if SandboxSettings.Logging.LogInstanceFunctionCall then
							local Arguments = {...}
							local ArgumentsStr = ""

							for _, Arg in pairs(Arguments) do
								ArgumentsStr = ArgumentsStr .. TruncateString(tostring(Arg)) .. " (Argument Type: " .. tostring(typeof(Arg)) .. "), "
							end

							if SandboxSettings.Logging.LogInstanceFunctionCallArguments then
								Callback("[game] Attempt to CALL function " .. Key .. " with arguments: " .. ArgumentsStr)
							else
								Callback("[game] Attempt to CALL function " .. Key .. " (CALL ARGUMENT LOGGING DISABLED)")
							end

							ArgumentsStr = nil
							Arguments = nil
						end
						
						if SandboxSettings.Hooking.Enabled then
							if SandboxSettings.Hooking.HookedFunctions[InQuestion] ~= nil then
								local Hook = SandboxSettings.Hooking.HookedFunctions[InQuestion]

								return ResponseHandler(CloneInstance, Hook(ArgumentHandler(...)))
							end
						end

						if temp == "userdata" or temp == "Instance" then
							temp = nil

							return ResponseHandler(CloneInstance, InQuestion(DataModel, ArgumentHandler(...)))
						else
							temp = nil

							return ResponseHandler(CloneInstance, InQuestion(ArgumentHandler(...)))
						end
					end
				end
			else
				if Key == GeneralPurposeString then
					return function()
						return DataModel
					end
				end

				return error(Key .. ' is not a valid member of ' .. tostring(typeof(DataModel)) .. ' "' .. ObjectName .. '"')
			end
		end

		function MT:__newindex(Key, Value)
			if ProtectedIndex(DataModel, Key) then
				if SandboxSettings.Logging.LogInstancePropertyNewIndex then
					if SandboxSettings.Logging.LogInstancePropertyNewIndexValue then
						Callback("[game] Attempt to SET property ." .. Key .. " to " .. TruncateString(tostring(Value)))
					else
						Callback("[game] Attempt to SET property ." .. Key .. " (PROPERTY SET VALUE LOGGING DISABLED)")
					end
				end
				
				if typeof(Value) == "userdata" then
					Value = Value[GeneralPurposeString]()
				end

				DataModel[Key] = Value
			else
				return error(Key .. ' is not a valid member of ' .. tostring(typeof(DataModel)) .. ' "' .. ObjectName .. '"')
			end
		end

		return Proxy
	end
	
	FunctionEnvironmentOverride.game = CloneDataModel(game)
	
	FunctionEnvironmentOverride.typeof = function(...)
		local Type = typeof(...)
		
		if Type == "userdata" then
			return "Instance"
		else
			return Type
		end
	end
	
	FunctionEnvironmentOverride.getfenv = getfenv
	
	FunctionEnvironmentOverride.setfenv = setfenv
	
	FunctionEnvironmentOverride.type = FunctionEnvironmentOverride.typeof
	
	FunctionEnvironmentOverride.Instance = {
		fromExisting = function(object: Instance, OptionalParent): Instance
			local optionalParent = nil

			if typeof(OptionalParent) == "userdata" then
				optionalParent = OptionalParent[GeneralPurposeString]()
			end

			if typeof(object) == "userdata" then
				object = object[GeneralPurposeString]()
			end

			return CloneInstance(Instance.fromExisting(object, optionalParent))
		end,
		new = function(object: string, OptionalParent): Instance
			local optionalParent = nil

			if typeof(OptionalParent) == "userdata" then
				optionalParent = OptionalParent[GeneralPurposeString]()
			end

			return CloneInstance(Instance.new(object, optionalParent))
		end
	}
	
	if SandboxSettings.Logging.LogGlobalFunctionCall then
		for Name, Value in pairs(FunctionEnvironmentOverride) do
			if typeof(Value) == "function" then
				FunctionEnvironmentOverride[Name] = function(...)
					if table.find(SandboxSettings.Excluding.ExcludedGlobalFunctions, Value) ~= nil then
						return ResponseHandler(CloneInstance, Value(ArgumentHandler(...))) -- no interception is needed, its an excluded func
					end

					if SandboxSettings.Logging.LogGlobalFunctionCallArguments then
						if ... ~= nil then
							local Arguments = {...}
							local ArgumentsStr = ""

							for _, Arg in pairs(Arguments) do
								ArgumentsStr = ArgumentsStr .. TruncateString(tostring(Arg)) .. " (Argument Type: " .. tostring(typeof(Arg)) .. "), "
							end

							Callback("[GLOBAL] Attempt to CALL function " .. Name .. " with arguments: " .. ArgumentsStr)
						else
							Callback("[GLOBAL] Attempt to CALL function " .. Name .. " with no args.")
						end
					else
						Callback("[GLOBAL] Attempt to CALL function " .. Name .. ".")
					end

					return ResponseHandler(CloneInstance, Value(ArgumentHandler(...)))
				end
			elseif typeof(Value) == "table" then
				for Name2, Func in pairs(Value) do
					if typeof(Func) == "table" then
						-- No.
					elseif typeof(Func) == "function" then
						Value[Name2] = function(...)
							if table.find(SandboxSettings.Excluding.ExcludedGlobalFunctions, Func) ~= nil then
								return ResponseHandler(CloneInstance, Func(ArgumentHandler(...))) -- no interception is needed, its an excluded func
							end

							if SandboxSettings.Logging.LogGlobalFunctionCallArguments then
								if ... ~= nil then
									local Arguments = {...}
									local ArgumentsStr = ""

									for _, Arg in pairs(Arguments) do
										ArgumentsStr = ArgumentsStr .. TruncateString(tostring(Arg)) .. " (Argument Type: " .. tostring(typeof(Arg)) .. "), "
									end

									Callback("[GLOBAL] Attempt to CALL function " .. Name .. "." .. Name2 .. " with arguments: " .. ArgumentsStr)
								else
									Callback("[GLOBAL] Attempt to CALL function " .. Name .. "." .. Name2 .. " with no args.")
								end
							else
								Callback("[GLOBAL] Attempt to CALL function " .. Name .. "." .. Name2 .. ".")
							end

							return ResponseHandler(CloneInstance, Func(ArgumentHandler(...)))
						end
					end
				end
			end
		end
	end
	
	setfenv(OriginalFunction, FunctionEnvironmentOverride)
	
	if CallArgs[1] ~= nil then
		func(unpack(CallArgs))
	else
		func()
	end
end

return Sandbox
