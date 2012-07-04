local M = {}

-------------------------------------------------------------------------------
-- IConnectionHandler component that dispatches all signals
-------------------------------------------------------------------------------
local LuaConnectionHandler = co.Component { name = "qt.LuaConnectionHandler", provides = { handler = "qt.IConnectionHandler" } }
function LuaConnectionHandler.handler:onSignal( cookie, ... )
	local connection = self.connections[cookie]
 	assert( connection.sender and connection.closure, "LuaConnectionHandler: invalid closure for the emitted signal" )
	
	if connection.handlerInstance then
		-- handler instance was set, so closure belongs to a table
		assert( type( connection.closure ) == "string", "Handler closure name is invalid" )
		connection.handlerInstance[connection.closure]( connection.handlerInstance, connection.sender, ... )
	else
		connection.closure( connection.sender, ... )
	end
end

local connections = {}
local connectionHandler = ( LuaConnectionHandler{ connections = connections } ).handler

function M.connect( wrapper, signal, handlerClosureOrClosureName, handlerInstance )
	local cookie = M.system:connect( wrapper._obj, signal, connectionHandler )
	connections[cookie] = { sender = wrapper, closure = handlerClosureOrClosureName, handlerInstance = handlerInstance }
end

return M

