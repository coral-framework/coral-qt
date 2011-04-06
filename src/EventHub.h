/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#ifndef _EVENTHUB_H_
#define _EVENTHUB_H_

#include <QMetaEnum>
#include <qt/Object.h>
#include <qt/MouseButtons.h>
#include <qt/IEventHandler.h>
#include <qt/KeyboardModifiers.h>

#include <map>

/*!
	A QObject for dispatching events to IEventHandlers.
 */
class EventHub : public QObject
{
	Q_GADGET
	Q_PROPERTY( Qt::Key _qtKeyEnum READ getKeyEnum )

public:
	static void fillKeyCodeString( int keyCode, co::Any& any );
	static void fillKeyboardModifiers( Qt::KeyboardModifiers modifiers, co::Any& any );
	static void fillKeyboardModifiers( Qt::KeyboardModifiers modifiers, qt::KeyboardModifiers& km );
	static void fillMouseButtons( Qt::MouseButtons buttons, qt::MouseButtons& mb );

public:
	//! Accessor for qt property (necessary to avoid Qt warnings)
	Qt::Key getKeyEnum() { return _qtKeyEnum; }

public:
	EventHub();

	virtual ~EventHub();

	/*!
		Installs an event handler into \a watched object. The installation is
		identified by a \a cookie, which is returned as the method's result.
	 */
	co::int64 installEventHandler( const qt::Object& watched, qt::IEventHandler* handler );

	//! Removes \a watched object from filtered objects list
	void removeEventHandler( const qt::Object& watched );

protected:
	virtual bool eventFilter( QObject* watched, QEvent* event );

private:
	// returns whether the given object is already filtered.
	void extractArguments( QEvent* event, co::Any* args, int maxArgs );
	bool isObjectFiltered( QObject* watched );
	static QMetaEnum const* initializeKeyMetaEnum();

private:
	Qt::Key _qtKeyEnum;
	static QMetaEnum const* sm_qtKeyMetaEnum;
	static const int MAX_ARGS = 6;
	typedef std::map<QObject*, qt::IEventHandler*> FilteredObjectMap;
	FilteredObjectMap _filteredObjects;
};

#endif // _EVENTHUB_H_
