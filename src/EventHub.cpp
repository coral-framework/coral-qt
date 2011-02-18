/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "EventHub.h"
#include <QEvent>
#include <QVariant>

EventHub::EventHub()
{
	// empty
}

EventHub::~EventHub()
{
	for( int i = 0; i < _filteredObjects.size(); ++i )
		delete _filteredObjects[i];
}

co::int32 EventHub::installEventHandler( const qt::Object& watched, qt::IEventHandler* handler )
{
	QObject* obj = watched.get();
	FilteredObject* filteredObj = 0;
	co::int32 index = findFilteredObject( obj );
	if( index >= 0 )
		filteredObj = _filteredObjects[index];
	else
	{
		filteredObj = new FilteredObject();
		filteredObj->watched = obj;
		_filteredObjects.push_back( filteredObj );
		index = _filteredObjects.size() - 1;
	}

	// replace or set current handler
	filteredObj->handler = handler;

	// sets installation index as a dynamic property of watched object
	// to reduce installation lookup at eventFilter()
	obj->setProperty( "__installationIndex", QVariant::fromValue( static_cast<qint32>( index ) ) );

	obj->installEventFilter( this );

	return index;
}

bool EventHub::eventFilter( QObject* watched, QEvent* event )
{
	QVariant index = watched->property( "__installationIndex" );
	co::int32 cookie = static_cast<co::int32>( index.toInt() );

	assert( cookie >= 0 && cookie < _filteredObjects.size() );
	assert( _filteredObjects[cookie] );

	_filteredObjects[cookie]->handler->onEvent( cookie, event->type(), 0, 0, 0, 0, 0, 0 );
	return false;
}

co::int32 EventHub::findFilteredObject( QObject* watched )
{
	for( int i = 0; i < _filteredObjects.size(); ++i )
		if( _filteredObjects[i]->watched == watched ) return i;

	return -1;
}
