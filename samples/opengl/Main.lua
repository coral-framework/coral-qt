-------------------------------------------------------------------------------
-- Loads the Qt module
local qt = require "qt"

-- Configures search paths
qt.setSearchPaths( "coral", co.getPaths() )

-------------------------------------------------------------------------------
-- Creates all the necessary stuff
local mainWindow = qt.loadUi "coral:/openGL/MainWindow.ui"
local glWidget   = co.new "qt.GLWidget"
local cubeSample = co.new "opengl.BasicCubeSample"

-------------------------------------------------------------------------------
-- Creates and configures the InputListener for the sample

local InputListener = require "qt.InputListener"
local SampleInputListener = InputListener( "qt.samples.opengl.SampleInputListener" )

SampleInputListener.lastx = 0
SampleInputListener.lasty = 0
SampleInputListener.target = qt.objectCast( glWidget )

function SampleInputListener:mousePressed( x, y, button )
	self.lastx = x
	self.lasty = y
end

function SampleInputListener:mouseMoved( x, y )
	cubeSample.parameters.pitch = cubeSample.parameters.pitch - ( self.lastx - x ) * 0.5
	cubeSample.parameters.yaw = cubeSample.parameters.yaw - ( self.lasty - y ) * 0.5
	self.lastx = x
	self.lasty = y
	self.target:invoke( "update()" )
end

local sampleListener = SampleInputListener{}

-------------------------------------------------------------------------------
-- Connect the interfaces

-- Adds the widget to the main window
local layout = mainWindow.centralwidget:setLayout( "QVBoxLayout" )
layout:addWidget( qt.objectCast( glWidget ) )

-- Sets the sample painter
glWidget.painter = cubeSample.painter
glWidget.inputListener = sampleListener.listener

-------------------------------------------------------------------------------
-- Start running the program
mainWindow.visible = true
qt.exec()
