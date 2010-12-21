local qt = require "qt"

local widget = qt.loadUi "TestWindow.ui"

widget.visible = true
assert( widget.visible == true, "widget not visible" )

widget.windowTitle = "Window Title"
assert( widget.windowTitle == "Window Title" )

assert( widget.btnOk ~= nil, "child widget not found" )

widget.btnOk.text = "WhAtEvEr"
assert( widget.btnOk.text == "WhAtEvEr", "could not change a child widget's property" )

local r = widget:invoke( "setEnabled", false )
assert( widget.enabled == false, "could not invoke method" )

while qt.processEvents() do
	--empty
end
