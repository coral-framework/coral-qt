/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#ifndef _QOBJECT_WRAPPER_H_
#define _QOBJECT_WRAPPER_H_

#include <QObject>

class QObjectWrapper
{

public:
	QObjectWrapper( QObject* obj ) : _obj( obj )
	{;}

	QObjectWrapper() : _obj(0)
	{;}

	void set( QObject* obj ) { _obj = obj; }
	QObject* get() { return _obj; }

private:
	QObject* _obj;
};

#endif //_QOBJECT_WRAPPER_H_
