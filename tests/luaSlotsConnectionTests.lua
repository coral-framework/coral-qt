require "testkit.unitTests"

local qt = require "qt"

local file = qt.findModuleFile( "tests", "TestWindow.ui" ) 

local mockState = false
local function slotCheckedMock( checked )
	mockState = checked
end

function singleLuaFunctionCouldBeUsedAsASlotTest()
	local w = qt.loadUi( file )
	w.checkBox:connect( "toggled(bool)", slotCheckedMock )
	assertTrue( not w.checkBox.checked, "The checkbox was initialized to checked" )

	w.checkBox.checked = true

	assertTrue( mockState, "The mockState variable was not changed to the checkbox value" )
end

function multipleLuaFunctionCouldBeUsedAsSlotsTest()
	local w = qt.loadUi( file )
	local hits = 0
	w.txtInput:connect( "textChanged()", function() hits = hits + 1 end )
	w.txtInput:connect( "textChanged()", function() hits = hits + 2 end )

	w.txtInput.plainText = "changing text"

	assertEquals( hits, 3, "2 slots where connected to a signal but they where not both signaled." )
end

