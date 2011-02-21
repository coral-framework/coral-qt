-------------------------------------------------------------------------------
--- Required modules
-------------------------------------------------------------------------------
local qt = require "qt"

-- loads main form
-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local M = {}

local function setupUi()
	-- loads main window ui file
	M.mainWindow = qt.loadUi( "coral:/eventHandling/SimpleDialog.ui" )
	M.mainWindow2 = qt.loadUi( "coral:/eventHandling/SimpleDialog.ui" )

	-- set event handlers
	-- set show event for both windows
	M.mainWindow.onShow = function( source, ... ) print( "handled onShow event from object ",  source ); M.mainWindow.windowTitle = "Event Handling Sample Application: Main Dialog" end
	M.mainWindow2.onShow = function( source, ... ) print( "handled onShow event from object ", source ); M.mainWindow2.windowTitle = "Event Handling Sample Application: Slave Dialog" end

	-- set close event so when the main window is closed, the slave is closed too
	M.mainWindow.onClose = function( source, ... ) print( "handled onClose event from object ", source ); qt.app:invoke( "closeAllWindows()" ) end

	M.mainWindow.onResize = function( source, width, height, oldWidth, oldHeight ) print( "onResize", source, width, height, oldWidth, oldHeight ) end
	M.mainWindow.onKeyPress = function( source, key, modifiers ) print( "onKeyPress", source, key, modifiers ) end
	M.mainWindow.onMousePress = function( source, x, y, button, modifiers ) print( "onMousePress", source, x, y, button, modifiers ) end
	M.mainWindow.onMouseMove = function( source, x, y, button, modifiers ) print( "onMouseMove", source, x, y, button, modifiers ) end
	M.mainWindow.onMouseRelease = function( source, x, y, button, modifiers ) print( "onMouseRelease", source, x, y, button, modifiers ) end
	M.mainWindow.onWheel = function( source, x, y, delta, modifiers ) print( "onWheel", source, x, y, delta, modifiers ) end

	M.mainWindow.visible = true

	M.mainWindow2.visible = true
	M.mainWindow2.pos = qt.Point( 100, 100 )
end

setupUi()

qt.exec()

