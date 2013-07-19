//these are the include files that will be inserted in the auto-generated wrapper class
%{
#include "AS3/AS3.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

//DebugUtils
#include "DebugDraw.h"
#include "DetourDebugDraw.h"
#include "RecastDebugDraw.h"
//#include "RecastDump.h"

//Detour
#include "DetourAlloc.h"
#include "DetourAssert.h"
#include "DetourCommon.h"
#include "DetourNavMesh.h"
#include "DetourNavMeshBuilder.h"
#include "DetourNavMeshQuery.h"
#include "DetourNode.h"
#include "DetourStatus.h"
//Detour Crowd
#include "DetourCrowd.h"
#include "DetourLocalBoundary.h"
#include "DetourObstacleAvoidance.h"
#include "DetourPathCorridor.h"
#include "DetourPathQueue.h"
#include "DetourProximityGrid.h"
//DetourTileCache
#include "DetourTileCache.h"
#include "DetourTileCacheBuilder.h"
//Recast
#include "Recast.h"
#include "RecastAlloc.h"
#include "RecastAssert.h"

	//demo
	#include "AS3_rcContext.h"
	#include "ChunkyTriMesh.h"
	#include "MeshLoaderObj.h"
	#include "InputGeom.h"
	#include "Sample.h"
	#include "Sample_TempObstacles.h"


void findNearestPoly2() __attribute__((used,
	annotate("as3sig:public function findNearestPoly2(self, center:int, extents:int, filter:int, nearestRef:int, nearestPt:int):int"),
	annotate("as3package:org.recastnavigation")));

void findNearestPoly2() {
  dtNavMeshQuery *arg1 = (dtNavMeshQuery *) 0 ;
  float *arg2 = (float *) 0 ;
  float *arg3 = (float *) 0 ;
  dtQueryFilter *arg4 = (dtQueryFilter *) 0 ;
  dtPolyRef *arg5 = (dtPolyRef *) 0 ;
  float *arg6 = (float *) 0 ;
  int arg5Loc;
  int arg6Loc;
  dtStatus result ;
  
  {
    AS3_GetScalarFromVar(arg1, self);
  }
  {
    AS3_GetScalarFromVar(arg2, center);
  }
  {
    AS3_GetScalarFromVar(arg3, extents);
  }
  {
    AS3_GetScalarFromVar(arg4, filter);
  }
  {
    AS3_GetScalarFromVar(arg5, nearestRef);
  }
  {
    AS3_GetScalarFromVar(arg6, nearestPt);
  }

//test trace
/*
   float bmin[3], bmax[3];
	dtVsub(bmin, (float const *)arg2, (float const *)arg3);
	dtVadd(bmax, (float const *)arg2, (float const *)arg3);

   AS3_DeclareVar(as3bMinX, Number);
   AS3_DeclareVar(as3bMinY, Number);
   AS3_DeclareVar(as3bMinZ, Number);
   AS3_DeclareVar(as3bMaxX, Number);
   AS3_DeclareVar(as3bMaxY, Number);
   AS3_DeclareVar(as3bMaxZ, Number);
   AS3_CopyScalarToVar( as3bMinX, bmin[0] );
   AS3_CopyScalarToVar( as3bMinY, bmin[1] );
   AS3_CopyScalarToVar( as3bMinZ, bmin[2] );

   AS3_CopyScalarToVar( as3bMaxX, bmax[0] );
   AS3_CopyScalarToVar( as3bMaxY, bmax[1] );
   AS3_CopyScalarToVar( as3bMaxZ, bmax[2] );
   AS3_Trace(as3bMinX);
   AS3_Trace(as3bMinY);
   AS3_Trace(as3bMinZ);
   AS3_Trace(as3bMaxX);
   AS3_Trace(as3bMaxY);
   AS3_Trace(as3bMaxZ);
*/

  result = (dtStatus)((dtNavMeshQuery const *)arg1)->findNearestPoly((float const *)arg2,(float const *)arg3,(dtQueryFilter const *)arg4,arg5,arg6);
  {
    AS3_DeclareVar(asresult, int);
    AS3_CopyScalarToVar(asresult, result);

    AS3_DeclareVar(asTargetRef, int);
    AS3_CopyScalarToVar(asTargetRef, arg5);
  }
  {
    AS3_ReturnAS3Var(asresult);
  }
}


%}


%rename (vertexXYZ) duDebugDraw::vertex(const float x, const float y, const float z, unsigned int color);
%rename (vertexUV) duDebugDraw::vertex(const float* pos, unsigned int color, const float* uv);
%rename (vertexXYZUV) duDebugDraw::vertex(const float x, const float y, const float z, unsigned int color, const float u, const float v);

//DebugUtils
//ignore overloaded functions
%ignore duDebugDraw::begin(duDebugDrawPrimitives,float);
%ignore duIntToCol(int,float *);
%ignore duDisplayList::begin(duDebugDrawPrimitives,float);
%ignore duDebugDrawRegionConnections(duDebugDraw *,rcContourSet const &,float const);
%ignore duDebugDrawRawContours(duDebugDraw *,rcContourSet const &,float const);
%ignore duDebugDrawContours(duDebugDraw *,rcContourSet const &,float const);

%rename (equals) dtNodePool::operator=; //rename operate= to function equals()

%ignore dtNavMesh::init(unsigned char *,int const,int const);

%include "DebugDraw.h"
%include "DetourDebugDraw.h"

%ignore duDebugDrawRegionConnections(duDebugDraw *,rcContourSet const &);
%ignore duDebugDrawRawContours(duDebugDraw *,rcContourSet const &);
%ignore duDebugDrawContours(duDebugDraw *,rcContourSet const &);
%ignore duDebugDrawLayerContours(duDebugDraw* dd, const struct rcLayerContourSet& lcset);
%ignore duDebugDrawLayerPolyMesh(duDebugDraw* dd, const struct rcLayerPolyMesh& lmesh);
%ignore duDebugDrawHeightfieldLayersRegions(duDebugDraw* dd, const struct rcHeightfieldLayerSet& lset);
%include "RecastDebugDraw.h"

%ignore duLogBuildTimes(rcContext& ctx, const int totalTileUsec);
//%include "RecastDump.h"  //commenting out for now. swig doesnt know what to do with duLogBuildTimes, even with it ignored


//Detour
%ignore dtAllocSetCustom(dtAllocFunc *allocFunc, dtFreeFunc *freeFunc);
%ignore dtAlloc(int size, dtAllocHint hint);
%ignore dtFree(void* ptr);

%ignore dtSwapEndian(unsigned short *);
%ignore dtSwapEndian(unsigned int *);
%ignore  dtSwapEndian(int *);
//%ignore  dtSwapEndian(float 

%include "DetourAlloc.h"
%include "DetourAssert.h"

%ignore dtSwapEndian(float *);

%include "DetourCommon.h"
%include "DetourNavMesh.h"
%include "DetourNavMeshBuilder.h"
%include "DetourNavMeshQuery.h"
%ignore dtNodePool::getNodeAtIdx(unsigned int) const;
%rename (equals) dtNodeQueue::operator=;
%include "DetourNode.h"
%include "DetourStatus.h"

//DetourCrowd
%include "DetourCrowd.h"
%include "DetourLocalBoundary.h"
%ignore dtObstacleAvoidanceQuery::sampleVelocityGrid(float const *,float const,float const,float const *,float const *,float *,dtObstacleAvoidanceParams const *);
%ignore dtObstacleAvoidanceQuery::sampleVelocityAdaptive(float const *,float const,float const,float const *,float const *,float *,dtObstacleAvoidanceParams const *);
%include "DetourObstacleAvoidance.h"
%include "DetourPathCorridor.h"
%include "DetourPathQueue.h"
%include "DetourProximityGrid.h"
//DetourTileCache
%include "DetourTileCache.h"
%include "DetourTileCacheBuilder.h"
//Recast
%ignore rcContext::rcContext();
%ignore rcRasterizeTriangle(rcContext *,float const *,float const *,float const *,unsigned char const,rcHeightfield &);
%ignore rcRasterizeTriangles(rcContext *,float const *,int const,int const *,unsigned char const *,int const,rcHeightfield &);
%ignore rcRasterizeTriangles(rcContext *,float const *,int const,unsigned short const *,unsigned char const *,int const,rcHeightfield &,int const);
%ignore rcRasterizeTriangles(rcContext *,float const *,int const,unsigned short const *,unsigned char const *,int const,rcHeightfield &);
%ignore rcRasterizeTriangles(rcContext *,float const *,unsigned char const *,int const,rcHeightfield &,int const);
%ignore rcRasterizeTriangles(rcContext *,float const *,unsigned char const *,int const,rcHeightfield &);
%ignore rcBuildContours(rcContext *,rcCompactHeightfield &,float const,int const,rcContourSet &);

%include "Recast.h"

%ignore rcIntArray::rcIntArray(int);
%rename (valueAt) rcIntArray::operator[];
%ignore rcIntArray::operator [](int);
%include "RecastAlloc.h"
%include "RecastAssert.h"


//demo
%include "AS3_rcContext.h"
%include "ChunkyTriMesh.h"
%include "MeshLoaderObj.h"
%include "InputGeom.h"
%include "Sample.h"
%include "Sample_TempObstacles.h"
