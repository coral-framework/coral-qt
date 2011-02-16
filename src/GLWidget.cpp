#include "GLWidget.h"
#include "QObjectWrapper.h"

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
			_inputListener->mousePressed( event->x(), event->y(), event->button() );
		else
			event->ignore();
	}

	void GLWidget::mouseReleaseEvent( QMouseEvent* event )
	{
		if( _inputListener )
			_inputListener->mouseReleased( event->x(), event->y(), event->button() );
		else
			event->ignore();
	}

	void GLWidget::mouseMoveEvent( QMouseEvent* event )
	{
		if( _inputListener )
			_inputListener->mouseMoved( event->x(), event->y() );
		else
			event->ignore();
	}

	void GLWidget::mouseDoubleClickEvent( QMouseEvent* event )
	{
		if( _inputListener )
			_inputListener->mouseDoubleClicked( event->x(), event->y(), event->button() );
		else
			event->ignore();
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
