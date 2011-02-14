-- Creates an empty 
local qt = require "qt"

-- Configures search paths
qt.setSearchPaths( "coral", co.getPaths() )

local mainWindow = qt.loadUi "coral:/openGL/OpenGLWindow.ui"
local glWidget = co.new "qt.GLWidget"
local layout = qt.new "QVBoxLayout"

-- Adds the widget to the main window
layout:addWidget( qt.objectCast( glWidget ) )
mainWindow.centralwidget:setLayout( layout )
mainWindow.visible = true

qt.exec()
