/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "Object_Adapter.h"
#include "ValueConverters.h"
#include <co/IllegalArgumentException.h>

#include <qt/Object.h>

#include <QVariant>

#include <sstream>

void qt::Object_Adapter::getPropertyOrChild( qt::Object& instance, const std::string& name, co::Any& value )
{
	QVariant v = instance.get()->property( name.c_str() );

	if( v.isValid() )
	{
		variantToAny( v , value );
		return;
	}

	QObject* child = instance.get()->findChild<QObject*>( name.c_str() );
	value.createComplexValue<qt::Object>().set( child );
}

void qt::Object_Adapter::setProperty( qt::Object& instance, const std::string& name, const co::Any& value )
{
	instance.get()->setProperty( name.c_str(), anyToVariant( value ) );
}

void qt::Object_Adapter::invoke( qt::Object& instance, const std::string& name, const co::Any& p1,
								 const co::Any& p2, const co::Any& p3, const co::Any& p4,
								 const co::Any& p5, const co::Any& p6, const co::Any& p7 )
{
	QObject* obj = instance.get();
	bool ok = obj->metaObject()->invokeMethod( obj, name.c_str(), anyToArgument( p1 ), anyToArgument( p2 ),
											   anyToArgument( p3 ), anyToArgument( p4 ), anyToArgument( p5 ),
											   anyToArgument( p6 ), anyToArgument( p7 ) );

	if( !ok )
		CORAL_THROW( co::IllegalArgumentException, "could not invoke method " << name << " for "
												   << obj->objectName().toLatin1().data() );
}
