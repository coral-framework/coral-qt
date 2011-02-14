#include "GLWidget.h"
#include "QObjectWrapper.h"
#include <qt/IPainter.h>

namespace qt {

	GLWidget::GLWidget() 
		: QGLWidget( QGLFormat( QGL::AlphaChannel | QGL::DoubleBuffer | QGL::Rgba, 0) )
	{
		_painter = 0;
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

	void GLWidget::setReceptaclePainter( IPainter* painter )
	{
		_painter = painter;
	}

	qt::IPainter* GLWidget::getReceptaclePainter()
	{
		return _painter;
	}

	const qt::Object& GLWidget::getObject()
	{
		return _wrapper;
	}
}

CORAL_EXPORT_COMPONENT( qt::GLWidget, GLWidget );
