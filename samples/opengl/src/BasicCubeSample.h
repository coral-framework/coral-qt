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
	
};
	
}; // namespace opengl

#endif // _ROTATINGCUBESAMPLE_H_
