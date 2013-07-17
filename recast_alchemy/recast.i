%{
#include "AS3/AS3.h"
#include <stdlib.h>
#include "Recast.h"
#include "DetourCrowd.h"
#include "InputGeom.h"
#include "DetourCommon.h"
#include "SoloMesh.h"
#include "Sample_TempObstacles.h"
#include "AS3/AS3.h"
#include <stdio.h>
#include <string.h>
%}

//ignore overloaded methods from Sample_TempObstacles
%ignore Sample_TempObstacles();
%ignore getTilePos(const float* pos, int& tx, int& ty);
%ignore getObstacleCount();
%ignore clearAllTempObstacles();
%ignore addTempObstacle(const float* pos);
%ignore addTempObstacle(const float* pos, const float radius, const float height );
%ignore removeTempObstacle(dtObstacleRef id);
%ignore removeTempObstacle(const float* sp, const float* sq);

//ignore from sample
%ignore Sample();
%ignore resetCommonSettings();
%ignore handleCommonSettings();

//ignore inputgeom
%ignore InputGeom();
%ignore ~InputGeom();
%ignore loadMesh(class rcContext* ctx, const char* filepath);
%ignore deleteOffMeshConnection(int i);
%ignore raycastMesh(float* src, float* dst, float& tmin);
%ignore deleteConvexVolume(int i);
%ignore save(const char* filepath);
%ignore load(class rcContext* ctx, const char* filepath);
%ignore drawOffMeshConnections(struct duDebugDraw* dd, bool hilight = false);
%ignore addOffMeshConnection(const float* spos, const float* epos, const float rad, unsigned char bidir, unsigned char area, unsigned short flags);
%ignore drawConvexVolumes(struct duDebugDraw* dd, bool hilight = false);
%ignore addConvexVolume(const float* verts, const int nverts, const float minh, const float maxh, unsigned char area);

//%include "Recast.h"
%include "AS3_rcContext.h"
%include "Sample.h"
%include "Sample_TempObstacles.h"
%include "InputGeom.h"