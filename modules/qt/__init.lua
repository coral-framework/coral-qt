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

local connectionHandlerClosures = {}
local connectionHandler = ( LuaConnectionHandler{ closures = connectionHandlerClosures } ).handler

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

local eventClosureNames = {
-- closure name map
["onMouseDoubleClick"]				= true,
["onMousePress"]					= true,
["onMouseRelease"]					= true,
["onMouseMove"]						= true,
["onKeyPress"]						= true,
["onKeyRelease"]					= true,
["onWheel"]							= true,
["onClose"]							= true,
["onResize"]						= true,
["onShow"]							= true,
["onHide"]							= true,

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
	local eventClosureName = eventClosureNames[eventType]
	if not eventClosureName or not self.closures[cookie][eventClosureName] then
		return
	end
	-- dispatch the event to corresponding closure passing the source object
	self.closures[cookie][eventClosureName]( self.closures[cookie].source, ... )
end

local eventHandlerClosures = {}
local eventHandler = ( LuaEventHandler{ closures = eventHandlerClosures } ).handler

-------------------------------------------------------------------------------
-- ObjectWrapper
-------------------------------------------------------------------------------
local MT = {}

local function ObjectWrapper( object )
	return setmetatable( { _obj = object }, MT )
end

local function connect( wrapper, signal, handlerClosure )
	local cookie = system:connect( wrapper._obj, signal, connectionHandler )
	connectionHandlerClosures[cookie] = handlerClosure
end

local function invoke( wrapper, name, a1, a2, a3, a4, a5, a6, a7 )
	return wrapper._obj:invoke( name, a1, a2, a3, a4, a5, a6, a7 )
end

function MT.__index( wrapper, name )
	if name == "connect" then
		return connect
	elseif name == "invoke" then
		return invoke
	elseif name == "listen" then
		return listen
	end

	-- returns one of the shortcut functions
	if MT[name] then return MT[name] end

	local v = wrapper._obj:getPropertyOrChild( name )

	-- assume that all userdata are instances of qt.Object
	if type( v ) == "userdata" then
		v = ObjectWrapper( v )
	end

	return v
end

function MT.__newindex( wrapper, name, value )
	-- checks whether the new index name is a event closure name
	if type( value ) == "function" and eventClosureNames[name] then
		local cookie = system:installEventHandler( wrapper._obj, eventHandler )
		eventHandlerClosures[cookie] = eventHandlerClosures[cookie] or {}
		eventHandlerClosures[cookie][name] = value
		eventHandlerClosures[cookie].source = wrapper
		return
	end

	wrapper._obj:setProperty( name, value )
end

-- helper to ISystem:insertWidget( parent, pos, widget )
function MT.addWidget( parent, widget )
	system:insertWidget( parent._obj, -1, widget._obj )
	return widget
end

function MT.insertWidget( parent, widget, pos )
	system:insertWidget( parent._obj, pos, widget._obj )
	return widget
end

-- helper to ISystem:removeWidget( parent, widget )
function MT.removeWidget( parent, widget )
	system:removeWidget( parent._obj, widget._obj )
	return widget
end

-- helper to ISystem:setLayout( widget, layout )
function MT.setLayout( widget, layout )
	local layoutInstance = layout
	if type( layout ) == "string" then
		-- create the layout specified by the given string passing 'widget' 
		-- as parent: Qt forces a non-null parent in Debug using an Q_ASSERT
		-- for some strange reason. It is not pointed in the documentation of 
		-- QUiLoader::createLayout().
		layoutInstance = M.new( layout, widget )
	end
	
	system:setLayout( widget._obj, layoutInstance._obj )
	return layoutInstance
end

-- shortcut to ISystem:getLayout( widget )
function MT.getLayout( widget )
	return ObjectWrapper( system:getLayout( widget._obj ) )
end

-- shortcut to ISystem:addAction()
function MT.addAction( widget, text, icon )
	local actionInstance = text	
	-- support adding action from text and icon
	if type( text ) == "string" then
		actionInstance = M.new( "QAction" )
		if icon then
			actionInstance.icon = icon
			actionInstance.iconVisibleInMenu = true
		end
		actionInstance.text = text or ""
	end
	
	system:insertAction( widget._obj, -1, actionInstance._obj )
	return actionInstance
end

function MT.removeAction( widget, action )
	system:removeAction( widget._obj, action._obj )
end

-- shortcut to ISystem:setMenu( action, menu )
function MT.setMenu( action, menu )
	system:setMenu( action._obj, menu._obj )
	return menu
end

-- shortcut to ISystem:insertAction( widget, pos, action )
function MT.insertAction( widget, beforeActionIndex, text, icon )
	local actionInstance = text	
	-- support adding action from text and icon
	if type( text ) == "string" then
		actionInstance = M.new( "QAction" )
		if icon then
			actionInstance.icon = icon
			actionInstance.iconVisibleInMenu = true
		end
		actionInstance.text = text or ""
	end
	
	system:insertAction( widget._obj, beforeActionIndex, actionInstance._obj )
	return actionInstance
end

function MT.insertSeparator( widget, beforeAction )
	local action = M.new( "QAction" )
	system:setSeparator( action )
	system:insertAction( widget._obj, beforeAction, action._obj )
	return action
end

-- shortcut to ISystem:execMenu()
function MT.exec( menu, x, y )
	return ObjectWrapper( system:execMenu( menu._obj, x or -1, y or -1 ) )
end

function MT.setModel( view, model )
	system:assignModelToView( view._obj, model._obj or model )
end

-------------------------------------------------------------------------------
-- Casts IObjectSource components into an ObjectWrapper
-------------------------------------------------------------------------------
function M.objectCast( component )
	-- By now, just assume that the component passed
	-- has an IObjectSource facet called 'self'
	return ObjectWrapper( component.self.object )
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

-- Constructs a qt point instance using qt.Variant
function M.Point( x, y )
	local variant = co.new( "qt.Variant" )
	variant:setPoint( x, y )
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
function M.Menu( title )
	local menu = M.new( "QMenu" )
	menu.title = title or ""
	return menu
end

-------------------------------------------------------------------------------
-- Export QGL::FormatOption enum
-------------------------------------------------------------------------------
M.FormatOption = {}
M.FormatOption.DoubleBuffer				= 1				
M.FormatOption.DepthBuffer				= 2				
M.FormatOption.Rgba						= 4				
M.FormatOption.AlphaChannel				= 8				
M.FormatOption.AccumBuffer				= 16				
M.FormatOption.StencilBuffer			= 32				
M.FormatOption.StereoBuffers			= 64				
M.FormatOption.DirectRendering			= 128				
M.FormatOption.HasOverlay				= 256	
M.FormatOption.SampleBuffers			= 512
M.FormatOption.DeprecatedFunctions		= 1024			
M.FormatOption.SingleBuffer				= 65536
M.FormatOption.NoDepthBuffer			= 131072
M.FormatOption.ColorIndex				= 262144
M.FormatOption.NoAlphaChannel			= 524288
M.FormatOption.NoAccumBuffer			= 1048576
M.FormatOption.NoStencilBuffer			= 2097152
M.FormatOption.NoStereoBuffers			= 4194304
M.FormatOption.IndirectRendering		= 8388608
M.FormatOption.NoOverlay				= 16777216
M.FormatOption.NoSampleBuffers			= 33554432
M.FormatOption.NoDeprecatedFunctions	= 67108864

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
M.AlignCenter	= M.AlignHCenter + M.AlignVCenter
M.Horizontal 	= 0x1
M.Vertical 		= 0x2

-------------------------------------------------------------------------------
-- Export QMessageBox enums
-------------------------------------------------------------------------------
M.MessageBox = {}

M.MessageBox.NoIcon				= 0
M.MessageBox.Question			= 4
M.MessageBox.Information		= 1
M.MessageBox.Warning			= 2
M.MessageBox.Critical			= 3
M.MessageBox.Ok					= 0x00000400
M.MessageBox.Open				= 0x00002000
M.MessageBox.Save				= 0x00000800
M.MessageBox.Cancel				= 0x00400000
M.MessageBox.Close				= 0x00200000
M.MessageBox.Discard			= 0x00800000
M.MessageBox.Apply				= 0x02000000
M.MessageBox.Reset				= 0x04000000
M.MessageBox.RestoreDefaults	= 0x08000000
M.MessageBox.Help				= 0x01000000
M.MessageBox.SaveAll			= 0x00001000
M.MessageBox.Yes				= 0x00004000
M.MessageBox.YesToAll			= 0x00008000
M.MessageBox.No					= 0x00010000
M.MessageBox.NoToAll			= 0x00020000
M.MessageBox.Abort				= 0x00040000
M.MessageBox.Retry				= 0x00080000
M.MessageBox.Ignore				= 0x00100000
M.MessageBox.NoButton			= 0x00000000

-------------------------------------------------------------------------------
-- Export Module
-------------------------------------------------------------------------------
M.app = ObjectWrapper( system.app )

function M.new( className, parent, object )
	local parentInstance = parent
	if not parent then
		-- empty Object representing a null QObject
		parentInstance = { _obj = co.new( "qt.Object" ) }
	end

	return ObjectWrapper( system:newInstanceOf( className, parentInstance._obj ) )
end

function M.loadUi( uiFile, parentWidget )
	local parentInstance = parentWidget
	if not parentWidget then
		-- empty Object representing a null QObject
		parentInstance = { _obj = co.new( "qt.Object" ) }
	end

	return ObjectWrapper( system:loadUi( uiFile, parentInstance._obj ) )
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

function M.quit()
	return system:quit()
end

return M
