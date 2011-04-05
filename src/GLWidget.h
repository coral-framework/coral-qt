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

	// QGLWidget methods
	void initializeGL();
	void paintGL();
	void resizeGL( int w, int h );

	// qt.IGLContext.autoSwapBuffers attribute
	void setAutoSwapBuffers( bool autoSwapBuffers );
	bool getAutoSwapBuffers();

	// qt.IGLContext methods
	void setFormat( co::int32 desiredFormat );
	void swapBuffers();
	void makeCurrent();
	void update();
	void setMouseTracking( bool enable );

	// qt.IObjecSource method
	const qt::Object& getObject();

protected:
	void keyPressEvent( QKeyEvent* event );
	void keyReleaseEvent( QKeyEvent* event );
	void mousePressEvent( QMouseEvent* event );
	void mouseReleaseEvent( QMouseEvent* event );
	void mouseMoveEvent( QMouseEvent* event );
	void mouseDoubleClickEvent( QMouseEvent* event );

protected:
	IPainter* getPainterService();
	void setPainterService( IPainter* painter );

	IInputListener* getInputListenerService();
	void setInputListenerService( IInputListener* inputListener );

private:
	IPainter*       _painter;
	IInputListener* _inputListener;
	QObjectWrapper  _wrapper;
};

} // namespace qt;

#endif // _GLWIDGET_H_
