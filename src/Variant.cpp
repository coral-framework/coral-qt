#include <Variant_Adapter.h>
#include <QFont>
#include <QIcon>
#include <QBrush>
#include <QColor>
#include <ValueConverters.h>

namespace qt
{

bool Variant_Adapter::isValid( qt::Variant& instance )
{
	return instance.isValid();
}

void Variant_Adapter::setAny( qt::Variant& instance, const co::Any& value )
{
	qt::Variant v;
	anyToVariant( value, QMetaType::QVariant, v );

	instance.setValue( v );
}

void Variant_Adapter::setIcon( qt::Variant& instance, const std::string& iconFilename )
{
	instance.setValue( QIcon( iconFilename.c_str() ) );
}

void Variant_Adapter::setPoint( qt::Variant& instance, co::int32 x, co::int32 y )
{
	instance.setValue( QPoint( x, y ) );
}

void Variant_Adapter::setSize( qt::Variant& instance, co::int32 width, co::int32 height )
{
	instance.setValue( QSize( width, height ) );
}

void Variant_Adapter::setColor( qt::Variant& instance, co::int32 r, co::int32 g, co::int32 b, co::int32 a )
{
	instance.setValue( QColor( r, g, b, a ) );
}

void Variant_Adapter::setBrush( qt::Variant& instance, co::int32 r, co::int32 g, co::int32 b, co::int32 a, co::int32 style )
{
	instance.setValue( QBrush( QColor( r, g, b, a ), static_cast<Qt::BrushStyle>( style ) ) );
}

void Variant_Adapter::setFont( qt::Variant& instance, const std::string& family, co::int32 pointSize, co::int32 weight, bool italic )
{
	instance.setValue( QFont( family.c_str(), pointSize, weight, italic ) );
}

} // namespace qt
