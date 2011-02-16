-------------------------------------------------------------------------------
-- Returns an InputListener component prototype factory
-------------------------------------------------------------------------------

-- default empty implementation for keyboard and mouse handlers
local function defaultKeyHandler( key ) end
local function defaultMouseHandler( x, y, button ) end

return function( componentName )
	local InputListener = co.Component { name = componentName, provides = { "qt.IInputListener" } }
	
	InputListener.keyPressed = defaultKeyHandler
	InputListener.keyReleased = defaultKeyHandler
	InputListener.mousePressed = defaultMouseHandler
	InputListener.mouseReleased = defaultMouseHandler
	InputListener.mouseDoubleClicked = defaultMouseHandler
	InputListener.mouseMoved = defaultMouseHandler
	
	return InputListener
end
