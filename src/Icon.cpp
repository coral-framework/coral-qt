#include "Icon_Adapter.h"
#include <qt/Icon.h>

void qt::Icon_Adapter::addFile( qt::Icon& instance, const std::string& fileName, co::int32 width, co::int32 height,
								co::int32 mode, co::int32 state )
{
	instance.addFile( QString::fromStdString( fileName ), QSize( width, height ),
					  static_cast<QIcon::Mode>( mode ), static_cast<QIcon::State>( state ) );
}

bool qt::Icon_Adapter::isNull( qt::Icon& instance )
{
	return instance.isNull();
}

