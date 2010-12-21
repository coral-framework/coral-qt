/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "System_Base.h"
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
	}

	virtual ~System()
	{
		delete _app;
	}

	bool processEvents()
	{
		_app->processEvents();
		return true;
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

private:
	QApplication* _app;
};

CORAL_EXPORT_COMPONENT( System, System )
