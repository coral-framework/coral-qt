#ifndef _ROTATINGCUBESAMPLE_H_
#define _ROTATINGCUBESAMPLE_H_

#include "BasicCubeSample_Base.h"

namespace opengl{

class BasicCubeSample: public BasicCubeSample_Base
{
public:
	BasicCubeSample();
	virtual ~BasicCubeSample();
	
public:
	// qt.IPainter methods;
	void initialize();
	void resize( co::int32 width, co::int32 height );
	void paint();
	// opengl.ICubeParameters methods;
	// attribute double cubePitch
	void setPitch( double pitch ) { _pitch = pitch; }
	double getPitch() { return _pitch; }
	// attribute double cubeYaw
	void setYaw( double yaw ) { _yaw = yaw; }
	double getYaw() { return _yaw; }
private:
	double _pitch;
	double _yaw;
};
	
}; // namespace opengl

#endif // _ROTATINGCUBESAMPLE_H_
