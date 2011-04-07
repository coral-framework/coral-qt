#ifndef _TIMECALLBACKNOTIFIER_H_
#define _TIMECALLBACKNOTIFIER_H_

#include <QTime>
#include <QTimer>

#include <co/RefVector.h>
#include <qt/ITimerCallback.h>

namespace qt
{

class TimerCallbackNotifier : public QTimer
{
    Q_OBJECT

public:
	TimerCallbackNotifier( QObject* parent = 0 );

	void addCallback( ITimerCallback* callback );
	void removeCallback( ITimerCallback* callback );

	void start( int msec );
	void stop();

	bool isEmpty() { return _callbacks.empty(); }

private slots:
	void timeout();

private:
	void notify( double dt );

	typedef co::RefVector<ITimerCallback> CallbackList;
	CallbackList _callbacks;

	inline CallbackList::iterator find( ITimerCallback* callback )
	{
		CallbackList::iterator it = _callbacks.begin();
		for( /*empty*/; it != _callbacks.end(); ++it )
		{
			if( (*it).get() == callback )
				break;
		}

		return it;
	}

private:
	QTime _userClock;
};

} // namespace qt

#endif // _TIMECALLBACKNOTIFIER_H_
