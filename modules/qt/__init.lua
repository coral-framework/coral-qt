-- performed before requiring other dependent submodules since they might use 
-- system service

-------------------------------------------------------------------------------
-- Required modules
-------------------------------------------------------------------------------
local path = require "path"
local types = require "qt.Types"
local eventHandler = require "qt.EventHandler"
local connectionHandler = require "qt.ConnectionHandler"

-------------------------------------------------------------------------------
-- Coral-Qt system service registration
-------------------------------------------------------------------------------
-- For now we're manually registering the qt.ISystem service here.
co.system.services:addServiceProvider( co.Type "qt.ISystem", "qt.System" )
local system = co.getService( "qt.ISystem" )

local M = {}

-------------------------------------------------------------------------------
-- ObjectWrapper
-------------------------------------------------------------------------------
local MT = {}

-- stores single instances of ObjectWrapper for each wrapped object
M.wrappedInstances = {}

local function ObjectWrapper( object )
	if not M.wrappedInstances[object.hash] then
		M.wrappedInstances[object.hash] = setmetatable( { _obj = object, hash = object.hash }, MT )
	end
	
	return M.wrappedInstances[object.hash]
end

function MT.connect( wrapper, signal, handlerClosure )
	connectionHandler.connect( wrapper, signal, handlerClosure )
end

function MT.invoke( wrapper, name, a1, a2, a3, a4, a5, a6, a7 )
	return wrapper._obj:invoke( name, a1, a2, a3, a4, a5, a6, a7 )
end

function MT.__index( wrapper, name )
	-- returns one of the ObjectWrapper utility functions
	if MT[name] then return MT[name] end

	local v = wrapper._obj:getPropertyOrChild( name )

	-- assume that all userdata are instances of qt.Object
	if type( v ) == "userdata" then
		v = ObjectWrapper( v )
	end

	return v
end

function MT.__newindex( wrapper, name, value )
	if eventHandler.installEventHandler( wrapper, name, value )	then
		return
	end
	wrapper._obj:setProperty( name, value )
end

-------------------------------------------------------------------------------
-- ObjectWrapper utility functions that provides access to QWidget, QAction, 
-- QLayout and QMenu specific operations through ISystem interface.
-------------------------------------------------------------------------------
function MT.addWidget( parent, widget )
	system:insertWidget( parent._obj, -1, widget._obj )
	return widget
end

function MT.insertWidget( parent, widget, pos )
	system:insertWidget( parent._obj, pos, widget._obj )
	return widget
end

function MT.removeWidget( parent, widget )
	system:removeWidget( parent._obj, widget._obj )
	return widget
end

function MT.addDockWidget( mainWindow, area, dockWidget )
	system:addDockWidget( mainWindow._obj, area, dockWidget._obj )
	return mainWindow
end

function MT.setWidget( dockWidget, widget )
	system:setWidget( dockWidget._obj, widget._obj )
	return dockWidget
end

function MT.setLayout( widget, layout )
	local layoutInstance = layout
	if type( layout ) == "string" then
		--[[
			creates the layout specified by the given layout name using 'widget' 
			as parent: Qt forces a non-null parent in Debug using an Q_ASSERT
			for some unknown reason. It is not pointed in the documentation of 
			QUiLoader::createLayout().
		  ]]
		layoutInstance = M.new( layout, widget )
	end
	
	system:setLayout( widget._obj, layoutInstance._obj )
	return layoutInstance
end

function MT.getLayout( widget )
	return ObjectWrapper( system:getLayout( widget._obj ) )
end

function MT.addAction( widget, v, icon )
	-- adds support for adding an action both from text 
	-- and icon as well as from an actual QAction instance
	local actionInstance = v
	if type( v ) == "string" then
		actionInstance = M.new( "QAction" )
		if icon then
			actionInstance.icon = icon
			actionInstance.iconVisibleInMenu = true
		end
		actionInstance.text = v or ""
	end
	
	system:insertAction( widget._obj, -1, actionInstance._obj )
	return actionInstance
end

function MT.removeAction( widget, action )
	system:removeAction( widget._obj, action._obj )
end

function MT.setMenu( action, menu )
	system:setMenu( action._obj, menu._obj )
	return menu
end

function MT.insertAction( widget, beforeActionIndex, v, icon )
	-- adds support for inserting an action both from text 
	-- and icon as well as from an actual QAction instance	
	local actionInstance = v	
	if type( v ) == "string" then
		actionInstance = M.new( "QAction" )
		if icon then
			actionInstance.icon = icon
			actionInstance.iconVisibleInMenu = true
		end
		actionInstance.text = v or ""
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

function M.getOpenFileNames( parent, caption, initialDir, filter )
	return system:getOpenFileNames( parent._obj, caption, initialDir, filter )
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

-------------------------------------------------------------------------------
-- Sub-modules configurations
-------------------------------------------------------------------------------
-- types must access ObjectWrapper functions from this (parent) module
types.parent = M

-- eventHandler/connectinoHandler must access system service
eventHandler.system = system
connectionHandler.system = system

-- copy types to module table
for k, v in pairs( types ) do
	M[k] = v
end

return M
