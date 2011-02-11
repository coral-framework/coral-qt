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
	local layout = qt.new( "QVBoxLayout" )
	mainWindow.centralWidget:setLayout( layout )
	local textEdit = qt.new( "QTextEdit" )
	textEdit.plainText = "[Extended Central Widget]: Click unload in the plugins access menu to unload the Central Widget Plugin and remove this widget."
	textEdit:invoke( "setAlignment(Qt::Alignment)", qt.AlignCenter )
	layout:addWidget( textEdit )
end

return M
