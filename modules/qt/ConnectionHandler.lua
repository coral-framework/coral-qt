local M = {}

-------------------------------------------------------------------------------
-- IConnectionHandler component that dispatches all signals
-------------------------------------------------------------------------------
local LuaConnectionHandler = co.Component { name = "qt.LuaConnectionHandler", provides = { handler = "qt.IConnectionHandler" } }
function LuaConnectionHandler.handler:onSignal( cookie, ... )
	local closure = assert( self.closures[cookie], "LuaConnectionHandler: invalid closure for the emitted signal" )
	closure( ... )
end

local connectionHandlerClosures = {}
local connectionHandler = ( LuaConnectionHandler{ closures = connectionHandlerClosures } ).handler

function M.connect( wrapper, signal, handlerClosure )
	local cookie = M.system:connect( wrapper._obj, signal, connectionHandler )
	connectionHandlerClosures[cookie] = handlerClosure
end

return M

