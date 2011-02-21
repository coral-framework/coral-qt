/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "EventHub.h"
#include <QEvent>
#include <QVariant>
#include <QKeyEvent>
#include <QWheelEvent>
#include <QMouseEvent>
#include <QResizeEvent>

// Extract event-specific arguments to co::Any array
static void extractArguments( QEvent* event, co::Any* args, int maxArgs )
{
	switch( event->type() )
	{
	case QEvent::MouseButtonDblClick:
	case QEvent::MouseButtonPress:
	case QEvent::MouseButtonRelease:
	case QEvent::MouseMove:
		{
			QMouseEvent* mouseEvent = dynamic_cast<QMouseEvent*>( event );
			assert( mouseEvent );

			// extract position (x and y ), button, modifiers
			const QPoint& pos = mouseEvent->pos();
			args[0].set( pos.x() );
			args[1].set( pos.x() );
			args[2].set( static_cast<co::int32>( mouseEvent->button() ) );
			args[3].set( static_cast<co::int32>( mouseEvent->modifiers() ) );
			return;
		}
	case QEvent::KeyPress:
	case QEvent::KeyRelease:
		{
			QKeyEvent* keyEvent = dynamic_cast<QKeyEvent*>( event );
			assert( keyEvent );

			// extract key and modifiers
			args[0].set( keyEvent->key() );
			args[1].set( static_cast<co::int32>( keyEvent->modifiers() ) );

			return;
		}
	case QEvent::Wheel:
		{
			QWheelEvent* wheelEvent = dynamic_cast<QWheelEvent*>( event );
			assert( wheelEvent );

			// extract position (x and y ), delta, modifiers
			const QPoint& pos = wheelEvent->pos();
			args[0].set( pos.x() );
			args[1].set( pos.x() );
			args[2].set( wheelEvent->delta() );
			args[3].set( static_cast<co::int32>( wheelEvent->modifiers() ) );
			return;
		}
	case QEvent::Resize:
		{
			QResizeEvent* resizeEvent = dynamic_cast<QResizeEvent*>( event );
			assert( resizeEvent );

			// extract size (width and height) and oldSize (width and height)
			const QSize& size = resizeEvent->size();
			const QSize& oldSize = resizeEvent->oldSize();
			args[0].set( size.width() );
			args[1].set( size.height() );
			args[2].set( oldSize.width() );
			args[3].set( oldSize.height() );
			return;
		}
	default:
		// Close, Show and Hide require no arguments
		return;
	}
}

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

	co::Any args[MAX_ARGS];
	extractArguments( event, args, MAX_ARGS );

	_filteredObjects[cookie]->handler->onEvent( cookie, event->type(), args[0], args[1], args[2], args[3], args[4], args[5] );
	return false;
}

co::int32 EventHub::findFilteredObject( QObject* watched )
{
	for( int i = 0; i < _filteredObjects.size(); ++i )
		if( _filteredObjects[i]->watched == watched ) return i;

	return -1;
}
