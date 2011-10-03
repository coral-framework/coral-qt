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
#include <QCoreApplication>
#include <qt/KeyboardModifiers.h>

QMetaEnum EventHub::sm_qtKeyMetaEnum;

void EventHub::fillKeyboardModifiers( Qt::KeyboardModifiers modifiers, co::Any& any )
{
	qt::KeyboardModifiers& km = any.createComplexValue<qt::KeyboardModifiers>();
	fillKeyboardModifiers( modifiers, km );
}

void EventHub::fillKeyboardModifiers( Qt::KeyboardModifiers modifiers, qt::KeyboardModifiers& km )
{
	km.alt = modifiers & Qt::AltModifier;
	km.meta = modifiers & Qt::MetaModifier;
	km.shift = modifiers & Qt::ShiftModifier;
	km.keypad = modifiers & Qt::KeypadModifier;
	km.control = modifiers & Qt::ControlModifier;
	km.groupSwitch = modifiers & Qt::GroupSwitchModifier;
}

void EventHub::fillKeyCodeString( int keyCode, co::Any& any )
{
	const char* name = sm_qtKeyMetaEnum.valueToKey( keyCode );
	if( name )
		any.createString() = name;
}
void EventHub::fillMouseButtons( Qt::MouseButtons buttons, qt::MouseButtons& mb )
{
	mb.left = buttons & Qt::LeftButton;
	mb.right = buttons & Qt::RightButton;
	mb.middle = buttons & Qt::MiddleButton;
}

EventHub::EventHub()
{
	if( !sm_qtKeyMetaEnum.isValid() )
		sm_qtKeyMetaEnum = createKeyMetaEnum();
}

EventHub::~EventHub()
{
	// empty
}

co::int64 EventHub::installEventHandler( const qt::Object& watched, qt::IEventHandler* handler )
{
	QObject* obj = watched.get();
	if( !isObjectFiltered( obj ) )
		obj->installEventFilter( this );

	// sets/replaces event handler for the object
	_filteredObjects[obj] = handler;

	return reinterpret_cast<co::int64>( obj );
}

void EventHub::removeEventHandler( const qt::Object& watched )
{
	QObject* obj = watched.get();
	if( isObjectFiltered( obj ) )
	{
		obj->removeEventFilter( this );
		_filteredObjects.erase( obj );
	}
}

bool EventHub::eventFilter( QObject* watched, QEvent* event )
{
	assert( _filteredObjects[watched] );

	co::Any args[MAX_ARGS];
	extractArguments( event, args, MAX_ARGS );

	if( !_filteredObjects[watched]->onEvent( reinterpret_cast<co::int64>( watched ), event->type(),
										args[0], args[1], args[2], args[3], args[4], args[5] ) )
    {
        event->ignore();
    }
    
	return true;
}

// Extract event-specific arguments to co::Any array
void EventHub::extractArguments( QEvent* event, co::Any* args, int maxArgs )
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
			fillKeyboardModifiers( mouseEvent->modifiers(), args[3] );
			return;
		}
	case QEvent::KeyPress:
	case QEvent::KeyRelease:
		{
			QKeyEvent* keyEvent = dynamic_cast<QKeyEvent*>( event );
			assert( keyEvent );

			fillKeyCodeString( keyEvent->key(), args[0] );
			fillKeyboardModifiers( keyEvent->modifiers(), args[1] );
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
			fillKeyboardModifiers( wheelEvent->modifiers(), args[3] );
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

bool EventHub::isObjectFiltered( QObject* watched )
{
	return _filteredObjects.find( watched ) != _filteredObjects.end();
}

QMetaEnum EventHub::createKeyMetaEnum()
{
	const QMetaObject &mo = EventHub::staticMetaObject;
	int prop_index = mo.indexOfProperty( "_qtKeyEnum" );
	QMetaProperty metaProperty = mo.property( prop_index );
	return metaProperty.enumerator();
}
