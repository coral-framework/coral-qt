require "testkit.Unit"

local qt = require "qt"

qt.setSearchPaths( "coral", co.getPaths() )

local file = "coral:/TestWindow.ui"

function aWindowShouldBeInvisibleWhenLoaded()
	local widget = qt.loadUi( file )
	assertTrue( not widget.visible, "widget visible when opened" )
end

function shouldThrowAnExceptionWithAnInexistantFile()
	expectException( "could not open", qt.loadUi, "inexistant.ui" )
end

function shouldThrowAnExceptionWithAnInvalidFile()
	expectException( "error loading ui file", qt.loadUi, "coral:/invalid.ui" )
end


