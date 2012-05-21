-------------------------------------------------------------------------------
-- Loads the Qt module
local qt = require "qt"

-- Configures search paths
qt.setSearchPaths( "coral", co.getPaths() )

-------------------------------------------------------------------------------
-- Creates all the necessary stuff
local mainWindow = qt.loadUi "coral:/opengl/MainWindow.ui"
local cubeSample = co.new "opengl.BasicCubeSample"
local glWidgetObject = co.new "qt.GLWidget"
local glContext = glWidgetObject.context
local glWidget = qt.wrap( glContext.widget )

-------------------------------------------------------------------------------
-- Sets the widget format
glContext:setFormat( qt.FormatOption.Rgba + qt.FormatOption.DoubleBuffer + qt.FormatOption.AlphaChannel )

-------------------------------------------------------------------------------
-- Creates and configures the InputListener for the sample

local SampleInputListener = co.Component {
	name = "qt.samples.opengl.SampleInputListener",
	provides = { listener   = "qt.IInputListener" },
	receives = { parameters = "opengl.ICubeParameters" }
}

-- Internal attributes
SampleInputListener.lastx = 0  -- Last drag x coordinate
SampleInputListener.lasty = 0  -- Last drag y coordinate
SampleInputListener.target = glWidget -- Target widget
SampleInputListener.target.focusPolicy = qt.StrongFocus -- necessary for good keyboard interaction
SampleInputListener._params = nil -- internal reference of the opengl.ICubeParameters interface

-- The 'receives opengl.ICubeParameters' required the following two methods
function SampleInputListener:setParametersService( value )
	self._params = value
end
function SampleInputListener:getParametersService()
	return self._params
end

-- Those qt.IInputListener methods are unused; providing empty implementations
function SampleInputListener:keyPressed( key ) print( ">>>>", key ) end
function SampleInputListener:keyReleased( key ) print( ">>>>", key ) end
function SampleInputListener:mouseReleased( x, y, button, modifiers ) end
function SampleInputListener:mouseDoubleClicked( x, y, button, modifiers ) end
function SampleInputListener:mouseWheel( x, y, button, modifiers ) end

-- Handles mouse button press event
function SampleInputListener:mousePressed( x, y, button, modifiers )
	self.lastx = x
	self.lasty = y
end

-- Handles mouse motion while any mouse button is pressed
function SampleInputListener:mouseMoved( x, y, buttons, modifiers )
	-- updates the cube rotation parameters
	self._params.pitch = self._params.pitch - ( self.lastx - x ) * 0.5
	self._params.yaw   = self._params.yaw   - ( self.lasty - y ) * 0.5
	-- updates the dragging position
	self.lastx = x
	self.lasty = y
	-- triggers widget redraw
	self.target:invoke( "update()" )
end

local sampleListener = SampleInputListener{}

-------------------------------------------------------------------------------
-- Connect the interfaces

-- Adds the widget to the main window
local layout = mainWindow.centralwidget:setLayout( "QVBoxLayout" )
layout:addWidget( glWidget )

-- Sets the sample painter
glWidgetObject.painter = cubeSample.painter
glWidgetObject.inputListener = sampleListener.listener
sampleListener.parameters = cubeSample.parameters

-------------------------------------------------------------------------------
-- Start running the program
mainWindow.visible = true
qt.exec()
