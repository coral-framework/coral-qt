local qt = require "qt"

-- loads main form
-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local M = 
{ 
	name = "Extend StatusBar Plugin", 
	icon = qt.Icon( "coral:/extensibleUIs/icons/statusbar.png" ) 
}

function M.load( mainWindow )
	local lineEdit = qt.new( "QLineEdit" )
	lineEdit.text = "Extended StatusBar!"
	M.action = mainWindow.statusbar:addWidget( lineEdit )
end

return M
