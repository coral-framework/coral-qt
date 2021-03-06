-------------------------------------------------------------------------------
-- Required modules
-------------------------------------------------------------------------------

local path = require "lua.path"
local types = require "qt.Types"
local eventHandler = require "qt.EventHandler"
local connectionHandler = require "qt.ConnectionHandler"

-------------------------------------------------------------------------------
-- Coral-Qt system service registration
-------------------------------------------------------------------------------

-- For now we're manually registering the qt.ISystem service here.
local system = co.new( "qt.System" ).system
co.system.services:addService( co.Type "qt.ISystem", system )

local M = { system = system }

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

-- if handlerInstance is not nill then handlerClosureOrClosureName must be a name
-- of a closure in it and will be called passing the table as self argument.
function MT.connect( wrapper, signal, handlerClosureOrClosureName, handlerInstance )
	connectionHandler.connect( wrapper, signal, handlerClosureOrClosureName, handlerInstance )
end

function MT.invoke( wrapper, name, a1, a2, a3, a4, a5, a6, a7 )
	return wrapper._obj:invoke( name, a1, a2, a3, a4, a5, a6, a7 )
end

function MT.__index( wrapper, name )
	-- returns one of the ObjectWrapper utility functions
	if MT[name] then return MT[name] end

	if name:sub( 1, 1 ) == '_' then
		return wrapper[name]
	end

	local v = wrapper._obj:getPropertyOrChild( name )

	-- assume that all userdata are instances of qt.Object
	if type( v ) == "userdata" then
		v = ObjectWrapper( v )
	end

	return v
end

function MT.__newindex( wrapper, name, value )
	assert( value ~= nil )
	if eventHandler.installEventHandler( wrapper, name, value )	then
		return
	end

	-- if name is an special name, then just set the property within the owner table
	-- and returns (do not accept qt properties beggining with underscore symbol)
	if name:sub( 1, 1 ) == '_' then
		rawset( wrapper, name, value )
		return
	end
	wrapper._obj:setProperty( name, value )
end

-------------------------------------------------------------------------------
-- ObjectWrapper utility functions that provides access to QWidget, QAction,
-- QLayout and QMenu specific operations through ISystem interface.
-------------------------------------------------------------------------------
function MT.addWidget( parent, widget )
	system:insertWidget( parent._obj or parent, -1, widget._obj or widget )
	return widget
end

function MT.insertWidget( parent, widget, pos )
	system:insertWidget( parent._obj or parent, pos, widget._obj or widget )
	return widget
end

function MT.removeWidget( parent, widget )
	system:removeWidget( parent._obj or parent, widget._obj or widget )
	return widget
end

function MT.addDockWidget( mainWindow, area, dockWidget )
	system:addDockWidget( mainWindow._obj or mainWindow, area, dockWidget._obj or dockWidget )
	return mainWindow
end

function MT.setCorner( mainWindow, corner, area )
	system:setCorner( mainWindow._obj or mainWindow, corner, area )
	return mainWindow
end

function MT.getToggleViewAction( dockWidget )
	return ObjectWrapper( system:getToggleViewAction( dockWidget._obj or dockWidget ) )
end

function MT.setWidget( dockWidget, widget )
	system:setWidget( dockWidget._obj or dockWidget, widget._obj or widget )
	return dockWidget
end

function MT.setCentralWidget( mainWindow, centralWidget )
	system:setCentralWidget( mainWindow._obj or mainWindow, centralWidget._obj or centralWidget )
end

function MT.getCentralWidget( mainWindow )
	return ObjectWrapper( system:getCentralWidget( mainWindow._obj or mainWindow ) )
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

	system:setLayout( widget._obj or widget, layoutInstance._obj or layoutInstance )
	return layoutInstance
end

function MT.insertSpacing( layout, beforeIndex, size )
	system:insertSpacing( layout._obj or layout, beforeIndex, size )
end

function MT.insertStretch( layout, beforeIndex, stretch )
	system:insertStretch( layout._obj or layout, beforeIndex or -1, size or 0 )
end

function MT.getLayout( widget )
	return ObjectWrapper( system:getLayout( widget._obj or widget ) )
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

	system:insertAction( widget._obj or widget, -1, actionInstance._obj or actionInstance )
	return actionInstance
end

function MT.removeAction( widget, action )
	system:removeAction( widget._obj or widget, action._obj or widget )
end

function MT.setMenu( action, menu )
	system:setMenu( action._obj or action, menu._obj or menu )
	return menu
end

function MT.addActionIntoGroup( actionGroup, action )
	system:addActionIntoGroup( actionGroup._obj or actionGroup, action._obj or action )
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

	system:insertAction( widget._obj or widget, beforeActionIndex, actionInstance._obj or actionInstance )
	return actionInstance
end

function MT.insertSeparator( widget, beforeActionIndex )
	local action = M.new( "QAction" )
	system:makeSeparator( action._obj )
	system:insertAction( widget._obj, beforeActionIndex, action._obj )
	return action
end

function MT.makeSeparator( widget )
	system:makeSeparator( widget._obj )
	return widget
end

function MT.exec( menu, x, y )
	return ObjectWrapper( system:execMenu( menu._obj, x or -1, y or -1 ) )
end

function MT.addItem( comboBox, text, userData )
	system:insertItem( comboBox._obj, -1, text, userData or 0 )
end

function MT.insertItem( comboBox, index, text, userData )
	system:insertItem( comboBox._obj, index, text, userData or 0 )
end

function MT.showPopup( comboBox )
	system:showPopup( comboBox._obj )
end

function MT.hidePopup( comboBox )
	system:hidePopup( comboBox._obj )
end

function MT.setModel( view, model )
	system:assignModelToView( view._obj, model._obj or model )
end

function MT.setSelectionModel( view, model )
	system:assignSelectionModelToView( view._obj, model._obj or model )
end

function MT.setCursor( widget, cursor )
	system:setCursor( widget._obj, cursor )
end

function MT.unsetCursor( widget )
	system:unsetCursor( widget._obj )
end

function MT.setCursorPosition( widget, posX, posY )
	system:setCursorPosition( widget._obj, posX, posY )
end

function MT.getCursorPosition( widget )
	return system:getCurstorPosition( widget._obj )
end

function MT.mapFromGlobal( widget, posX, posY )
	return system:mapFromGlobal( widget._obj, posX, posY )
end

function MT.mapToGlobal( widget, posX, posY )
	return system:mapToGlobal( widget._obj, posX, posY )
end

function MT.grabMouse( widget, cursor )
	return system:grabMouse( widget._obj, cursor )
end

function MT.releaseMouse( widget )
	return system:releaseMouse( widget._obj )
end

-------------------------------------------------------------------------------
-- Export Module
-------------------------------------------------------------------------------
M.app = ObjectWrapper( system.app )
M.wrap = ObjectWrapper
M.unwrap = function( wrappedObject ) return wrappedObject._obj end

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

function M.getOpenFileName( parent, caption, initialDir, filter )
	return system:getOpenFileName( parent._obj, caption, initialDir, filter )
end

function M.getOpenFileNames( parent, caption, initialDir, filter )
	return system:getOpenFileNames( parent._obj, caption, initialDir, filter )
end

function M.getSaveFileName( parent, caption, initialDir, filter )
	return system:getSaveFileName( parent._obj, caption, initialDir, filter )
end
function M.getInputText( parent, dialogTitle, label, text )
	return system:getInputText( parent._obj or parent, dialogTitle, label, text )
end

function M.setSearchPaths( prefix, paths )
	if type( paths ) == "table" then
		-- paths is a table with a list of absolute paths
		return system:setSearchPaths( prefix, paths )
	elseif type( paths ) == "string" then
		-- paths is a module name
		local subPath = string.gsub( paths, "%.", "/" )
		local coPaths = co.getPaths()
		local newSearchPaths = {}
		for k, v in pairs( coPaths ) do
			local newPath = v .. "/" .. subPath
			if path.exists( newPath ) and path.isDir( newPath ) then
				table.insert( newSearchPaths, path.normalize( newPath ) )
			end
		end
		return system:setSearchPaths( prefix, newSearchPaths )
	end
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

local function makeNamedSlotsTable( slotsTable )
	local namedSlotsTable = {}
	for k, v in pairs( slotsTable ) do
		if type( v ) == "function" then
			local parametersChunk = string.match( k, "on_[%w_%d]*__([%w_]*)" )
			local slotInfoChunk = k
			local parametersString = "("
			if parametersChunk then
				slotInfoChunk = string.sub( k, 1, string.len( k ) - string.len( parametersChunk ) - 2 )
				local p = {}
				for w in string.gmatch( parametersChunk, "([%w]*)" ) do
					if w and w ~= "" then
						table.insert( p, w )
					end
				end
				for i, v in ipairs( p ) do
					parametersString = parametersString .. v
					if i < #p then
						parametersString = parametersString .. ","
					end
				end
			end
			parametersString = parametersString .. ")"
			local childName = string.match( slotInfoChunk, "on_([%w_%d]*)_" )
			if childName and childName ~= "" then
				local qtSlotName = string.sub( slotInfoChunk, 4 - string.len( slotInfoChunk ) + string.len( childName ) )
				namedSlotsTable[childName] = { closure = v, qtSignalSignature = qtSlotName .. parametersString }
			end
		end
	end

	return namedSlotsTable
end

function M.connectSlotsByName( wrapper, slotsTable )
	local namedSlotsTable = makeNamedSlotsTable( slotsTable )
	for k, v in pairs( namedSlotsTable ) do
		local child = wrapper[k]
		local signalSignature = v.qtSignalSignature
		if child and child._obj then
			child:connect( signalSignature, v.closure )
		else
			local msg = "connectSlotsByName: warning: no match child QObject for given slot'" .. signalSignature
			msg = msg .. "'. You might have mistyped signal name. Closures signature must be of form on_(child QObject name)_(signal name)[__type1_type2_...typeN]"
			print( msg )
		end
	end
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
