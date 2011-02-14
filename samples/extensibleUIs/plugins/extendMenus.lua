local qt = require "qt"

-- loads main form
-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local M = 
{ 
	name = "Extend Menu Plugin", 
	icon = qt.Icon( "coral:/extensibleUIs/icons/menu.png" ) 
}

function M.load( mainWindow )
	M.menuAction = mainWindow.menubar:addAction( "[Extended Menu]" )
	local menu = qt.Menu()
	menu:addAction( "Extended Option1" )
	menu:addAction( "Extended Option2" )
	menu:addAction( "Extended Option3" )
	M.menuAction:setMenu( menu )
end

return M
