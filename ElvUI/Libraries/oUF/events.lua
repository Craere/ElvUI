local ns = oUF
local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck
local error = Private.error
local frame_metatable = Private.frame_metatable

-- Original event methods
local registerEvent = frame_metatable.__index.RegisterEvent
local unregisterEvent = frame_metatable.__index.UnregisterEvent

function Private.UpdateUnits(frame, unit, realUnit)

	return true
end

local function onEvent()
	if(this:IsVisible() or event == 'UNIT_COMBO_POINTS') then
		return this[event](this, event, arg1, arg2, arg3)
	end
end

local event_metatable = {
	__call = function(funcs, self, ...)
		for _, func in next, funcs do
			func(self, unpack(arg))
		end
	end,
}

--[[ Events: frame:RegisterEvent(event, func, unitless)
Used to register a frame for a game event and add an event handler. OnUpdate polled frames are prevented from
registering events.

* self     - frame that will be registered for the given event.
* event    - name of the event to register (string)
* func     - function that will be executed when the event fires. If a string is passed, then a function by that name
             must be defined on the frame. Multiple functions can be added for the same frame and event
             (string or function)
* unitless - indicates that the event does not fire for a specific unit, so the event arguments won't be
             matched to the frame unit(s). Events that do not start with UNIT_ or are not known to be unit events are
             automatically considered unitless (boolean)
--]]
function frame_metatable.__index:RegisterEvent(event, func)
	-- Block OnUpdate polled frames from registering events.
	-- UNIT_PORTRAIT_UPDATE and UNIT_MODEL_CHANGED which are used for
	-- portrait updates.
	if(self.__eventless and event ~= 'UNIT_PORTRAIT_UPDATE' and event ~= 'UNIT_MODEL_CHANGED') then return end

	argcheck(event, 2, 'string')

	if(type(func) == 'string' and type(self[func]) == 'function') then
		func = self[func]
	end

	local curev = self[event]
	local kind = type(curev)
	if(curev and func) then
		if(kind == 'function' and curev ~= func) then
			self[event] = setmetatable({curev, func}, event_metatable)
		elseif(kind == 'table') then
			for _, infunc in next, curev do
				if(infunc == func) then return end
			end

			table.insert(curev, func)
		end
	elseif(self:IsEventRegistered(event)) then
		return
	else
		if(type(func) == 'function') then
			self[event] = func
		elseif(not self[event]) then
			return error("Style [%s] attempted to register event [%s] on unit [%s] with a handler that doesn't exist.", self.style, event, self.unit or 'unknown')
		end

		if not self:GetScript('OnEvent') then
			self:SetScript('OnEvent', onEvent)
		end

		registerEvent(self, event)
		self.__registeredEvents[event] = true
	end
end

--[[ Events: frame:IsEventRegistered(event, func)
Used to determine if a game event is registered.

* self  - the frame registered for the event
* event - name of the registered event (string)
--]]
function frame_metatable.__index:IsEventRegistered(event)
	argcheck(event, 2, 'string')
	
	return self.__registeredEvents[event] and true or false
end

--[[ Events: frame:UnregisterEvent(event, func)
Used to remove a function from the event handler list for a game event.

* self  - the frame registered for the event
* event - name of the registered event (string)
* func  - function to be removed from the list of event handlers. If this is the only handler for the given event, then
          the frame will be unregistered for the event
--]]
function frame_metatable.__index:UnregisterEvent(event, func)
	argcheck(event, 2, 'string')

	local curev = self[event]
	if(type(curev) == 'table' and func) then
		for k, infunc in next, curev do
			if(infunc == func) then
				table.remove(curev, k)

				local n = getn(curev)
				if(n == 1) then
					local _, handler = next(curev)
					self[event] = handler
				elseif(n == 0) then
					-- This should not happen
					unregisterEvent(self, event)
					self.__registeredEvents[event] = nil
				end

				break
			end
		end
	elseif(curev == func) then
		self[event] = nil
		unregisterEvent(self, event)
		self.__registeredEvents[event] = nil
	end
end