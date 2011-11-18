local env = require "testkit.env"

local qt = require "qt"

qt.setSearchPaths( "coral", co.getPaths() )

local file = "coral:../tests/resources/TestWindow.ui"

function aWindowShouldBeInvisibleWhenLoaded()
	local widget = qt.loadUi( file )
	env.ASSERT_TRUE( not widget.visible, "widget visible when opened" )
end
