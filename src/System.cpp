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
#include <QFileDialog>
#include <QFileInfo>
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

	void assignModelToView( qt::Object& view, qt::IAbstractItemModel* model )
	{
		QAbstractItemView* qtView = qobject_cast<QAbstractItemView*>( view.get() );
		if( !qtView )
			CORAL_THROW( qt::Exception, "cannot assign model to view: 'view' object is not a subclass of QAbstractItemView" );

		QAbstractItemModel* qtModel = dynamic_cast<QAbstractItemModel*>( model );
		if( !qtModel )
			CORAL_THROW( qt::Exception, "cannot assign model to view: 'model' object is not a subclass of QAbstractItemModel" );


		qtView->setModel( qtModel );

		// connect AbstractItemView slots to model signals (to allow signal forwarding to delegate of IAbstractItemModel)
		QObject::connect( qtView, SIGNAL( activated( const QModelIndex& ) ), qtModel, SLOT( activated( const QModelIndex& ) ) );
		QObject::connect( qtView, SIGNAL( clicked( const QModelIndex& ) ), qtModel, SLOT( clicked( const QModelIndex& ) ) );
		QObject::connect( qtView, SIGNAL( doubleClicked( const QModelIndex& ) ), qtModel, SLOT( doubleClicked( const QModelIndex& ) ) );
		QObject::connect( qtView, SIGNAL( entered( const QModelIndex& ) ), qtModel, SLOT( entered( const QModelIndex& ) ) );
		QObject::connect( qtView, SIGNAL( pressed( const QModelIndex& ) ), qtModel, SLOT( pressed( const QModelIndex& ) ) );
	}

	void createWidget( const std::string& className, const qt::Object& parent, const std::string& widgetName, qt::Object& widget )
	{
		QWidget* parentWidget = qobject_cast<QWidget*>( parent.get() );
		if( !parentWidget )
		{
			CORAL_THROW( qt::Exception, "cannot set parent for the new widget: the given parent instance is not a widget instance" );
		}

		QUiLoader loader;
		widget.set( loader.createWidget( className.c_str(), parentWidget, widgetName.c_str() ) );
	}

	void loadUi( const std::string& filePath, qt::Object& widget )
	{
		QUiLoader loader;

		QFile uiFile( filePath.c_str() );
		if( !uiFile.exists() )
			CORAL_THROW( qt::Exception, "could not open '" << filePath << "'" );

		// change app work directory to ui's base directory
		// so the ui loader can find relative icon paths
		QString savedWorkDir = QDir::currentPath();

		QFileInfo fi( filePath.c_str() );
		QDir::setCurrent( fi.absolutePath() );

		QWidget* resWidget = loader.load( &uiFile, NULL );

		// restore workdir
		QDir::setCurrent( savedWorkDir );

		if( !resWidget )
		{
			CORAL_THROW( qt::Exception, "error loading ui file '" << filePath << "'"  );

		}

		widget.set( resWidget );
	}

	void getExistingDirectory( const qt::Object& parent, const std::string& caption, const std::string& initialDir,
							   std::string& selectedDir )
	{
		QString dir = QFileDialog::getExistingDirectory( qobject_cast<QWidget*>( parent.get() ),
														 QString::fromStdString( caption ),
														 QString::fromStdString( initialDir ) );
		selectedDir = dir.toStdString();
	}

	void setSearchPaths( const std::string& prefix, co::ArrayRange<std::string const> searchPaths )
	{
		QStringList qtSearchPaths;
		while( searchPaths )
		{
			std::string path = searchPaths.getLast();
			qtSearchPaths.push_back( QString::fromStdString( path ) );
			searchPaths.popLast();
		}

		QDir::setSearchPaths( QString::fromStdString( prefix ), qtSearchPaths );
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

} // namespace qt

CORAL_EXPORT_COMPONENT( qt::System, System )
