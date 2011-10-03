local M = {}

-------------------------------------------------------------------------------
-- IEventHandler declaration and auxiliary structures
-------------------------------------------------------------------------------
-- Qt QEvent::Type enum mapping used to map event type ids to a fixed closure name
local eventTypes = {
	MouseButtonDblClick					= 4,
	MouseButtonPress					= 2,
	MouseButtonRelease					= 3,
	MouseMove							= 5,
	KeyPress							= 6,
	KeyRelease							= 7,
	Wheel								= 31,
	Close								= 19,
	Resize								= 14,
	Show								= 17,
	Hide								= 18
}

local eventNames = {
	-- closure name map
	onMouseDoubleClick					= true,
	onMousePress						= true,
	onMouseRelease						= true,
	onMouseMove							= true,
	onKeyPress							= true,
	onKeyRelease						= true,
	onWheel								= true,
	onClose								= true,
	onResize							= true,
	onShow								= true,
	onHide								= true,

	-- enum to name map
	[eventTypes.MouseButtonDblClick]	= "onMouseDoubleClick",
	[eventTypes.MouseButtonPress]		= "onMousePress",
	[eventTypes.MouseButtonRelease]		= "onMouseRelease",
	[eventTypes.MouseMove]				= "onMouseMove",
	[eventTypes.KeyPress]				= "onKeyPress",
	[eventTypes.KeyRelease]				= "onKeyRelease",
	[eventTypes.Wheel]					= "onWheel",
	[eventTypes.Close]					= "onClose",
	[eventTypes.Resize]					= "onResize",
	[eventTypes.Show]					= "onShow",
	[eventTypes.Hide]					= "onHide"
}

-- IEventHandler component that dispatches all events
local LuaEventHandler = co.Component { name = "qt.LuaEventHandler", provides = { handler = "qt.IEventHandler" } }
function LuaEventHandler.handler:onEvent( cookie, eventType, ... )
	local eventName = eventNames[eventType]
	if not eventName or not self.closures[cookie][eventName] then
		return false
	end
	-- dispatch the event to corresponding closure passing the source object
	return self.closures[cookie][eventName]( self.closures[cookie].source, ... ) == true
end

local eventHandlerClosures = {}
local eventHandler = ( LuaEventHandler{ closures = eventHandlerClosures } ).handler

function M.installEventHandler( wrapper, eventName, closure )
	-- checks whether the event name exists and closure is valid
	if type( closure ) ~= "function" or not eventNames[eventName] then
		return false
	end

	local cookie = M.system:installEventHandler( wrapper._obj, eventHandler )
	eventHandlerClosures[cookie] = eventHandlerClosures[cookie] or {}
	eventHandlerClosures[cookie][eventName] = closure
	eventHandlerClosures[cookie].source = wrapper
	return true
end

return M

