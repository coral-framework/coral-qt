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
	if not M.initialized then
		M.menuAction = qt.new( "QAction" )
		M.menuAction.text = "[Extended Menu]"

		local menu = qt.Menu()
		menu:addAction( "Extended Option1" )
		menu:addAction( "Extended Option2" )
		menu:addAction( "Extended Option3" )
		M.menuAction:setMenu( menu )
		M.initialized = true
	end
	mainWindow.menubar:addAction( M.menuAction )
end


function M.unload( mainWindow )
	mainWindow.menubar:removeAction( M.menuAction )
end

return M
