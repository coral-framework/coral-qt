#include "TimerCallbackNotifier.h"

namespace qt
{

TimerCallbackNotifier::TimerCallbackNotifier( QObject *parent ) :
	QTimer( parent )
{
	connect( this, SIGNAL(timeout()), this, SLOT(timeout()) );
}

void TimerCallbackNotifier::addCallback( ITimerCallback* callback )
{
	if( find( callback ) != _callbacks.end() )
		return;

	_callbacks.push_back( callback );
}

void TimerCallbackNotifier::removeCallback( ITimerCallback* callback )
{
	CallbackList::iterator pos = find( callback );
	if( pos == _callbacks.end() )
		return;

	_callbacks.erase( pos );
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
	for( CallbackList::iterator it = _callbacks.begin(); it != _callbacks.end(); ++it )
		(*it)->timeUpdate( dt );
}

} // namespace qt
