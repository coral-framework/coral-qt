#include "Timer.h"

namespace qt {

Timer::Timer( ITimerCallback* callback ) : _callback( callback )
{
    // empty
}

void Timer::start( int msec )
{
	_basicTimer.start( msec, this );
}

void Timer::stop()
{
	_basicTimer.stop();
}

void Timer::timerEvent( QTimerEvent* e )
{
	notify( _lastEvent.restart() / 1000.0 );
}

} // namespace qt
