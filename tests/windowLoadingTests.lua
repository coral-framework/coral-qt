require "testkit.unitTests"

local qt = require "qt"

local file = co.findModuleFile( "tests", "TestWindow.ui" )

function aWindowShouldBeInvisibleWhenLoaded()
	local widget = qt.loadUi( file )
	assertTrue( not widget.visible, "widget visible when opened" )
end

function shouldThrowAnExceptionWithAnInexistantFile()
	expectException( "could not open", qt.loadUi, "inexistant.ui" )
end

function shouldThrowAnExceptionWithAnInvalidFile()
	expectException( "error loading ui file", qt.loadUi, co.findModuleFile( "tests", "invalid.ui" ) )
end


