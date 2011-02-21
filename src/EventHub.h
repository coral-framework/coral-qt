/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#ifndef _EVENTHUB_H_
#define _EVENTHUB_H_

#include <qt/Object.h>
#include <qt/IEventHandler.h>
#include <vector>

/*!
	A QObject for dispatching events to IEventHandlers.
 */
class EventHub : public QObject
{
public:
	EventHub();

	virtual ~EventHub();

	/*!
		Installs an event handler into \a watched object. The installation is
		identified by a \a cookie, which is returned as the method's result.
	 */
	co::int32 installEventHandler( const qt::Object& watched, qt::IEventHandler* handler );

protected:
	virtual bool eventFilter( QObject* watched, QEvent* event );

private:
	// searches for the object in the filtered object list
	// and retrieves position index or -1 if there
	// is no event filter installed for the object
	co::int32 findFilteredObject( QObject* watched );

private:
	static const int MAX_ARGS = 6;
	struct FilteredObject
	{
		QObject* watched;
		qt::IEventHandler* handler;
	};

	std::vector<FilteredObject*> _filteredObjects;
};

#endif // _EVENTHUB_H_
