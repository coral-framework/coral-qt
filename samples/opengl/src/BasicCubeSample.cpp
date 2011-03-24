#include "BasicCubeSample.h"

// MS Windows obligates windows.h to be included before gl.h
#ifdef WIN32
# include <windows.h>
#endif

#include <GL/gl.h> 
#include <GL/glu.h>

namespace opengl {

BasicCubeSample::BasicCubeSample()
{
	_pitch = 45.0;
	_yaw = 45.0;
}

BasicCubeSample::~BasicCubeSample()
{
	// empty
}

void BasicCubeSample::initialize()
{
	glEnable( GL_DEPTH_TEST );
	glDepthFunc( GL_LEQUAL );
}

void BasicCubeSample::resize( co::int32 width, co::int32 height )
{
	double aspect = height == 0 ? 1 : static_cast<double>( width ) /static_cast<double>( height );
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	gluPerspective( 45.0, aspect, 1.0, 10.0 );
	glViewport( 0, 0, width, height );
}

void BasicCubeSample::paint()
{
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	glTranslated( 0.0, 0.0, -5.0 );
	
	glRotated( _yaw, 1.0, 0.0, 0.0 ); // yaw
	glRotated( _pitch, 0.0, 1.0, 0.0 ); // pitch

	// Draw the cube's faces
	// Front face
	glBegin( GL_QUADS );
	glColor3d( 0.0, 0.0, 0.0 ); glVertex3d( -1.0, -1.0, -1.0 );
	glColor3d( 1.0, 0.0, 0.0 ); glVertex3d(  1.0, -1.0, -1.0 );
	glColor3d( 1.0, 1.0, 0.0 ); glVertex3d(  1.0,  1.0, -1.0 );
	glColor3d( 0.0, 1.0, 0.0 ); glVertex3d( -1.0,  1.0, -1.0 );
	glEnd();
	// Back face
	glBegin( GL_QUADS );
	glColor3d( 0.0, 0.0, 1.0 ); glVertex3d( -1.0, -1.0,  1.0 );
	glColor3d( 0.0, 1.0, 1.0 ); glVertex3d( -1.0,  1.0,  1.0 );
	glColor3d( 1.0, 1.0, 1.0 ); glVertex3d(  1.0,  1.0,  1.0 );
	glColor3d( 1.0, 0.0, 1.0 ); glVertex3d(  1.0, -1.0,  1.0 );
	glEnd();
    // Right face
	glBegin( GL_QUADS );
	glColor3d( 1.0, 0.0, 0.0 ); glVertex3d(  1.0, -1.0, -1.0 );
	glColor3d( 1.0, 0.0, 1.0 ); glVertex3d(  1.0, -1.0,  1.0 );
	glColor3d( 1.0, 1.0, 1.0 ); glVertex3d(  1.0,  1.0,  1.0 );
	glColor3d( 1.0, 1.0, 0.0 ); glVertex3d(  1.0,  1.0, -1.0 );
	glEnd();
	// Left face
	glBegin( GL_QUADS );
	glColor3d( 0.0, 0.0, 0.0 ); glVertex3d( -1.0, -1.0, -1.0 );
	glColor3d( 0.0, 1.0, 0.0 ); glVertex3d( -1.0,  1.0, -1.0 );
	glColor3d( 0.0, 1.0, 1.0 ); glVertex3d( -1.0,  1.0,  1.0 );
	glColor3d( 0.0, 0.0, 1.0 ); glVertex3d( -1.0, -1.0,  1.0 );
	glEnd();
	// Bottom face
	glBegin( GL_QUADS );
	glColor3d( 0.0, 0.0, 0.0 ); glVertex3d( -1.0, -1.0, -1.0 );
	glColor3d( 0.0, 0.0, 1.0 ); glVertex3d( -1.0, -1.0,  1.0 );
	glColor3d( 1.0, 0.0, 1.0 ); glVertex3d(  1.0, -1.0,  1.0 );
	glColor3d( 1.0, 0.0, 0.0 ); glVertex3d(  1.0, -1.0, -1.0 );
	glEnd();
	// Top face
	glBegin( GL_QUADS );
	glColor3d( 0.0, 1.0, 0.0 ); glVertex3d( -1.0,  1.0, -1.0 );
	glColor3d( 1.0, 1.0, 0.0 ); glVertex3d(  1.0,  1.0, -1.0 );
	glColor3d( 1.0, 1.0, 1.0 ); glVertex3d(  1.0,  1.0,  1.0 );
	glColor3d( 0.0, 1.0, 1.0 ); glVertex3d( -1.0,  1.0,  1.0 );
	glEnd();

	glFlush();
}

CORAL_EXPORT_COMPONENT( BasicCubeSample, BasicCubeSample )

} // namespace opengl

