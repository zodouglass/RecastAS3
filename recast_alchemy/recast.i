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


//utility method for getting the navigation mesh triangles for debug rendering
void getTiles() __attribute__((used,
  annotate("as3sig:public function getTiles(samplePtr):Array"),
  annotate("as3package:org.recastnavigation.util")));

void getTiles() {

  Sample_TempObstacles* sample = ( Sample_TempObstacles* ) 0;
  AS3_GetScalarFromVar(sample, samplePtr);
  
  //AS3_Val result = AS3_Array("");
  inline_as3(
      "var result:Array = [];\n"
      : : 
  );
  


  const dtNavMesh* mesh = sample->getNavMesh();
  if( !mesh )
    AS3_Trace("nav mesh not defined");

  for (int i = 0; i < mesh->getMaxTiles(); ++i)
  {
    const dtMeshTile* tile = mesh->getTile(i);
    if (!tile->header) continue;
    dtPolyRef base = mesh->getPolyRefBase(tile);


    AS3_DeclareVar(vertCount, int);
    AS3_CopyScalarToVar(vertCount, tile->header->vertCount);

    inline_as3(
        "var as3polys:Array = [];\n"
        "var as3tileverts:Array = [];"
        "var as3Tile:Object = {polys: as3polys, vertCount: vertCount};\n"
        : : 
    );
    for( int l=0; l < tile->header->vertCount*3; l+=3)
    {
      AS3_DeclareVar(x, Number);
      AS3_CopyScalarToVar(x, tile->verts[l]);

      AS3_DeclareVar(y, Number);
      AS3_CopyScalarToVar(y, tile->verts[l+1]);

      AS3_DeclareVar(z, Number);
      AS3_CopyScalarToVar(z, tile->verts[l+2]);

      inline_as3(
          "var pos:Object = {x: x, y: y, z: z};\n"
          "as3tileverts.push(pos);\n"
          : : 
      );

    }

    inline_as3(
          "as3Tile.verts = as3tileverts;\n"
          "result.push(as3Tile);\n"
          : : 
      );

    for (int j = 0; j < tile->header->polyCount; ++j)
    {
      
      const dtPoly* poly = &tile->polys[j];

      // AS3_Val as3verts = AS3_Array("");
      inline_as3(
          "var as3verts:Array = [];\n"
          : : 
      );
      
      const unsigned int ip = (unsigned int)(poly - tile->polys);
      const dtPolyDetail* pd = &tile->detailMeshes[ip];
     
      for (int i = 0; i < pd->triCount; ++i)
      {
        const unsigned char* t = &tile->detailTris[(pd->triBase+i)*4];
        for (int j = 0; j < 3; ++j)
        {
          float* v;
          if (t[j] < poly->vertCount)
            v = &tile->verts[poly->verts[t[j]]*3];//dd->vertex(&tile->verts[poly->verts[t[j]]*3], c);
          else
            v = &tile->detailVerts[(pd->vertBase+t[j]-poly->vertCount)*3]; //dd->vertex(&tile->detailVerts[(pd->vertBase+t[j]-poly->vertCount)*3], c);
            
          
          AS3_DeclareVar(v0, Number);
          AS3_CopyScalarToVar(v0, v[0]);

          AS3_DeclareVar(v1, Number);
          AS3_CopyScalarToVar(v1, v[1]);

          AS3_DeclareVar(v2, Number);
          AS3_CopyScalarToVar(v2, v[2]);
          //TODO - this should get the index of the value in tile->verts, rather than creating duplicate verts.
          inline_as3(
              "as3verts.push(v0);\n"
              "as3verts.push(v1);\n"
              "as3verts.push(v2);\n"
              : : 
          );

        }
      }

     // AS3_Val as3poly = AS3_Object("triCount: IntType, verts: AS3ValType", pd->triCount, as3verts);
     // AS3_Set(as3polys, AS3_Int(j), as3poly);

      AS3_DeclareVar(triCount, int);
      AS3_CopyScalarToVar(triCount, pd->triCount);
      inline_as3(
          "var as3poly:Object = {triCount: triCount, verts: as3verts};\n"
          "as3polys.push(as3poly);\n"
          : : 
      );
    }
  }


 // return result;
  AS3_ReturnAS3Var(result);
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
%ignore passFilter(const dtPolyRef ref, const dtMeshTile* tile, const dtPoly* poly) const;
%ignore getCost(const float* pa, const float* pb,
          const dtPolyRef prevRef, const dtMeshTile* prevTile, const dtPoly* prevPoly,
          const dtPolyRef curRef, const dtMeshTile* curTile, const dtPoly* curPoly,
          const dtPolyRef nextRef, const dtMeshTile* nextTile, const dtPoly* nextPoly) const;
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
%ignore addTempObstacle(const float* pos);
%include "Sample_TempObstacles.h"
