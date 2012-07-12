-------------------------------------------------------------------------------
-- qt.Timer class (manages the life-cycle of a Qt timer in Lua)
-------------------------------------------------------------------------------

local system = require( "qt" ).system

-------------------------------------------------------------------------------
-- Dispatcher component (forwards timer events to a Lua closure)
-------------------------------------------------------------------------------

local Dispatcher = co.Component{
	name = 'qt.TimerDispatcher',
	provides = { callback = 'qt.ITimerCallback' },
}

function Dispatcher:onTimer( dt )
	self.closure( dt )
end

-------------------------------------------------------------------------------
-- qt.Timer class
-------------------------------------------------------------------------------
local Timer = {}

function Timer:__finalize()
	system:deleteTimer( self.timerId )
end

function Timer:start( msecs )
	system:startTimer( self.timerId, msecs )
end

function Timer:stop()
	system:stopTimer( self.timerId )
end

-- Timer class MT
local MT = { __gc = Timer.__finalize, __index = Timer }

-- module returns the Timer class constructor
return function( timerCallback )
	print( "registering function", timerCallback )
	-- handle Lua closures by creating a dispatcher
	if type( timerCallback ) == 'function' then
		timerCallback = Dispatcher{ closure = timerCallback }.callback
	end
	local cookie = system:createTimer( timerCallback )
	return setmetatable( { timerId = cookie }, MT )
end
