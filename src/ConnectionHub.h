/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#ifndef _CONNECTIONHUB_H_
#define _CONNECTIONHUB_H_

#include <qt/Object.h>
#include <qt/IConnectionHandler.h>
#include <QObject>
#include <vector>

/*!
	A dynamic QObject for dispatching signals to IConnectionHandlers.
	Supports an arbitrary number of connections through the use of dynamic slots.
 */
class ConnectionHub : public QObject
{
public:
	ConnectionHub();

	virtual ~ConnectionHub();

	/*!
		Creates a new dynamic slot and connects the given sender/signal to it; whenever
		the signal is emitted, the specified \a handler will be called.
		The connection is identified by a \a cookie, which is returned as the method's result.
	 */
	co::int32 connect( const qt::Object& sender, const std::string& signal, qt::IConnectionHandler* handler );

	//! Removes the connection identified by the given \a cookie.
	void disconnect( co::int32 cookie );

	//! Handles signals emissions.
	int qt_metacall( QMetaObject::Call call, int id, void **arguments );

private:
	co::int32 _baseId;

	static const int MAX_ARGS = 8;
	struct Connection
	{
		QObject* sender;
		int signalIndex;
		int argTypes[MAX_ARGS];
		co::RefPtr<qt::IConnectionHandler> handler;
	};

	std::vector<Connection*> _connections;
};

#endif // _CONNECTIONHUB_H_
