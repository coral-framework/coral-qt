#include "GLWidget.h"
#include "EventHub.h"
#include <qt/IPainter.h>
#include <QKeyEvent>
#include <QMouseEvent>

namespace qt {

GLWidget::GLWidget() 
	: QGLWidget( QGLFormat( QGL::AlphaChannel | QGL::DoubleBuffer | QGL::Rgba, 0) )
{
	_painter = 0;
	_inputListener = 0;
	_wrapper.set( this );
    setAutoSwapBuffers( true );
}

GLWidget::~GLWidget()
{
	// empty
}

void GLWidget::setAutoSwapBuffers( bool autoSwapBuffers )
{
	setAutoBufferSwap( autoSwapBuffers );
}

bool GLWidget::getAutoSwapBuffers()
{
	return autoBufferSwap();
}

void GLWidget::setFormat( co::int32 desiredFormat )
{
	QGLWidget::setFormat( QGLFormat( static_cast<QGL::FormatOption>( desiredFormat ) ) );
}

void GLWidget::swapBuffers()
{
	QGLWidget::swapBuffers();
}

void GLWidget::makeCurrent()
{
	QGLWidget::makeCurrent();
}

void GLWidget::update()
{
	QGLWidget::update();
}

bool GLWidget::getIsValid()
{
	return QGLWidget::isValid();
}

const qt::Object& GLWidget::getWidget()
{
	return _wrapper;
}

void GLWidget::initializeGL()
{
	if( _painter.get() )
		_painter->initialize();
}

void GLWidget::paintGL()
{
	if( _painter.get() )
		_painter->paint();
}

void GLWidget::resizeGL( int w, int h )
{
	if( _painter.get() )
		_painter->resize( w, h );
}

void GLWidget::keyPressEvent( QKeyEvent* event )
{
	if( !_inputListener.get() || event->isAutoRepeat() )
	{
		event->ignore();
		return;
	}
	
	qt::KeyboardModifiers km;
	EventHub::fillKeyboardModifiers( event->modifiers(), km );

	co::Any keyCode;
	EventHub::fillKeyCodeString( event->key(), keyCode );

	_inputListener->keyPressed( keyCode.get<std::string&>(), event->text().toStdString(), km );
}

void GLWidget::keyReleaseEvent( QKeyEvent* event )
{
	if( !_inputListener.get() || event->isAutoRepeat() )
	{
		event->ignore();
		return;
	}

	qt::KeyboardModifiers km;
	EventHub::fillKeyboardModifiers( event->modifiers(), km );

	co::Any keyCode;
	EventHub::fillKeyCodeString( event->key(), keyCode );

	_inputListener->keyReleased( keyCode.get<std::string&>(), event->text().toStdString(), km );
}

void GLWidget::mousePressEvent( QMouseEvent* event )
{
	if( _inputListener.get() )
	{
		qt::KeyboardModifiers modifiers;
		EventHub::fillKeyboardModifiers( event->modifiers(), modifiers );
		_inputListener->mousePressed( event->x(), event->y(), event->button(), modifiers );
	}
	else
		event->ignore();
}

void GLWidget::mouseReleaseEvent( QMouseEvent* event )
{
	if( _inputListener.get() )
	{
		qt::KeyboardModifiers modifiers;
		EventHub::fillKeyboardModifiers( event->modifiers(), modifiers );
		_inputListener->mouseReleased( event->x(), event->y(), event->button(), modifiers );
	}
	else
		event->ignore();
}

void GLWidget::mouseMoveEvent( QMouseEvent* event )
{
	if( _inputListener.get() )
	{
		qt::KeyboardModifiers modifiers;
		EventHub::fillKeyboardModifiers( event->modifiers(), modifiers );
		_inputListener->mouseMoved( event->x(), event->y(), event->buttons(), modifiers );
	}
	else
		event->ignore();
}

void GLWidget::mouseDoubleClickEvent( QMouseEvent* event )
{
	if( _inputListener.get() )
	{
		qt::KeyboardModifiers modifiers;
		EventHub::fillKeyboardModifiers( event->modifiers(), modifiers );
		_inputListener->mouseDoubleClicked( event->x(), event->y(), event->button(), modifiers );
	}
	else
		event->ignore();
}

void GLWidget::wheelEvent( QWheelEvent* event )
{
	if( _inputListener.get() )
	{
		qt::KeyboardModifiers modifiers;
		EventHub::fillKeyboardModifiers( event->modifiers(), modifiers );
		_inputListener->mouseWheel( event->x(), event->y(), event->delta(), modifiers );
	}
	else
		event->ignore();
}

qt::IPainter* GLWidget::getPainterService()
{
	return _painter.get();
}

void GLWidget::setPainterService( IPainter* painter )
{
	_painter = painter;
}

IInputListener* GLWidget::getInputListenerService()
{
	return _inputListener.get();
}

void GLWidget::setInputListenerService( IInputListener* inputListener )
{
	_inputListener = inputListener;
}

CORAL_EXPORT_COMPONENT( GLWidget, GLWidget );

} // namespace qt

