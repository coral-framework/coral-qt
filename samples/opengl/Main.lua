-- Creates an empty 
local qt = require "qt"

-- Configures search paths
qt.setSearchPaths( "coral", co.getPaths() )

-- Creates all the necessary stuff
local mainWindow = qt.loadUi "coral:/opengl/MainWindow.ui"
local glWidget   = co.new "qt.GLWidget"
local cubeSample = co.new "opengl.BasicCubeSample"

-- Adds the widget to the main window
local layout = mainWindow.centralwidget:setLayout( "QVBoxLayout" )
layout:addWidget( qt.objectCast( glWidget ) )

-- Sets the sample painter
glWidget.painter = cubeSample.painter

-- Start running the program
mainWindow.visible = true
qt.exec()
