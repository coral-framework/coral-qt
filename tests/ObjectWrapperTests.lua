local env = require "testkit.env"

local qt = require "qt"

qt.setSearchPaths( "coral", co.getPaths() )

local file = "coral:../tests/resources/TestWindow.ui"

local testWidget = 	qt.loadUi( file )

function testSingletonWrapperInstances()
	-- each time a child object is accessed, a ObjectWrapper is
	-- representing the QObject is returned. The following assert
	-- checks whether the same ObjectWrapper is returned everytime
	env.ASSERT_TRUE( testWidget.btnOk == testWidget.btnOk )
end
