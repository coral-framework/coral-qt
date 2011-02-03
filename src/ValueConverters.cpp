/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "ValueConverters.h"
#include <co/Any.h>
#include <co/IllegalCastException.h>
#include <co/IllegalArgumentException.h>
#include <qt/Variant.h>
#include <QVariant>
#include <sstream>

bool canConvert( const co::Any& value )
{
	co::TypeKind kind = value.getKind();
	return kind == co::TK_BOOLEAN || kind == co::TK_INT8 || kind == co::TK_UINT8
		|| kind == co::TK_INT16 || kind == co::TK_UINT16 || kind == co::TK_INT32
		|| kind == co::TK_UINT32 || kind == co::TK_INT64 || kind == co::TK_UINT64
		|| kind == co::TK_FLOAT || kind == co::TK_DOUBLE || kind == co::TK_STRING;
}

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
	case co::TK_NATIVECLASS:
	{
		if( value.getType()->getFullName() == "qt.Variant" )
			v.setValue( value.get<qt::Variant&>() ); break;
	}
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

void anyToArgument( const co::Any& any, const QByteArray& argType, QVariant& var, QGenericArgument& arg )
{
	int typeId = QMetaType::type( argType.constData() );
	switch( typeId )
	{
	case QMetaType::Void:
		CORAL_THROW( co::IllegalArgumentException, "illegal Qt type '" << argType.constData() << "'" );
		break;
	case QMetaType::Bool:
		var.setValue( any.get<bool>() );
		arg = Q_ARG( bool, *reinterpret_cast<bool*>( var.data() ) );
		break;
	case QMetaType::Int:
		var.setValue( any.get<int>() );
		arg = Q_ARG( int, *reinterpret_cast<int*>( var.data() ) );
		break;
	case QMetaType::UInt:
		var.setValue( any.get<unsigned int>() );
		arg = Q_ARG( unsigned int, *reinterpret_cast<unsigned int*>( var.data() ) );
		break;
	case QMetaType::Double:
		var.setValue( any.get<double>() );
		arg = Q_ARG( double, *reinterpret_cast<double*>( var.data() ) );
		break;
	case QMetaType::QString:
		var.setValue<QString>( any.get<const std::string&>().c_str() );
		arg = Q_ARG( QString, *reinterpret_cast<QString*>( var.data() ) );
		break;
	default:
		CORAL_THROW( co::IllegalArgumentException, "no conversion from " << any << " to " << argType.constData() );
		break;
	}
}
