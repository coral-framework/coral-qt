Event Handling
====================================

Coral-Qt module supports Object events through Lua closures. Each closure name must be in the form on{_EventName_}, where {_EventName_} is one of the values for events listed below:

- Show (onShow)
- Hide (onHide)
- Close (onClose)
- Resize (onResize)
- KeyPress (onKeyPress)
- KeyRelease (onKeyRelease)
- MousePress (onMousePress)
- MouseMove (onMouseMove)
- MouseRelease (onMouseRelease)
- MouseDoubleClick (onMouseDoubleClick)
- Wheel (onWheel)

At each event call, the source Object that originated the event is also passed as first argument. The other arguments are event-specific as shown as follow:

Example:

	-- basic events
	mainWindow.onShow = function( source ) end -- (no event-specific arguments)
	mainWindow.onHide = function( source ) end -- (no event-specific arguments)
	mainWindow.onClose = function( source ) end -- (no event-specific arguments)
	mainWindow.onResize = function( source, width, height, oldWidth, oldHeight ) end -- (new and old widget dimensions)

	-- key events
	mainWindow.onKeyPress = function( source, key, modifiers ) end
	mainWindow.onKeyRelease = function( source, key, modifiers ) end

	-- mouse events
	mainWindow.onMousePress = function( source, x, y, button, modifiers ) end
	mainWindow.onMouseMove = function( source, x, y, buttons, modifiers ) end
	mainWindow.onMouseRelease = function( source, x, y, button, modifiers ) end
	mainWindow.onMouseDoubleClick = function( source, x, y, button, modifiers ) end
	mainWindow.onWheel = function( source, x, y, delta, modifiers ) end


Keyboard Keys and modifiers
-------------------------------

Keyboard modifiers are contained into a CSL Struct with several boolean fields, one for each modifier key.
Field names are:

- alt
- meta
- shift
- keypad
- control
- groupSwitch

Modifiers example:

	local function onKeyPress( source, key, modifiers )
		if modifiers.alt then
			print( "ALT modifier is pressed!" )
		end
	end

	mainWindow.onKeyPress = onKeyPress
	...

The same is valid for mouse events:

	local function onMousePress( source, x, y, button, modifiers )
		print( "Mouse button pressed at pos", x, y )
		if modifiers.alt then
			print( "ALT modifier is pressed!" )
		end
		if modifier.control then
			print( "CONTROL modifier is pressed! )
		end
	end

	mainWindow.onMousePress = onMousePress
	...

In keyPress or keyRelease events, the key value is a string which value is one of Qt::Key enumerator entries names.

Key querying example:

	local function onKeyPress( source, key, modifiers )
		if key == "Key_A" and modifiers.control then
			selectAllText()
		elseif key == "Key_F1" then
			myHelpFunction()
		elseif key == "Key_Q" and modifiers.control then
			quitApplication()
		end
	end

	mainWindow.onKeyPress = onKeyPress
	...

