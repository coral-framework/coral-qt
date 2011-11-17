/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include <QObjectWrapper.h>
#include <qt/Object.h>
#include "Object_Adapter.h"
#include "ValueConverters.h"
#include <co/IllegalArgumentException.h>
#include <qt/Variant.h>
#include <qt/Exception.h>
#include <QVariant>
#include <QMetaMethod>
#include <sstream>
#include <cstdio>

co::int64 qt::Object_Adapter::getHash( qt::Object& instance )
{
	return reinterpret_cast<co::int64>( instance.get() );
}

void qt::Object_Adapter::getPropertyOrChild( qt::Object& instance, const std::string& name, co::Any& value )
{
	QVariant v = instance.get()->property( name.c_str() );
	if( v.isValid() )
	{
		variantToAny( v, value );
		return;
	}

	QObject* child = instance.get()->findChild<QObject*>( name.c_str() );
	value.createComplexValue<qt::Object>().set( child );
}

void qt::Object_Adapter::setProperty( qt::Object& instance, const std::string& name, const co::Any& value )
{
	QObject* obj = instance.get();
	const QMetaObject* metaObj = obj->metaObject();
	QMetaProperty property = metaObj->property( metaObj->indexOfProperty( name.c_str() ) );

	QVariant v;
	anyToVariant( value, property.type(), v );
	instance.get()->setProperty( name.c_str(), v );
}

void qt::Object_Adapter::invoke( qt::Object& instance, const std::string& methodSignature, const co::Any& p1,
								 const co::Any& p2, const co::Any& p3, const co::Any& p4,
								 const co::Any& p5, const co::Any& p6, const co::Any& p7 )
{
	QObject* obj = instance.get();
	const QMetaObject* metaObj = obj->metaObject();
	int methodIdx = metaObj->indexOfMethod( methodSignature.c_str() );
	if( methodIdx < 0 )
		CORAL_THROW( co::IllegalArgumentException, "no such method " << metaObj->className() << "::" << methodSignature );		

	QMetaMethod mm = metaObj->method( methodIdx );
	QList<QByteArray> paramTypes = mm.parameterTypes();

	const int MAX_NUM_ARGS = 7;
	int numArgs = paramTypes.size();
	if( numArgs > MAX_NUM_ARGS )
		CORAL_THROW( co::IllegalArgumentException, "method " << metaObj->className() << "::" << methodSignature <<
					 "exceeds the limit of " << MAX_NUM_ARGS << " parameters" );

	// prepare arguments
	const co::Any* any[] = { &p1, &p2, &p3, &p4, &p5, &p6, &p7 };
	QVariant var[MAX_NUM_ARGS];
	QGenericArgument arg[MAX_NUM_ARGS];
	for( int i = 0; i < numArgs; ++i )
	{
		anyToVariant( *any[i], paramTypes[i].constData(), var[i] );
		variantToArgument( var[i], arg[i] );
	}

	bool ok = mm.invoke( obj, arg[0], arg[1], arg[2], arg[3], arg[4], arg[5], arg[6] );
	if( !ok ) 
		CORAL_THROW( co::IllegalArgumentException, "could not invoke " << metaObj->className() << "::" << methodSignature );
}
