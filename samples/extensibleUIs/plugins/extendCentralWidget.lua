local qt = require "qt"

-- loads main form
-- configure search paths
qt.setSearchPaths( "coral", co.getPaths() )

local M = 
{ 
	name = "Extend Central Widget Plugin", 
	icon = qt.Icon( "coral:/extensibleUIs/icons/centralWidget.png" ) 
}

function M.load( mainWindow )
	local layout = mainWindow.centralWidget:setLayout( "QVBoxLayout" )	
	local textEdit = qt.new( "QTextEdit" )
	local msg = "[Extended Central Widget]: Click unload in the plugins "
	msg = msg .. "access menu to unload the Central Widget Plugin and remove this widget."
	textEdit.plainText = msg

	textEdit:invoke( "setAlignment(Qt::Alignment)", qt.AlignCenter )
	layout:addWidget( textEdit )
end

return M
