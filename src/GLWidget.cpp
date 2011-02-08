#include "GLWidget.h"
#include "QObjectWrapper.h"
#include <qt/IPainter.h>

namespace qt {

	GLWidget::GLWidget() 
		: QGLWidget( QGLFormat( QGL::AlphaChannel | QGL::DoubleBuffer | QGL::Rgba, 0) )
	{
		_painter = 0;
	}

	GLWidget::~GLWidget()
	{
		// call inherited destructor
		QGLWidget::~QGLWidget();
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

	void GLWidget::setPainter( qt::IPainter* painter )
	{
		_painter = painter;
	}

	qt::IPainter* GLWidget::getPainter()
	{
		return _painter;
	}

	const Object& GLWidget::getWidget()
	{
		return QObjectWrapper( this );
	}
}

CORAL_EXPORT_COMPONENT( qt::GLWidget, GLWidget );
