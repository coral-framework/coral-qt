/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#ifndef _QOBJECTWRAPPER_H_
#define _QOBJECTWRAPPER_H_

#include <QObject>

class QObjectWrapper
{

public:
	QObjectWrapper( QObject* obj ) : _obj( obj )
	{;}

	QObjectWrapper() : _obj(0)
	{;}

	void set( QObject* obj ) { _obj = obj; }
	QObject* get() const { return _obj; }

private:
	QObject* _obj;
};


#endif //_QOBJECTWRAPPER_H_
