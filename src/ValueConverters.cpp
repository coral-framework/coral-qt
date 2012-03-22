/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "ValueConverters.h"
#include <co/Any.h>
#include <co/IllegalCastException.h>
#include <co/IllegalArgumentException.h>
#include <qt/Variant.h>
#include <QKeySequence>
#include <QVariant>
#include <QString>
#include <sstream>

Q_DECLARE_METATYPE( Qt::Alignment )
static const int s_QtAlignmentTypeId = qRegisterMetaType<Qt::Alignment>( "Qt::Alignment" );

void anyToVariant( const co::Any& any, int expectedTypeId, QVariant& var )
{
	switch( expectedTypeId )
	{
	case QMetaType::Void:
		CORAL_THROW( co::IllegalArgumentException, "illegal Qt type '" << QMetaType::typeName( expectedTypeId ) << "'" );
		return;
	case QMetaType::Bool:
		var.setValue( any.get<bool>() );
		return;
	case QMetaType::Int:
		var.setValue( any.get<int>() );
		return;
	case QMetaType::UInt:
		var.setValue( any.get<unsigned int>() );
		return;
	case QMetaType::Double:
		var.setValue( any.get<double>() );
		return;
	case QMetaType::QString:
		var.setValue<QString>( any.get<const std::string&>().c_str() );
		return;
	case QMetaType::QIcon:
	case QMetaType::QSize:
	case QMetaType::QFont:
	case QMetaType::QPoint:
	case QMetaType::QColor:
	case QMetaType::QBrush:
        case QMetaType::QKeySequence:
            var.setValue( QKeySequence( QString( any.get<std::string&>().c_str() ) ) ); break;
	case QMetaType::QVariant:
   		switch( any.getKind() )
		{
		case co::TK_NONE:		return;
		case co::TK_BOOLEAN:	var.setValue( any.get<bool>() ); return;
		case co::TK_INT8:		var.setValue( any.get<co::int8>() ); return;
		case co::TK_UINT8:		var.setValue( any.get<co::uint8>() ); return;
		case co::TK_INT16:		var.setValue( any.get<co::int16>() ); return;
		case co::TK_UINT16:		var.setValue( any.get<co::uint16>() ); return;
		case co::TK_INT32:		var.setValue( any.get<co::int32>() ); return;
		case co::TK_UINT32:		var.setValue( any.get<co::uint32>() ); return;
		case co::TK_INT64:		var.setValue( any.get<co::int64>() ); return;
		case co::TK_UINT64:		var.setValue( any.get<co::uint64>() ); return;
		case co::TK_FLOAT:		var.setValue( any.get<float>() ); return;
		case co::TK_DOUBLE:		var.setValue( any.get<double>() ); return;
		case co::TK_STRING:		var.setValue( QString( any.get<std::string&>().c_str() ) ); return;
		case co::TK_NATIVECLASS:
		{
			if( any.getType() == co::typeOf<qt::Variant>::get() )
				var.setValue( any.get<qt::Variant&>() ); return;
		}
		default:
			CORAL_THROW( co::IllegalCastException, "cannot convert " << any << " to a QVariant." );
			return;
		}

	case QVariant::UserType:
		// check our registered type
		var = QVariant::fromValue( static_cast<Qt::Alignment>( any.get<co::int64>() ) );
		if( var.userType() == s_QtAlignmentTypeId )
			return;

	default:
		CORAL_THROW( co::IllegalArgumentException, "no conversion from " << any << " to " << QMetaType::typeName( expectedTypeId ) );
	}
}

void anyToVariant( const co::Any& any, const char* expectedTypeId, QVariant& var )
{
	int typeId = QMetaType::type( expectedTypeId );
	anyToVariant( any, typeId, var );
}

void variantToArgument( QVariant& var, QGenericArgument& arg )
{
	QVariant::Type type = var.type();
	switch( type )
	{
	case QVariant::Bool:
		arg = Q_ARG( bool, *reinterpret_cast<bool*>( var.data() ) );
	case QVariant::Int:
		arg = Q_ARG( int, *reinterpret_cast<int*>( var.data() ) );
	case QVariant::UInt:
		arg = Q_ARG( unsigned int, *reinterpret_cast<unsigned int*>( var.data() ) );
	case QVariant::Double:
		arg = Q_ARG( double, *reinterpret_cast<double*>( var.data() ) );
	case QVariant::String:
		arg = Q_ARG( QString, *reinterpret_cast<QString*>( var.data() ) );
		break;
	case QVariant::UserType:
		// check our registered type
		if( var.userType() == s_QtAlignmentTypeId )
		{
			arg = Q_ARG( Qt::Alignment, *reinterpret_cast<Qt::Alignment*>( var.data() ) );
			break;
		}
	default:
		CORAL_THROW( co::IllegalArgumentException, "no conversion from " << QMetaType::typeName( type ) << " to QGenericArgument" );
		break;
	}
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
	case QVariant::Icon:
	case QVariant::Size:
	case QVariant::Font:
	case QVariant::Point:
	case QVariant::Color:
	case QVariant::Brush:
		{
			// sets a qt::Variant into co:Any
			qt::Variant& variant = value.createComplexValue<qt::Variant>();
			variant = v;
			break;
		}
	default:
		CORAL_THROW( co::IllegalCastException, "cannot convert " << v.typeName() << " to a Coral any." );
		break;
	}
}
