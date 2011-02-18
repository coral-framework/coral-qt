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
	M.mainWindow:listen( qt.Event.Show, function() M.mainWindow.windowTitle = "Event Handling Sample Application: Main Dialog" end )
	M.mainWindow2:listen( qt.Event.Show, function() M.mainWindow2.windowTitle = "Event Handling Sample Application: Slave Dialog" end )

	-- set close event so when the main window is closed, the slave is closed too
	M.mainWindow:listen( qt.Event.Close, function() qt.app:invoke( "closeAllWindows()" ) end )

	M.mainWindow.visible = true

	M.mainWindow2.visible = true
	M.mainWindow2.pos = qt.Point( 100, 100 )
end

setupUi()

qt.exec()

