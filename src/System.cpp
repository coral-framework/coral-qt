/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "System_Base.h"
#include "ConnectionHub.h"
#include <qt/Exception.h>
#include <qt/ItemDataRole.h>
#include <qt/IAbstractItemModel.h>
#include <QAbstractItemView>
#include <QAbstractItemModel>

#include <QStringListModel>

#include <QApplication>
#include <QUiLoader>
#include <QWidget>
#include <QFile>
#include <sstream>

namespace {
	int dummy_argc = 1;
	const char* dummy_argv[] = { "", "" };
}

namespace qt {

class System : public qt::System_Base
{
public:
	System()
	{
		_app = new QApplication( dummy_argc, const_cast<char**>( dummy_argv ) );
		_appObj.set( _app );
	}

	virtual ~System()
	{
		delete _app;
	}

	const qt::Object& getApp() { return _appObj; }

	qt::ItemDataRole getDataRoles() { return _dataRoles; }

	void assignModelToView( qt::Object& view, qt::IAbstractItemModel* model )
	{
		QAbstractItemView* qtView = qobject_cast<QAbstractItemView*>( view.get() );
		if( !qtView )
			CORAL_THROW( qt::Exception, "cannot assign model to view: 'view' object is not a subclass of QAbstractItemView" );

		QAbstractItemModel* qtModel = dynamic_cast<QAbstractItemModel*>( model );
		if( !qtModel )
			CORAL_THROW( qt::Exception, "cannot assign model to view: 'model' object is not a subclass of QAbstractItemModel" );


		qtView->setModel( qtModel );
	}

	void loadUi( const std::string& filePath, qt::Object& widget )
	{
		QUiLoader loader;

		QFile uiFile( filePath.c_str() );
		if( !uiFile.exists() )
			CORAL_THROW( qt::Exception, "could not open '" << filePath << "'" );

		QWidget* resWidget = loader.load( &uiFile, NULL );
		if( !resWidget )
			CORAL_THROW( qt::Exception, "error loading ui file '" << filePath << "'"  );

		widget.set( resWidget );
	}

	co::int32 connect( const qt::Object& sender, const std::string& signal, qt::IConnectionHandler* handler )
	{
		return _connectionHub.connect( sender, signal, handler );
	}

	void disconnect( co::int32 cookie )
	{
		_connectionHub.disconnect( cookie );
	}
	
	void exec()
	{
		_app->exec();
	}

	void processEvents()
	{
		_app->processEvents();
	}

	void quit()
	{
		_app->quit();
	}

private:
	QApplication* _app;
	qt::Object _appObj;
	qt::ItemDataRole _dataRoles;
	ConnectionHub _connectionHub;
};

} // namespace qt

CORAL_EXPORT_COMPONENT( qt::System, System )
