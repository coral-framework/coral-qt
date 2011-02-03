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
-- Lua constructors for supported Qt types
-------------------------------------------------------------------------------
-- Constructs a qt icon instance using qt.Variant
function M.Icon( filename )
	local variant = co.new( "qt.Variant" )
	variant:setIcon( filename )
	return variant
end

-- Constructs a qt color instance using qt.Variant
function M.Color( r, g, b, a )
	local variant = co.new( "qt.Variant" )
	variant:setColor( r, g, b, a or 255 )
	return variant
end

-- Constructs a qt brush instance using qt.Variant
function M.Brush( r, g, b, a, style )
	local variant = co.new( "qt.Variant" )
	variant:setBrush( r, g, b, a or 1, style or M.SolidPattern )
	return variant
end

-- Constructs a qt size instance using qt.Variant
function M.Size( width, height )
	local variant = co.new( "qt.Variant" )
	variant:setSize( width or -1, height or -1 )
	return variant
end

-- Constructs a qt font instance using qt.Variant
function M.Font( family, pointSize, weight, italic )
	local variant = co.new( "qt.Variant" )
	variant:setFont( family, pointSize or -1, weight or -1, italic or false )
	return variant
end

-------------------------------------------------------------------------------
-- Constructor for qt.Menu using qt.newInstanceOf() of ISystem
-------------------------------------------------------------------------------
M.Menu = {}

function M.Menu:addAction( icon, text )
	local action = ObjectWrapper( system:newInstanceOf( "QAction" ) )
	action.icon = icon
	action.text = text
	action.iconVisibleInMenu = true
	system:addAction( self._obj, action._obj )
	return action
end

function M.Menu:exec( x, y )
	return system:execMenu( self._obj, x or -1, y or -1 )
end

local MenuMT = {}

function MenuMT.__call( menuTable, title )
	menuTable._obj = system:newInstanceOf( "QMenu" )
	menuTable._obj:setProperty( "title", M.Variant( title or "" ) )
	return menuTable
end

-- makes qt.Menu inherits from qt.Object
setmetatable( MenuMT, MT )

-- sets menu metatable
setmetatable( M.Menu, MenuMT )

-------------------------------------------------------------------------------
-- Export Qt::ItemFlag enum (see AbstractItemModelDelegate:getData())
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
-- Export Qt::BrushStyle enum
-------------------------------------------------------------------------------
M.NoBrush 					= 0
M.SolidPattern 				= 1
M.Dense1Pattern				= 2
M.Dense2Pattern				= 3
M.Dense3Pattern				= 4
M.Dense4Pattern				= 5
M.Dense5Pattern				= 6
M.Dense6Pattern				= 7
M.Dense7Pattern				= 8
M.HorPattern				= 9
M.VerPattern				= 10
M.CrossPattern				= 11
M.BDiagPattern				= 12
M.FDiagPattern				= 13
M.DiagCrossPattern			= 14
M.LinearGradientPattern		= 15
M.ConicalGradientPattern	= 17
M.RadialGradientPattern		= 16
M.TexturePattern			= 24

-------------------------------------------------------------------------------
-- Export Qt::AlignmentFlag enum
-------------------------------------------------------------------------------
M.AlignLeft		= 0x0001
M.AlignRight	= 0x0002
M.AlignHCenter	= 0x0004
M.AlignJustify	= 0x0008
M.AlignTop		= 0x0020
M.AlignBottom	= 0x0040
M.AlignVCenter	= 0x0080
M.AlignAbsolute	= 0x0010

-------------------------------------------------------------------------------
-- Export Module
-------------------------------------------------------------------------------
M.app = ObjectWrapper( system.app )

function M.newInstanceOf( className, object )
	return ObjectWrapper( system:newInstanceOf( className ) )
end

function M.loadUi( uiFile )
	return ObjectWrapper( system:loadUi( uiFile ) )
end

function M.getExistingDirectory( parent, caption, initialDir )
	return system:getExistingDirectory( parent._obj, caption, initialDir )
end

function M.getOpenFileNames( parent, caption, initialDir )
	return system:getOpenFileNames( parent._obj, caption, initialDir )
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
