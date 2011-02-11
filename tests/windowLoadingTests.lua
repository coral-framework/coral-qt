require "testkit.Unit"

local qt = require "qt"

qt.setSearchPaths( "coral", co.getPaths() )

local file = "coral:/TestWindow.ui"

function aWindowShouldBeInvisibleWhenLoaded()
	local widget = qt.loadUi( file )
	ASSERT_TRUE( not widget.visible, "widget visible when opened" )
end

function shouldThrowAnExceptionWithAnInexistantFile()
	EXPECT_EXCEPTION( "could not open", qt.loadUi, "inexistant.ui" )
end

function shouldThrowAnExceptionWithAnInvalidFile()
	EXPECT_EXCEPTION( "error loading ui file", qt.loadUi, "coral:/invalid.ui" )
end
