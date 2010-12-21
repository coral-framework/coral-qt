/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "ValueConverters.h"
#include <QVariant>
#include <co/Any.h>
#include <sstream>
#include <co/IllegalCastException.h>

QVariant anyToVariant( const co::Any& value )
{
	QVariant v;

	switch( value.getKind() )
	{
	case co::TK_BOOLEAN:	v.setValue( value.get<bool>() ); break;
	case co::TK_INT8:		v.setValue( value.get<co::int8>() ); break;
	case co::TK_UINT8:		v.setValue( value.get<co::uint8>() ); break;
	case co::TK_INT16:		v.setValue( value.get<co::int16>() ); break;
	case co::TK_UINT16:		v.setValue( value.get<co::uint16>() ); break;
	case co::TK_INT32:		v.setValue( value.get<co::int32>() ); break;
	case co::TK_UINT32:		v.setValue( value.get<co::uint32>() ); break;
	case co::TK_INT64:		v.setValue( value.get<co::int64>() ); break;
	case co::TK_UINT64:		v.setValue( value.get<co::uint64>() ); break;
	case co::TK_FLOAT:		v.setValue( value.get<float>() ); break;
	case co::TK_DOUBLE:		v.setValue( value.get<double>() ); break;
	case co::TK_STRING:		v.setValue( QString( value.get<std::string&>().c_str() ) ); break;
	default:
		CORAL_THROW( co::IllegalCastException, "cannot convert " << value << " to a QVariant." );
		break;
	}

	return v;
}

void variantToAny( const QVariant& v, co::Any& value )
{
	if( !v.isValid() )
	{
		value = co::Any();
		return;
	}

	QVariant::Type type = v.type();
	switch( type )
	{
	case QVariant::Bool:		value.set( v.toBool() ); break;
	case QVariant::Int:			value.set( v.toInt() ); break;
	case QVariant::UInt:		value.set( v.toUInt() ); break;
	case QVariant::Double:		value.set( v.toDouble() ); break;

	case QVariant::Char:
	case QVariant::String:
	case QVariant::StringList:
	case QVariant::ByteArray:
	case QVariant::Date:
	case QVariant::Time:
	case QVariant::DateTime:
		value.createString() = v.toString().toLatin1().data();
		break;

	default:
		CORAL_THROW( co::IllegalCastException, "cannot convert " << v.typeName() << " to a Coral any." );
		break;
	}
}

QGenericArgument anyToArgument( const co::Any& value )
{
	switch( value.getKind() )
	{
	case co::TK_NONE:
		return QGenericArgument();
	case co::TK_BOOLEAN:
		return Q_ARG( bool, value.get<bool>() );
	case co::TK_INT8:
	case co::TK_INT16:
	case co::TK_INT32:
		return Q_ARG( int, value.get<co::int32>() );
	case co::TK_UINT8:
	case co::TK_UINT16:
	case co::TK_UINT32:
		return Q_ARG( int, value.get<co::uint32>() );
	case co::TK_INT64:		return Q_ARG( qint64, value.get<co::int64>() );
	case co::TK_UINT64:		return Q_ARG( quint64, value.get<co::uint64>() );
	case co::TK_FLOAT:      return Q_ARG( float, value.get<float>() );
	case co::TK_DOUBLE:		return Q_ARG( int, value.get<int>() );
	case co::TK_STRING:		return Q_ARG( const char*, value.get<std::string&>().c_str() );
	default:
		 CORAL_THROW( co::IllegalCastException, "cannot convert " << value << " to a QGenericArgument." );
		break;
	}
}
