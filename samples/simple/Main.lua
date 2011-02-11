local qt = require "qt"

-- update Qt search paths
qt.setSearchPaths( "coral", co.getPaths() )

local widget = qt.loadUi "coral:/simple/TestWindow.ui"
widget.enabled = true

widget.txtInput:connect( "textChanged()", function() widget.windowTitle = widget.txtInput.plainText end )
widget.txtInput.plainText = "write something here"

widget.checkBox:connect( "toggled(bool)", function( checked ) widget.btnOk.enabled = checked end )
widget.btnOk.enabled = false

widget.visible = true

qt.exec()

