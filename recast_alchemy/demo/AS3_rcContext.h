
#include "DetourNavMesh.h"
#include "Recast.h"
#include "AS3.h"

class AS3_rcContext : public rcContext
{
public:
	//override log
	void log(const rcLogCategory category, const char* format, ...)
	{
		AS3_Val message = AS3_String(format);
		AS3_Trace(message);
	}

protected:
	//override base log
	virtual void doLog(const rcLogCategory /*category*/, const char* msg, const int /*len*/) 
	{
		AS3_Val message = AS3_String(msg);
		AS3_Trace(message);
	}
};