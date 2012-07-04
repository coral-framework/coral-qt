/*
 * Coral Qt Module
 * See copyright notice in LICENSE.md
 */

#include "Timer.h"
#include "EventHub.h"
#include "System_Base.h"
#include "ConnectionHub.h"
#include "AbstractItemModel.h"
#include "ValueConverters.h"

#include <co/NotSupportedException.h>
#include <co/IllegalArgumentException.h>

#include <qt/Exception.h>
#include <qt/ITimerCallback.h>
#include <qt/IAbstractItemModel.h>
#include <qt/IItemSelectionModel.h>
#include <qt/IAbstractItemModelDelegate.h>

#include <QAbstractItemView>
#include <QAbstractItemModel>
#include <QStringListModel>
#include <QStackedLayout>
#include <QApplication>
#include <QInputDialog>
#include <QMainWindow>
#include <QDockWidget>
#include <QMessageBox>
#include <QFileDialog>
#include <QStatusBar>
#include <QBoxLayout>
#include <QFileInfo>
#include <QSplitter>
#include <QUiLoader>
#include <QComboBox>
#include <QToolBar>
#include <QAction>
#include <QLayout>
#include <QCursor>
#include <QLayout>
#include <QWidget>
#include <QFile>
#include <QMenu>

#include <sstream>

namespace {
	int dummy_argc = 1;
	const char* dummy_argv[] = { "", "" };
}

#define INSERT_WIDGET( element, pos, widget ) \
	if( pos >= 0 ) \
	{ \
		element->insertWidget( pos, widget ); \
	} \
	else \
	{ \
		element->addWidget( widget ); \
	}

template <class T>
T* tryCastObject( const qt::Object& instance, const std::string& errorMsg )
{
	T* t = qobject_cast<T*>( instance.get() );
	if( !t )
	{
		QString objName = "<n/a>";
		if( instance.get() )
			objName = instance.get()->objectName();

		CORAL_THROW( co::IllegalArgumentException, errorMsg << ": '" << objName.toLatin1().data() << "' is not a valid instance" );
	}

	return t;
}

namespace qt {

class System : public qt::System_Base
{
public:
	System() // must force _app initialization before _eventHub since _eventHub uses Qt qApp in constructor
		: _app( new QApplication( dummy_argc, const_cast<char**>( dummy_argv ) ) ), _eventHub()
	{
		_appObj.set( _app );
	}

	virtual ~System()
	{
		delete _app;
	}

	const qt::Object& getApp() { return _appObj; }

	void loadUi( const std::string& filePath, const qt::Object& parent, qt::Object& widget )
	{
		QWidget* parentWidget = 0;
		if( parent.get() )
			parentWidget = tryCastObject<QWidget>( parent, "cannot set parent widget" );

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

		resWidget->setParent( parentWidget );
		widget.set( resWidget );
	}

	void setSearchPaths( const std::string& prefix, co::Range<std::string const> searchPaths )
	{
		QStringList qtSearchPaths;
		while( searchPaths )
		{
			std::string path = searchPaths.getFirst();
			qtSearchPaths.push_back( path.c_str() );
			searchPaths.popFirst();
		}

		QDir::setSearchPaths( prefix.c_str(), qtSearchPaths );
	}

	void getExistingDirectory( const qt::Object& parent, const std::string& caption, const std::string& initialDir,
							   std::string& selectedDir )
	{
		QString dir = QFileDialog::getExistingDirectory( qobject_cast<QWidget*>( parent.get() ),
														 QString::fromStdString( caption ),
														 QString::fromStdString( initialDir ) );
		selectedDir = dir.toStdString();
	}

	void getOpenFileNames( const qt::Object& parent, const std::string& caption, const std::string& initialDir,
						   const std::string& filter, std::vector<std::string>& selectedFiles )
	{
		QStringList files = QFileDialog::getOpenFileNames( qobject_cast<QWidget*>( parent.get() ),
														 caption.c_str(), initialDir.c_str(), filter.c_str() );
		for( int i = 0; i < files.size(); ++i )
		{
			selectedFiles.push_back( files[i].toStdString() );
		}
	}

	void getSaveFileName( const qt::Object& parent, const std::string& caption, const std::string& initialDir,
						   const std::string& filter, std::string& selectedFile )
	{
		QString file = QFileDialog::getSaveFileName( qobject_cast<QWidget*>( parent.get() ),
														 caption.c_str(), initialDir.c_str(), filter.c_str() );
		selectedFile = file.toStdString();
	}

	bool getInputText ( const qt::Object& parent, const std::string& dialogTitle, const std::string& label, const std::string& text, std::string& result )
	{
		bool ok = false;
		QString ret = QInputDialog::getText( qobject_cast<QWidget*>( parent.get() ), QObject::tr( label.c_str() ),
											  QObject::tr( label.c_str() ), QLineEdit::Normal, text.c_str(), &ok );

		result = ret.toStdString();
		return ok;
	}

	void newInstanceOf( const std::string& className, const qt::Object& parent, qt::Object& object )
	{
		QUiLoader loader;
		QString name = className.c_str();
		QWidget* parentWidget = qobject_cast<QWidget*>( parent.get() );
		// check whether the className is a supported widget
		if( loader.availableWidgets().contains( name, Qt::CaseInsensitive ) )
		{
			object.set( loader.createWidget( name, parentWidget ) );
		}
		else if( loader.availableLayouts().contains( name, Qt::CaseInsensitive ) )
		{
			object.set( loader.createLayout( name, parentWidget ) );
		}
		else if( name == "QAction" )
		{
			object.set( loader.createAction( parentWidget ) );
		}
		else if( name == "QActionGroup" )
		{
			object.set( new QActionGroup( parentWidget ) );
		}
		else if( name == "QMessageBox" )
		{
			object.set( new QMessageBox( parentWidget ) );
		}
		else
		{
			CORAL_THROW( co::NotSupportedException,
						 "cannot create new instance for class '" << className << "': class not supported" );
		}
	}

	void addWidget( const qt::Object& parent, const qt::Object& widget )
	{
		QWidget* qwidget = tryCastObject<QWidget>( parent, "cannot add widget" );

		QLayout* qlayout = qobject_cast<QLayout*>( parent.get() );
		QSplitter* qsplitter = qobject_cast<QSplitter*>( parent.get() );
		if( qlayout )
			qlayout->addWidget( qwidget );
		else if( qsplitter )
			qsplitter->addWidget( qwidget );
		else
			CORAL_THROW( co::IllegalArgumentException, "cannot add widget: 'parent' is not an instace of QLayout nor QSplitter classs" );
	}

	void insertWidget( const qt::Object& parent, co::int32 beforeIndex, const qt::Object& widget )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot insert widget" );

		QSplitter* qsplitter = qobject_cast<QSplitter*>( parent.get() );
		QBoxLayout* qlayout = qobject_cast<QBoxLayout*>( parent.get() );
		QStatusBar* qstatusBar = qobject_cast<QStatusBar*>( parent.get() );
		QStackedLayout* qstackedLayout = qobject_cast<QStackedLayout*>( parent.get() );
		if( qsplitter )
		{
			INSERT_WIDGET( qsplitter, beforeIndex, qwidget );
		}
		else if( qlayout )
		{
			INSERT_WIDGET( qlayout, beforeIndex, qwidget );
		}
		else if( qstatusBar )
		{
			if( beforeIndex >= 0 )
			{
				qstatusBar->insertPermanentWidget( beforeIndex, qwidget );
			}
			else
			{
				qstatusBar->addPermanentWidget( qwidget );
			}
		}
		else if( qstackedLayout )
		{
			INSERT_WIDGET( qstackedLayout, beforeIndex, qwidget );
		}
		else
			CORAL_THROW( co::IllegalArgumentException, "cannot insert widget: 'parent' is not an instace of QSplitter, "
													   "QBoxLayout, QStatusBar nor QStackedLayout classs" );
	}

	void removeWidget( const qt::Object& parent, const qt::Object& widget )
	{
		QWidget* qwidget = tryCastObject<QWidget>( parent, "cannot remove widget" );

		QBoxLayout* qlayout = qobject_cast<QBoxLayout*>( parent.get() );
		QStatusBar* qstatusBar = qobject_cast<QStatusBar*>( parent.get() );
		QStackedLayout* qstackedLayout = qobject_cast<QStackedLayout*>( parent.get() );
		if( qlayout )
			qlayout->removeWidget( qwidget );
		else if( qstatusBar )
			qstatusBar->removeWidget( qwidget );
		else if( qstackedLayout )
			qstackedLayout->removeWidget( qwidget );
		else
			CORAL_THROW( co::IllegalArgumentException, "cannot remove widget: 'parent' is not an instace of "
													   "QBoxLayout, QStatusBar nor QStackedLayout classs" );

		qwidget->setParent( 0 );
	}

	void setCentralWidget( const qt::Object& parent, const qt::Object& widget )
	{
		QMainWindow* qMainWindow = tryCastObject<QMainWindow>( parent, "cannot set central widget" );
		QWidget* qWidget = tryCastObject<QWidget>( widget, "cannot set central widget" );
		qMainWindow->setCentralWidget( qWidget );
	}

    void getCentralWidget( const qt::Object& parent, qt::Object& widget )
	{
		QMainWindow* qMainWindow = tryCastObject<QMainWindow>( parent, "cannot get central widget" );
		widget.set( qMainWindow->centralWidget() );
	}

	void addDockWidget( const qt::Object& mainWindow, co::int32 dockArea, const qt::Object& dockWidget )
	{
		QMainWindow* qMainWindow = tryCastObject<QMainWindow>( mainWindow, "cannot add QDockWidget" );
		QDockWidget* qDockWidget = tryCastObject<QDockWidget>( dockWidget, "cannot add QDockWidget" );

		Qt::DockWidgetArea qDockArea = static_cast<Qt::DockWidgetArea>( dockArea );
		qMainWindow->addDockWidget( qDockArea, qDockWidget );
	}

	void setCorner( const qt::Object& mainWindow, co::int32 corner, co::int32 dockArea )
	{
		QMainWindow* qMainWindow = tryCastObject<QMainWindow>( mainWindow, "cannot set corner" );

		Qt::DockWidgetArea qDockArea = static_cast<Qt::DockWidgetArea>( dockArea );
		qMainWindow->setCorner( static_cast<Qt::Corner>( corner ), qDockArea );
	}

	void setWidget( const qt::Object& dockWidget, const qt::Object& widget )
	{
		QDockWidget* qDockWidget = tryCastObject<QDockWidget>( dockWidget, "cannot set widget" );
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot set widget" );
		qDockWidget->setWidget( qwidget );
	}

	void getToggleViewAction( const qt::Object& dockWidget, qt::Object& action )
	{
		QDockWidget* qDockWidget = tryCastObject<QDockWidget>( dockWidget, "cannot get view action" );
		action.set( qDockWidget->toggleViewAction() );
	}

	void setLayout( const qt::Object& widget, const qt::Object& layout )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot set layout" );
		QLayout* qlayout = tryCastObject<QLayout>( layout, "cannot set layout" );
		qwidget->setLayout( qlayout );
	}

	void getLayout( const qt::Object& widget, qt::Object& layout )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot get layout" );
		layout.set( qwidget->layout() );
	}

	void addActionIntoGroup( const qt::Object& actionGroup, const qt::Object& action )
	{
		QActionGroup* qActionGroup = tryCastObject<QActionGroup>( actionGroup, "cannot insert action into group" );
		QAction* qAction = tryCastObject<QAction>( action, "cannot insert action into group" );
		qActionGroup->addAction( qAction );
	}

	void insertAction( const qt::Object& widget, co::int32 beforeActionIndex, const qt::Object& action )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot insert action" );

		QAction* qaction = tryCastObject<QAction>( action, "cannot insert action" );

		if( beforeActionIndex >= 0 )
		{
			QList<QAction*> actions = qwidget->actions();
			if( beforeActionIndex >= actions.size() )
				CORAL_THROW( qt::Exception, "cannot insert action: 'beforeActionIndex' out-of-bounds" );

			qwidget->insertAction( actions[beforeActionIndex], qaction );
		}
		else
			qwidget->addAction( qaction );
	}

	void removeAction( const qt::Object& widget, const qt::Object& action )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot remove action" );

		QAction* qaction = tryCastObject<QAction>( action, "cannot remove action" );

		qwidget->removeAction( qaction );
	}

	void makeSeparator( const qt::Object& action )
	{
		QAction* qaction = tryCastObject<QAction>( action, "cannot make separator" );
		qaction->setSeparator( true );
	}

	void setMenu( const qt::Object& action, const qt::Object& menu )
	{
		QAction* qaction = tryCastObject<QAction>( action, "cannot set menu" );
		QMenu* qmenu = tryCastObject<QMenu>( menu, "cannot set menu" );
		qaction->setMenu( qmenu );
	}

	void execMenu( const qt::Object& menu, co::int32 posX, co::int32 posY, qt::Object& selectedAction )
	{
		QMenu* qmenu = tryCastObject<QMenu>( menu, "cannot exec menu" );

		QPoint p( posX, posY );
		if( posX < 0 || posY < 0 )
			p = QCursor::pos();

		QAction* selected = qmenu->exec( p );
		selectedAction.set( selected );
	}


	void insertItem( const qt::Object& comboBox, co::int32 index, const std::string& text, const co::Any& userData )
	{
		QComboBox* qcomboBox = tryCastObject<QComboBox>( comboBox, "cannot insert new item" );

		QVariant v;
		anyToVariant( userData, QMetaType::QVariant, v );

		if( index == -1 )
			qcomboBox->addItem( text.c_str(), v );
		else
			qcomboBox->insertItem( index, text.c_str(), v );
	}

	void showPopup( const qt::Object& comboBox )
	{
		QComboBox* qcomboBox = tryCastObject<QComboBox>( comboBox, "cannot show popup" );
		qcomboBox->showPopup();
	}

	void hidePopup( const qt::Object& comboBox )
	{
		QComboBox* qcomboBox = tryCastObject<QComboBox>( comboBox, "cannot hide popup" );
		qcomboBox->hidePopup();
	}

	void setCursor( const qt::Object& widget, co::int32 cursor )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot set cursor" );
		qwidget->setCursor( static_cast<Qt::CursorShape>( cursor ) );
	}

	void unsetCursor( const qt::Object& widget )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot set cursor" );
		qwidget->unsetCursor();
	}

	void setCursorPosition( const qt::Object& widget, co::int32 posX, co::int32 posY )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot set cursor position" );
		qwidget->cursor().setPos( QPoint( posX, posY ) );
	}

	void getCursorPosition( const qt::Object& widget, co::int32& posX, co::int32& posY )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot get cursor position" );

		QPoint pos = qwidget->cursor().pos();
		posX = pos.x();
		posY = pos.y();
	}

	void mapFromGlobal( const qt::Object& widget, co::int32& posX, co::int32& posY )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot get cursor position" );

		QPoint pos = qwidget->mapFromGlobal( QPoint( posX, posY ) );
		posX = pos.x();
		posY = pos.y();
	}

	void mapToGlobal( const qt::Object& widget, co::int32& posX, co::int32& posY )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot get cursor position" );

		QPoint pos = qwidget->mapToGlobal( QPoint( posX, posY ) );
		posX = pos.x();
		posY = pos.y();
	}

	void assignModelToView( qt::Object& view, qt::IAbstractItemModel* model )
	{
		QAbstractItemView* qtView = tryCastObject<QAbstractItemView>( view, "cannot assign model to view" );
		model->installModel( qtView );
	}

	void assignSelectionModelToView( qt::Object& view, qt::IItemSelectionModel* model )
	{
		QAbstractItemView* qtView = tryCastObject<QAbstractItemView>( view, "cannot assign model to view" );
		model->installSelectionModel( qtView );
	}

	void getModelFromView( const qt::Object& view, qt::IAbstractItemModel*& model  )
	{
		QAbstractItemView* qtView = tryCastObject<QAbstractItemView>( view, "cannot retrieve model from view" );
		qt::IAbstractItemModel* ptr = dynamic_cast<qt::IAbstractItemModel*>( qtView->model() );
		assert( ptr );
		model = ptr;
	}

	void getSelectionModelFromView( const qt::Object& view, qt::IItemSelectionModel*& model  )
	{
		QAbstractItemView* qtView = tryCastObject<QAbstractItemView>( view, "cannot retrieve model from view" );
		qt::IItemSelectionModel* ptr = dynamic_cast<qt::IItemSelectionModel*>( qtView->selectionModel() );
		assert( ptr );
		model = ptr;
	}

	co::int64 installEventHandler( const qt::Object& watched, qt::IEventHandler* handler )
	{
		return _eventHub.installEventHandler( watched, handler );
	}

	void grabMouse( const qt::Object& widget, co::int32 cursor )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot grab mouse" );

		qwidget->grabMouse( static_cast<Qt::CursorShape>( cursor ) );
	}

	void releaseMouse( const qt::Object& widget )
	{
		QWidget* qwidget = tryCastObject<QWidget>( widget, "cannot release mouse" );

		qwidget->releaseMouse();
	}

    co::int32 createTimer( ITimerCallback* callback )
    {
		Timer* timer = new Timer( callback );
		co::int32 timerId = static_cast<co::int32>( _timers.size() );
		_timers[timerId] = timer;
		return timerId;
    }

    void startTimer( co::int32 timerId, double milliseconds )
    {
        assert( _timers.count( timerId ) );
        Timer* timer = _timers[timerId];
        assert( timer );
        timer->start( milliseconds );
    }

    void stopTimer( co::int32 timerId )
    {
        assert( _timers.count( timerId ) );
        Timer* timer = _timers[timerId];
        assert( timer );
        timer->stop();
    }

    void deleteTimer( co::int32 timerId )
    {
        assert( _timers.count( timerId ) );
        Timer* timer = _timers[timerId];
        assert( timer );
        timer->stop();
        delete timer;
        _timers.erase( timerId );
    }

	co::int32 connect( const qt::Object& sender, const std::string& signal, qt::IConnectionHandler* handler )
	{
		return _connectionHub.connect( sender, signal, handler );
	}

	void disconnect( co::int32 cookie )
	{
		_connectionHub.disconnect( cookie );
	}

	co::int32 exec()
	{
		return _app->exec();
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
	EventHub _eventHub;
	ConnectionHub _connectionHub;
	std::map<co::int32, Timer*> _timers;
};

CORAL_EXPORT_COMPONENT( System, System )

} // namespace qt

