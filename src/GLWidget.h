#ifndef _GLWIDGET_H_
#define _GLWIDGET_H_

#include <QGLWidget>
#include "GLWidget_Base.h"

namespace qt {

// Forward declaration
class IPainter;

class GLWidget : public QGLWidget, public GLWidget_Base {

	Q_OBJECT

public:
	GLWidget();
	
	virtual ~GLWidget();

	virtual void initializeGL();
	
	virtual void paintGL();

	virtual void resizeGL( int w, int h );

	virtual void setParentWidget( const qt::Object& parent );

protected:
	virtual IPainter* getPainter();

	virtual void setPainter( IPainter* painter );

private:
	IPainter* _painter;
	QObjectWrapper _wrapper;
};

} // namespace qt;

#endif // _GLWIDGET_H_
