/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "System_Base.h"
#include "ConnectionHub.h"
#include <qt/Exception.h>
#include <QApplication>
#include <QUiLoader>
#include <QWidget>
#include <QFile>
#include <sstream>

class System : public qt::System_Base
{
public:
	System()
	{
		int a = 0;
		_app = new QApplication( a, NULL );
		_appObj.set( _app );
	}

	virtual ~System()
	{
		delete _app;
	}

	const qt::Object& getApp() { return _appObj; }

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
	ConnectionHub _connectionHub;
};

CORAL_EXPORT_COMPONENT( System, System )
