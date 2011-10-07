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

	void setCallback( ITimerCallback* callback );

	void start( int msec );
	void stop();

private slots:
	void timeout();

private:
	void notify( double dt );

    co::RefPtr<ITimerCallback> _callback;

private:
	QTime _userClock;
};

} // namespace qt

#endif // _TIMECALLBACKNOTIFIER_H_
