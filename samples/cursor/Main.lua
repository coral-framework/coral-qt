local qt = require "qt"

qt.setSearchPaths( "coral", co.getPaths() )

local mainWindow = qt.loadUi "coral:cursor/MainWindow.ui"
mainWindow.centralwidget:setCursor( qt.ForbiddenCursor )
mainWindow.visible = true

mainWindow.centralwidget.onMouseRelease = function( source, x, y, button, modifiers )
	mainWindow.centralwidget:setCursorPosition( mainWindow.centralwidget:mapToGlobal( mainWindow.centralwidget.width/2, mainWindow.centralwidget.height/2 ) )
end

qt.exec()