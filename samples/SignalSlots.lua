local qt = require "qt"

local widget = qt.loadUi "tests/TestWindow.ui"

widget.txtInput:connect( "textChanged()", function() widget.windowTitle = widget.txtInput.plainText end )
widget.txtInput.plainText = "write something here"

widget.checkBox:connect( "toggled(bool)", function( checked ) widget.btnOk.enabled = checked end )
widget.btnOk.enabled = false

widget.visible = true

qt.exec()

