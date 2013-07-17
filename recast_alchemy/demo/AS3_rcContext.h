
#include "DetourNavMesh.h"
#include "Recast.h"
#include "AS3/AS3.h"

class AS3_rcContext : public rcContext
{

protected:
	//override base log
	virtual void doLog(const rcLogCategory category, const char* msg, const int len) 
	{
		AS3_DeclareVar(message, String);
		AS3_CopyCStringToVar(message, msg, len);
		AS3_Trace(message);
	}
};