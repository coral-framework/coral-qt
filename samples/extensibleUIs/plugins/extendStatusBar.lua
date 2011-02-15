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
	if not M.initialized then
		M.lineEdit = qt.new( "QLineEdit" )
		M.toolTip = "Extended statusbar lineEdit!!!"
		M.lineEdit.text = "Extended StatusBar!"
		M.button = qt.new( "QPushButton" )
		M.button.icon = M.icon
		M.button.text = ""
		M.button.toolTip = "Extended statusbar button1!!!"
		M.button2 = qt.new( "QPushButton" )
		M.button2.icon = qt.Icon( "coral:/extensibleUIs/icons/menu.png" ) 
		M.button2.toolTip = "Extended statusbar button2!!!"
		M.button2.text = ""
		M.initialized = true
	end

	-- adds a LineEdit in the statusBar
	mainWindow.statusbar:addWidget( M.lineEdit )
	mainWindow.statusbar:addWidget( M.button )
	mainWindow.statusbar:addWidget( M.button2 )

	-- set visible state again (Qt hides widgets after they get removed)
	M.button.visible = true
	M.button2.visible = true
	M.lineEdit.visible = true
end

function M.unload( mainWindow )
	mainWindow.statusbar:removeWidget( M.lineEdit )
	mainWindow.statusbar:removeWidget( M.button )
	mainWindow.statusbar:removeWidget( M.button2 )
end

return M
