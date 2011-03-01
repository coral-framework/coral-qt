-------------------------------------------------------------------------------
-- Returns an InputListener component prototype factory
-------------------------------------------------------------------------------

-- default empty implementation for keyboard and mouse handlers
local function defaultKeyHandler( self, key ) end
local function defaultMouseHandler( self, x, y, button, modifiers ) end

return function( componentName )
	local InputListener = co.Component { name = componentName, provides = { listener = "qt.IInputListener" } }
	
	InputListener.keyPressed = defaultKeyHandler
	InputListener.keyReleased = defaultKeyHandler
	InputListener.mousePressed = defaultMouseHandler
	InputListener.mouseReleased = defaultMouseHandler
	InputListener.mouseDoubleClicked = defaultMouseHandler
	InputListener.mouseMoved = defaultMouseHandler
	InputListener.mouseWheel = defaultMouseHandler
	
	return InputListener
end
