/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "ConnectionHub.h"
#include "ValueConverters.h"
#include <co/IllegalArgumentException.h>
#include <qt/Exception.h>
#include <QMetaMethod>
#include <sstream>

ConnectionHub::ConnectionHub()
{
	_baseId = QObject::metaObject()->methodCount();
}

ConnectionHub::~ConnectionHub()
{
	size_t count = _connections.size();
	for( size_t i = 0; i < count; ++i )
	{
		Connection* c = _connections[i];
		if( c )
			delete c;
	}
}

co::int32 ConnectionHub::connect( const qt::Object& sender, const std::string& signal, qt::IConnectionHandler* handler )
{
	QObject* qobj = sender.get();
	if( !qobj )
		throw co::IllegalArgumentException( "illegal null sender" );

	if( !handler )
		throw co::IllegalArgumentException( "illegal null handler" );

	QByteArray theSignal = QMetaObject::normalizedSignature( signal.c_str() );
	const QMetaObject* mo = qobj->metaObject();
	int signalIndex = mo->indexOfSignal( theSignal );
	if( signalIndex == -1 )
		CORAL_THROW( qt::Exception, "no such signal (" << theSignal.constData() << ") in the sender" );

	co::int32 cookie = static_cast<co::int32>( _connections.size() );
	if( !QMetaObject::connect( qobj, signalIndex, this, _baseId + cookie ) )
		throw qt::Exception( "QMetaObject::connect() failed unexpectedly" );

	Connection* c = new Connection;
	c->sender = qobj;
	c->signalIndex = signalIndex;
	c->handler = handler;

	// resolve the signal's argument types
	const QMetaMethod& mm = mo->method( signalIndex );
	QList<QByteArray> params = mm.parameterTypes();
	int count = params.count();
	if( count > MAX_ARGS )
		CORAL_THROW( qt::Exception, "cannot connect to signals with more than " << MAX_ARGS << " arguments" );

	int i;
	for( i = 0; i < count; ++i )
	{
		int tp = QMetaType::type( params[i].constData() );
		if( !tp )
			CORAL_THROW( qt::Exception, "signal parameter type '" << params[i].constData()
							<< "' not registered with qRegisterMetaType()" );
		c->argTypes[i] = tp;
	}

	// mark the end of the argTypes list
	if( i < MAX_ARGS )
		c->argTypes[i] = -1;

	_connections.push_back( c );

	return cookie;
}

void ConnectionHub::disconnect( co::int32 cookie )
{
	if( cookie < 0 || cookie > static_cast<co::int32>( _connections.size() ) )
		throw co::IllegalArgumentException( "illegal out-of-range cookie" );

	Connection* c = _connections[cookie];
	QMetaObject::disconnect( c->sender, c->signalIndex, this, _baseId + cookie );
	delete c;

	_connections[cookie] = NULL;
}

int ConnectionHub::qt_metacall( QMetaObject::Call call, int id, void **arguments )
{
	id = QObject::qt_metacall( call, id, arguments );
	if( id == -1 || call != QMetaObject::InvokeMetaMethod )
		return id;

	assert( id < static_cast<int>( _connections.size() ) );

	Connection* c = _connections[id];
	assert( c );

	// create the array of arguments
	co::Any args[4 * MAX_ARGS];
	for( int i = 0; i < MAX_ARGS; )
	{
		if( c->argTypes[i] == -1 )
			break;
		QMetaType::Type tp = static_cast<QMetaType::Type>( c->argTypes[i] );
		QVariant variant( tp, arguments[i + 1] );
		i += variantToAny( variant, args[i], args[i+1], args[i+2], args[i+3] );
	}

	// dispatch the signal
	c->handler->onSignal( id, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7] );

	return -1;
}
