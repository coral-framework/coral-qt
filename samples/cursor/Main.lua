local qt = require "qt"

qt.setSearchPaths( "coral", co.getPaths() )

local mainWindow = qt.loadUi "coral:cursor/MainWindow.ui"
mainWindow.centralwidget:setCursor( qt.ForbiddenCursor )
mainWindow.visible = true

mainWindow.centralwidget.onMouseRelease = function( source, x, y, button, modifiers )
	if button == 1 then
		source:setCursorPosition( source:mapToGlobal( source.width/2, source.height/2 ) )
	end
	if button == 2 then
		source:unsetCursor()
	end
end

qt.exec()