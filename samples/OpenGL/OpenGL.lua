-- Creates an empty 
local qt = require "qt"

-- Configures search paths
qt.setSearchPaths( "coral", co.getPaths() )

local mainWindow = qt.loadUi( "coral:/openGL/OpenGLWindow.ui" )

-- Creates the GL widget and adds it to the window
-- the code now is ugly, but I did not think of anything good yet.
local glWidget = co.new "qt.GLWidget"
glWidget.widget:setParentWidget( mainWindow.centralwidget._obj )

mainWindow.visible = true

qt.exec()
