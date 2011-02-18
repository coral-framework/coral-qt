require "testkit.Unit"

local qt = require "qt"

local testWidget = qt.new( "QWidget" )

function testEventNotification()
	local hit = false
	testWidget:listen( qt.Event.Close, function() hit = true end )
	testWidget.visible = true
	testWidget:invoke( "close()" )
	ASSERT_TRUE( hit, "The event was not called" )
end
