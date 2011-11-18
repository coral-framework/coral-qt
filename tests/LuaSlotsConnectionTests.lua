local env = require "testkit.env"

local qt = require "qt"

qt.setSearchPaths( "coral", co.getPaths() )

local mockState = false
local function slotCheckedMock( sender, checked )
	mockState = checked
end

function singleLuaFunctionCouldBeUsedAsASlotTest()
	local w = qt.loadUi( "coral:../tests/resources/TestWindow.ui" )
	w.checkBox:connect( "toggled(bool)", slotCheckedMock )
	env.ASSERT_TRUE( not w.checkBox.checked, "The checkbox was initialized to checked" )

	w.checkBox.checked = true

	env.ASSERT_TRUE( mockState, "The mockState variable was not changed to the checkbox value" )
end

function multipleLuaFunctionCouldBeUsedAsSlotsTest()
	local w = qt.loadUi( "coral:../tests/resources/TestWindow.ui" )
	local hits = 0
	w.txtInput:connect( "textChanged()", function() hits = hits + 1 end )
	w.txtInput:connect( "textChanged()", function() hits = hits + 2 end )

	w.txtInput.plainText = "changing text"

	env.ASSERT_EQ( hits, 3, "2 slots where connected to a signal but they where not both signaled." )
end
