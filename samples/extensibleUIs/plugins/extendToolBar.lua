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
	M.action = mainWindow.toolbar:addAction( "Extended Action for ToolBar!", M.icon )
end

return M
