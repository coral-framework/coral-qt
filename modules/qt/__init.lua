local path = require "path"

local M = {}

-- for now we're manually registering the qt.ISystem service here
co.system.services:addServiceImplementation( co.Type "qt.ISystem", "qt.System" )

local system = co.getService( "qt.ISystem" )

-------------------------------------------------------------------------------
-- IConnectionHandler component that dispatches all signals
-------------------------------------------------------------------------------
local LuaConnectionHandler = co.Component { name = "qt.LuaConnectionHandler", provides = { handler = "qt.IConnectionHandler" } }
function LuaConnectionHandler.handler:onSignal( cookie, ... )
	local closure = assert( self.closures[cookie], "LuaConnectionHandler: invalid closure for the emitted signal" )
	closure( ... )
end

local handlerClosures = {}
local connectionHandler = ( LuaConnectionHandler{ closures = handlerClosures } ).handler

-------------------------------------------------------------------------------
-- ObjectWrapper
-------------------------------------------------------------------------------
local MT = {}

local function ObjectWrapper( object )
	return setmetatable( { _obj = object }, MT )
end

local function connect( wrapper, signal, handlerClosure )
	local cookie = system:connect( wrapper._obj, signal, connectionHandler )
	handlerClosures[cookie] = handlerClosure
end

local function invoke( wrapper, name, a1, a2, a3, a4, a5, a6, a7 )
	return wrapper._obj:invoke( name, a1, a2, a3, a4, a5, a6, a7 )
end

function MT.__index( wrapper, name )
	if name == "connect" then
		return connect
	elseif name == "invoke" then
		return invoke
	end

	local v = wrapper._obj:getPropertyOrChild( name )

	-- assume that all userdata are instances of qt.Object
	if type( v ) == "userdata" then
		v = ObjectWrapper( v )
	end

	return v
end

function MT.__newindex( wrapper, name, value )
	wrapper._obj:setProperty( name, value )
end

-------------------------------------------------------------------------------
-- Export AbstractItemModel flags
-------------------------------------------------------------------------------
M.NoItemFlags			= 0
M.ItemIsSelectable		= 1
M.ItemIsEditable		= 2
M.ItemIsDragEnabled		= 4
M.ItemIsDropEnabled		= 8
M.ItemIsUserCheckable	= 16
M.ItemIsEnabled			= 32
M.ItemIsTristate		= 64

-------------------------------------------------------------------------------
-- Export Module
-------------------------------------------------------------------------------
M.app = ObjectWrapper( system.app )

function M.loadUi( uiFile )
	return ObjectWrapper( system:loadUi( uiFile ) )
end

function M.getExistingDirectory( parent, caption, initialDir )
	return system:getExistingDirectory( parent._obj, caption, initialDir )
end

function M.setSearchPaths( prefix, paths )
	return system:setSearchPaths( prefix, paths )
end

function M.exec()
	return system:exec()
end

function M.processEvents()
	return system:processEvents()
end

function M.assignModelToView( view, model )
	return system:assignModelToView( view._obj, model )
end

function M.quit()
	return system:quit()
end

return M
