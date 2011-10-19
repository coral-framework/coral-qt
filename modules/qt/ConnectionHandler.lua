local M = {}

-------------------------------------------------------------------------------
-- IConnectionHandler component that dispatches all signals
-------------------------------------------------------------------------------
local LuaConnectionHandler = co.Component { name = "qt.LuaConnectionHandler", provides = { handler = "qt.IConnectionHandler" } }
function LuaConnectionHandler.handler:onSignal( cookie, ... )
	local connection = self.connections[cookie]
 	assert( connection.sender and connection.closure, "LuaConnectionHandler: invalid closure for the emitted signal" )
	connection.closure( connection.sender, ... )
end

local connections = {}
local connectionHandler = ( LuaConnectionHandler{ connections = connections } ).handler

function M.connect( wrapper, signal, handlerClosure )
	local cookie = M.system:connect( wrapper._obj, signal, connectionHandler )
	connections[cookie] = { sender = wrapper, closure = handlerClosure }
end

return M

