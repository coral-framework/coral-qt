#ifndef _TIMER_H_
#define _TIMER_H_

#include <co/RefPtr.h>
#include <qt/ITimerCallback.h>

#include <QTime>
#include <QObject>
#include <QBasicTimer>

namespace qt {

class Timer : public QObject
{
    Q_OBJECT

public:
	Timer( ITimerCallback* callback );

	void start( int msec );
	void stop();

protected:
	void timerEvent( QTimerEvent* e );

private:
	inline void notify( double dt )
	{
		if( _callback.isValid() )
			_callback->onTimer( dt );
	}

private:
	QTime _lastEvent;
	QBasicTimer _basicTimer;
    co::RefPtr<ITimerCallback> _callback;
};

} // namespace qt

#endif // _TIMECALLBACKNOTIFIER_H_
