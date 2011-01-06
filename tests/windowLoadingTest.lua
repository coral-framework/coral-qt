require "testkit.unitTests"
local lfs = require "lfs"

function aWindowShouldBeInvisibleWhenLoaded()
	local qt = require "qt"

	local widget = qt.loadUi( lfs.currentdir() .. "/../../tests/TestWindow.ui" )
	assertTrue( not widget.visible, "widget visible when opened" )
end
