#include <MimeData_Adapter.h>
#include <QFont>
#include <QIcon>
#include <QBrush>
#include <QColor>
#include <qt/MimeData.h>
#include <ValueConverters.h>
#include <iostream>

namespace qt
{

void MimeData_Adapter::getData( qt::MimeData& instance, const std::string& mimeType, std::vector<std::string>& data )
{
	QMimeData* qmimeData = instance.get();
	QByteArray encodedData = qmimeData->data( mimeType.c_str() );
	QDataStream stream( &encodedData, QIODevice::ReadOnly );
	while( !stream.atEnd() ) 
	{
		QString text;
		stream >> text;
		data.push_back( text.toLatin1().data() );
	}
}

void MimeData_Adapter::setData( qt::MimeData& instance, const std::string& mimeType, co::Range<std::string const> data )
{
	QByteArray encodedData;
	QDataStream stream( &encodedData, QIODevice::WriteOnly );
	for( ; data; data.popFirst() )
	{
		stream << QString( data.getFirst().c_str() );
	}   

	instance.get()->setData( mimeType.c_str(), encodedData );
}

} // namespace qt
