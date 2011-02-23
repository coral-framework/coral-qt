require "testkit.Unit"

local qt = require "qt"

qt.setSearchPaths( "coral", co.getPaths() )

local file = "coral:/TestWindow.ui"

local testWidget = 	qt.loadUi( file )

function testSingletonWrapperInstances()
	-- each time a child object is accessed, a ObjectWrapper is
	-- representing the QObject is returned. The following assert
	-- checks whether the same ObjectWrapper is returned everytime
	ASSERT_TRUE( testWidget.btnOk == testWidget.btnOk )
end
