-------------------------------------------------------------------------------
--- Required modules
-------------------------------------------------------------------------------
local qt = require "qt"

-- loads main form
-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local M = {}

local function printPos( x, y )
	return "(" .. x .. ", " .. y .. ")"
end

local function printMods( modifiers )
	local str = ""
	if modifiers.alt then
		str = "<alt>"
	end
	if modifiers.shift then
		str = str .. "<shift>"
	end
	if modifiers.control then
		str = str .. "<ctrl>"
	end
	if modifiers.meta then
		str = str .. "<meta>"
	end
	if modifiers.keypad then
		str = str .. "<keypad>"
	end
	if modifiers.groupSwitch then
		str = str .. "<grpSwitch>"
	end

	if str == "" then
		str = "[NONE]"
	end

	return str
end

local function mouseEvent( eventName, source, x, y, button, modifiers )
	local msg = eventName .. " Event Performed (source object = " 
	msg = msg .. tostring( source ) .. "): button = " .. ( button or "" ) .. ", pressed at pos " 
	msg = msg .. printPos( x, y ) .. ". Current Modifiers are: " 
	msg = msg .. printMods( modifiers )

	M.mainWindow.textArea:invoke( "append(QString)", msg )
end

local function onMousePress( source, x, y, button, modifiers )
	mouseEvent( "Mouse Press", source, x, y, button, modifiers )
end

local function onMouseRelease( source, x, y, button, modifiers )
	mouseEvent( "Mouse Release", source, x, y, button, modifiers )
end

local function onMouseMove( source, x, y, button, modifiers )
	mouseEvent( "Mouse Move", source, x, y, button, modifiers )
end

local function onWheel( source, x, y, delta, modifiers )
	mouseEvent( "Mouse Wheel (Delta = " .. delta .. ")", source, x, y, nil, modifiers )
end

local function onResize( source, width, height, oldWidth, oldHeight )
	local msg = "Window Resized from (" .. oldWidth .. ", " 
	msg = msg .. oldHeight .. ") to (" .. width .. ", " .. height .. ")"
	M.mainWindow.textArea:invoke( "append(QString)", msg )
end

local function onKeyEvent( eventName, key, modifiers )
	local msg = eventName .. ", Key =  ".. key .. " modifiers are: " .. printMods( modifiers )
	M.mainWindow.textArea:invoke( "append(QString)", msg )
end

local function onKeyPress( source, key, modifiers )
	onKeyEvent( "Key Press Event", key, modifiers )
end

local function onKeyRelease( source, key, modifiers )
	onKeyEvent( "Key Release Event", key, modifiers )
end

local function showWelcome()
	if not M.messageDialog then
		M.messageDialog = qt.new( "QMessageBox" )
		M.messageDialog.windowIcon = qt.Icon( "coral:/extensibleUIs/icons/coral_32.png" )
		M.messageDialog.icon = qt.MessageBox.Information

		local helpMsg = 	 "Click, drag or press keys into Interaction Area to show "
		helpMsg = helpMsg .. "event data into text area."

		M.messageDialog.text = helpMsg
	end

	M.messageDialog.windowTitle = "Show Event"
	M.messageDialog:invoke( "exec()" )
end

local function showGoodbie()
	local helpMsg = 	 "Thats a Close Event! Goodbie!"
	M.messageDialog.windowTitle = "Close Event"
	M.messageDialog.text = helpMsg
	M.messageDialog:invoke( "exec()" )
end

local function setupUi()
	-- loads main window ui file
	M.mainWindow = qt.loadUi( "coral:/eventHandling/SimpleDialog.ui" )

	-- set event handlers
	-- set show event for both windows
	M.mainWindow.onShow = function( source, ... ) showWelcome() end

	-- set close event so when the main window is closed, the slave is closed too
	M.mainWindow.onClose = function( source, ... ) showGoodbie() end

	M.mainWindow.interactionArea.onResize = onResize
	M.mainWindow.interactionArea.onKeyPress = onKeyPress
	M.mainWindow.interactionArea.onKeyRelease = onKeyRelease
	M.mainWindow.interactionArea.onMousePress = onMousePress
	M.mainWindow.interactionArea.onMouseMove = onMouseMove
	M.mainWindow.interactionArea.onMouseRelease = onMouseRelease
	M.mainWindow.interactionArea.onWheel = onWheel

	M.mainWindow.visible = true
end

setupUi()

qt.exec()

