local qt = require "qt"

local widget = qt.loadUi( ( ... ) or "tests/TestWindow.ui" )
assert( widget )

widget.visible = true
assert( widget.visible == true, "widget not visible" )

widget.windowTitle = "Window Title"
assert( widget.windowTitle == "Window Title" )

assert( widget.btnOk ~= nil, "child widget not found" )

widget.btnOk.text = "WhAtEvEr"
assert( widget.btnOk.text == "WhAtEvEr", "could not change a child widget's property" )

-- test method invocation
local r = widget.groupBox:invoke( "setEnabled", false )
assert( widget.groupBox.enabled == false, "could not invoke method" )

-- test signal emission (no args)
local signalEmitted = false
widget.txtInput:connect( "textChanged()", function() signalEmitted = true end )
assert( signalEmitted == false )
widget.txtInput.plainText = "something"
assert( signalEmitted == true )

-- test signal emission (one arg)
local isChecked = nil
widget.checkBox:connect( "toggled(bool)", function( checked ) isChecked = checked end )
assert( isChecked == nil )
widget.checkBox.checked = true
assert( isChecked == true )
widget.checkBox.checked = false
assert( isChecked == false )
