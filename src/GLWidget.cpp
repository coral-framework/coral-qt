#include "GLWidget.h"
#include "QObjectWrapper.h"

#include <qt/IPainter.h>
#include <qt/MouseButtons.h>
#include <qt/KeyboardModifiers.h>

#include <QKeyEvent>
#include <QMouseEvent>


// shamefully copied from EventHub.cpp

static void fillKeyboardModifiers( Qt::KeyboardModifiers modifiers, qt::KeyboardModifiers& km )
{
	km.alt = modifiers & Qt::AltModifier;
	km.meta = modifiers & Qt::MetaModifier;
	km.shift = modifiers & Qt::ShiftModifier;
	km.keypad = modifiers & Qt::KeypadModifier;
	km.control = modifiers & Qt::ControlModifier;
	km.groupSwitch = modifiers & Qt::GroupSwitchModifier;
}

static void fillMouseButtons( Qt::MouseButtons buttons, qt::MouseButtons& mb )
{
	mb.left = buttons & Qt::LeftButton;
	mb.right = buttons & Qt::RightButton;
	mb.middle = buttons & Qt::MiddleButton;
}

namespace qt {

GLWidget::GLWidget() 
	: QGLWidget( QGLFormat( QGL::AlphaChannel | QGL::DoubleBuffer | QGL::Rgba, 0) )
{
	_painter = 0;
	_inputListener = 0;
	_wrapper.set( this );
}

GLWidget::~GLWidget()
{
	// empty
}

void GLWidget::initializeGL()
{
	if( _painter )
		_painter->initialize();
}

void GLWidget::paintGL()
{
	if( _painter )
		_painter->paint();
}

void GLWidget::resizeGL( int w, int h )
{
	if( _painter )
		_painter->resize( w, h );
}

void GLWidget::keyPressEvent( QKeyEvent* event )
{
	if( _inputListener )
		_inputListener->keyPressed( event->key() );
	else
		event->ignore();
}

void GLWidget::keyReleaseEvent( QKeyEvent* event )
{
	if( _inputListener )
		_inputListener->keyReleased( event->key() );
	else
		event->ignore();
}

void GLWidget::mousePressEvent( QMouseEvent* event )
{
	if( _inputListener )
	{
		qt::KeyboardModifiers modifiers;
		fillKeyboardModifiers( event->modifiers(), modifiers );
		_inputListener->mousePressed( event->x(), event->y(), event->button(), modifiers );
	}
	else
		event->ignore();
}

void GLWidget::mouseReleaseEvent( QMouseEvent* event )
{
	if( _inputListener )
	{
		qt::KeyboardModifiers modifiers;
		fillKeyboardModifiers( event->modifiers(), modifiers );
		_inputListener->mouseReleased( event->x(), event->y(), event->button(), modifiers );
	}
	else
		event->ignore();
}

void GLWidget::mouseMoveEvent( QMouseEvent* event )
{
	if( _inputListener )
	{
		qt::KeyboardModifiers modifiers;
		fillKeyboardModifiers( event->modifiers(), modifiers );
		qt::MouseButtons buttons;
		fillMouseButtons( event->buttons(), buttons );
		_inputListener->mouseMoved( event->x(), event->y(), buttons, modifiers );
	}
	else
		event->ignore();
}

void GLWidget::mouseDoubleClickEvent( QMouseEvent* event )
{
	if( _inputListener )
	{
		qt::KeyboardModifiers modifiers;
		fillKeyboardModifiers( event->modifiers(), modifiers );
		_inputListener->mouseDoubleClicked( event->x(), event->y(), event->button(), modifiers );
	}
	else
		event->ignore();
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

const qt::Object& GLWidget::getObject()
{
	return _wrapper;
}

void GLWidget::setReceptaclePainter( IPainter* painter )
{
	_painter = painter;
}

qt::IPainter* GLWidget::getReceptaclePainter()
{
	return _painter;
}

IInputListener* GLWidget::getReceptacleInputListener()
{
	return _inputListener;
}

void GLWidget::setReceptacleInputListener( IInputListener* inputListener )
{
	_inputListener = inputListener;
}

}

CORAL_EXPORT_COMPONENT( qt::GLWidget, GLWidget );
