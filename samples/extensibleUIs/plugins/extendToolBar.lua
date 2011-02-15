local qt = require "qt"

-- loads main form
-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local M = 
{ 
	name = "Extend ToolBar Plugin", 
	icon = qt.Icon( "coral:/extensibleUIs/icons/toolbar.png" ) 
}

function M.load( mainWindow )
	if not M.initialized then
		M.menuAction = qt.new( "QAction" )
		M.menuAction.text = "Extended Action for ToolBar!"
		M.menuAction.icon = M.icon
		M.initialized = true
	end
	mainWindow.toolbar:addAction( M.menuAction )
end

function M.unload( mainWindow )
	mainWindow.toolbar:removeAction( M.menuAction )
end

return M
