#include "TimerCallbackNotifier.h"

namespace qt
{

TimerCallbackNotifier::TimerCallbackNotifier( QObject *parent ) :
	QTimer( parent )
{
	connect( this, SIGNAL( timeout() ), this, SLOT( timeout() ) );
    _callback = 0;
}

void TimerCallbackNotifier::setCallback( ITimerCallback* callback )
{
	_callback = callback;
}

void TimerCallbackNotifier::start( int msec )
{
	QTimer::start( msec );
}

void TimerCallbackNotifier::stop()
{
	QTimer::stop();
}

void TimerCallbackNotifier::timeout()
{
	int elapsedTime = _userClock.restart();
	notify( elapsedTime / 1000.0 );
}

void TimerCallbackNotifier::notify( double dt )
{
    if( _callback.get() )
        _callback->timeUpdate( dt );
}

} // namespace qt
