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
	if not M.initialized then
		M.layout = mainWindow.centralWidget:setLayout( "QVBoxLayout" )	
		M.textEdit = qt.new( "QTextEdit" )
		local msg = "[Extended Central Widget]: Click unload in the plugins "
		msg = msg .. "access menu to unload the Central Widget Plugin and remove this widget."
		M.textEdit.plainText = msg
		M.initialized = true
	end
	M.layout:addWidget( M.textEdit )
	-- set visible state again (Qt hides widgets after they get removed)
	M.textEdit.visible = true
end

function M.unload( mainWindow )
	mainWindow.centralWidget:getLayout():removeWidget( M.textEdit )
end

return M
