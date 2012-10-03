/*
	Recast Navigation Alchemy Wrapper Class for AS3 (alpha)
	
	Source: https://github.com/zodouglass/RecastAS3
	By: Zo Douglass
	Email: zo@zodotcom.com

	Recastnavigation source: https://code.google.com/p/recastnavigation/
	By: Mikko Mononen
*/
#include "Recast.h"
#include "DetourCrowd.h"
#include "InputGeom.h"
#include "DetourCommon.h"
#include "SoloMesh.h"
#include "Sample_TempObstacles.h"
#include "AS3.h"
#include <stdio.h>
#include <string.h>



//

InputGeom* geom = 0;
AS3_rcContext ctx;
Sample_TempObstacles* sample;
float m_targetPos[3];


/*
  __  __   ______    _____   _    _      _____   ______   _______   _______   _____   _   _    _____    _____ 
 |  \/  | |  ____|  / ____| | |  | |    / ____| |  ____| |__   __| |__   __| |_   _| | \ | |  / ____|  / ____|
 | \  / | | |__    | (___   | |__| |   | (___   | |__       | |       | |      | |   |  \| | | |  __  | (___  
 | |\/| | |  __|    \___ \  |  __  |    \___ \  |  __|      | |       | |      | |   | . ` | | | |_ |  \___ \ 
 | |  | | | |____   ____) | | |  | |    ____) | | |____     | |       | |     _| |_  | |\  | | |__| |  ____) |
 |_|  |_| |______| |_____/  |_|  |_|   |_____/  |______|    |_|       |_|    |_____| |_| \_|  \_____| |_____/ 
                                                                                                              
                                                                                                                                                                                       
*/
static AS3_Val meshSettings(void *data, AS3_Val args)
{
	double m_cellSize = 0.3f,
	m_cellHeight = 0.2f,
	m_agentHeight = 2.0f,
	m_agentRadius = 0.6f,
	m_agentMaxClimb = 0.9f,
	m_agentMaxSlope = 45.0f,
	m_regionMinSize = 8,
	m_regionMergeSize = 20,
	m_edgeMaxLen = 12.0f,
	m_edgeMaxError = 1.3f,
	m_vertsPerPoly = 6.0f,
	m_detailSampleDist = 6.0f,
	m_detailSampleMaxError = 1.0f,
	m_tileSize = 48,
	m_maxObstacles = 128;

	int m_monotonePartitioning = 0;

	//extract args from actionscript
	AS3_ArrayValue(args, "DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType,DoubleType, DoubleType, IntType",
	 &m_cellSize, 
	 &m_cellHeight, 
	 &m_agentHeight, 
	 &m_agentRadius, 
	 &m_agentMaxClimb, 
	 &m_agentMaxSlope, 
	 &m_regionMinSize, 
	 &m_regionMergeSize, 
	 &m_edgeMaxLen, 
	 &m_edgeMaxError, 
	 &m_vertsPerPoly, 
	 &m_detailSampleDist, 
	 &m_detailSampleMaxError, 
	 &m_tileSize,
	 &m_maxObstacles,
	 &m_monotonePartitioning);

	sample->m_cellSize = m_cellSize;
	sample->m_cellHeight = m_cellHeight;
	sample->m_agentHeight = m_agentHeight;
	sample->m_agentRadius = m_agentRadius;
	sample->m_agentMaxClimb = m_agentMaxClimb;
	sample->m_agentMaxSlope = m_agentMaxSlope;
	sample->m_regionMinSize = m_regionMinSize;
	sample->m_regionMergeSize = m_regionMergeSize;
	sample->m_edgeMaxLen = m_edgeMaxLen;
	sample->m_edgeMaxError = m_edgeMaxError;
	sample->m_vertsPerPoly = m_vertsPerPoly;
	sample->m_detailSampleDist = m_detailSampleDist;
	sample->m_detailSampleMaxError = m_detailSampleMaxError;
	sample->m_monotonePartitioning = m_monotonePartitioning == 0 ? false : true;
	sample->m_tileSize = m_tileSize;
	sample->m_maxObstacles = m_maxObstacles;

	AS3_Trace(AS3_Number(m_tileSize));
	AS3_Trace(AS3_Number(sample->m_tileSize));

	return AS3_True();
}

/*
  _         ____               _____        __  __   ______    _____   _    _ 
 | |       / __ \      /\     |  __ \      |  \/  | |  ____|  / ____| | |  | |
 | |      | |  | |    /  \    | |  | |     | \  / | | |__    | (___   | |__| |
 | |      | |  | |   / /\ \   | |  | |     | |\/| | |  __|    \___ \  |  __  |
 | |____  | |__| |  / ____ \  | |__| |     | |  | | | |____   ____) | | |  | |
 |______|  \____/  /_/    \_\ |_____/      |_|  |_| |______| |_____/  |_|  |_|
                                                                              
                                                                              
*/
static AS3_Val loadMesh(void *data, AS3_Val path)
{
	char* cpath = AS3_StringValue(path);
	
	geom->loadMesh(&ctx, cpath);

	

	return AS3_True();
}

/*
  ____    _    _   _____   _        _____      __  __   ______    _____   _    _ 
 |  _ \  | |  | | |_   _| | |      |  __ \    |  \/  | |  ____|  / ____| | |  | |
 | |_) | | |  | |   | |   | |      | |  | |   | \  / | | |__    | (___   | |__| |
 |  _ <  | |  | |   | |   | |      | |  | |   | |\/| | |  __|    \___ \  |  __  |
 | |_) | | |__| |  _| |_  | |____  | |__| |   | |  | | | |____   ____) | | |  | |
 |____/   \____/  |_____| |______| |_____/    |_|  |_| |______| |_____/  |_|  |_|
                                                                                 
                                                                                 
*/
static AS3_Val buildMesh(void *data, AS3_Val args)
{
	/*  now build the nav mesh */
	
	AS3_rcContext ctx2;
	
	sample->setContext(&ctx2);
	sample->handleMeshChanged(geom);

	sample->handleSettings();
	
	if( !sample->handleBuild() )
	{
		ctx2.log(RC_LOG_WARNING, "error on sample.handleBuild");
	}

	return AS3_True();
}

static AS3_Val getTris(void *data, AS3_Val args)
{
	const rcMeshLoaderObj* mesh =  geom->getMesh();
	const int* tris = mesh->getTris();

	int ntris = mesh->getTriCount();

	//convert int array to as3 array of as3_int types
	AS3_Val arr = AS3_Array("");

	for( int i=0; i < ntris*3; i++)
	{
		AS3_Val k = AS3_Int(tris[i]);
		AS3_Set(arr, AS3_Int(i), k );
		AS3_Release(k);
	}


	return arr;
}


static AS3_Val getVerts(void *data, AS3_Val args)
{
	
	const rcMeshLoaderObj* mesh =  geom->getMesh();
	const float* verts = mesh->getVerts();

	//const int* tris = mesh->getTris();

	//int ntris = mesh->getTriCount();

	int nverts = mesh->getVertCount();

	AS3_Trace(AS3_Int(nverts));

	//convert int array to as3 array of as3_int types
	AS3_Val arr = AS3_Array("");

	for( int i=0; i < nverts; i++)
	{
		const float* v = &verts[i*3];
		AS3_Set(arr, AS3_Int(i), AS3_Object("x:DoubleType, y:DoubleType,z:DoubleType", v[0],v[1],v[2]) );
	}

	return arr;

}

//returns the vertices using a Byte Array
static AS3_Val getVerts2(void *data, AS3_Val args)
{
	const rcMeshLoaderObj* mesh =  geom->getMesh();
	const float* verts = mesh->getVerts();

	//const int* tris = mesh->getTris();

	//int ntris = mesh->getTriCount();

	int nverts = mesh->getVertCount();


	AS3_Val flash_utils_namespace = AS3_String("flash.utils");
	AS3_Val no_params = AS3_Array("");
	AS3_Val ByteArray_class = AS3_NSGetS(flash_utils_namespace, "ByteArray");
	AS3_Val outBytes = AS3_New(ByteArray_class, no_params);

	//Write bytes to byte array
	AS3_ByteArray_writeBytes(outBytes, const_cast<float*>(verts), nverts*3);


	//Clean up
	AS3_Release(flash_utils_namespace);
	AS3_Release(no_params);
	AS3_Release(ByteArray_class);

	return outBytes;
}

/*
  _____   _   _   _____   _______      _____   _____     ____   __          __  _____  
 |_   _| | \ | | |_   _| |__   __|    / ____| |  __ \   / __ \  \ \        / / |  __ \ 
   | |   |  \| |   | |      | |      | |      | |__) | | |  | |  \ \  /\  / /  | |  | |
   | |   | . ` |   | |      | |      | |      |  _  /  | |  | |   \ \/  \/ /   | |  | |
  _| |_  | |\  |  _| |_     | |      | |____  | | \ \  | |__| |    \  /\  /    | |__| |
 |_____| |_| \_| |_____|    |_|       \_____| |_|  \_\  \____/      \/  \/     |_____/ 
*/

static AS3_Val initCrowd(void *data, AS3_Val args)
{
	int maxagents = 60;
	double maxagentradius = 10.0;
	//extract args from actionscript into idx, x,y,z vars
	AS3_ArrayValue(args, "IntType, DoubleType", &maxagents, &maxagentradius);
	
	dtCrowd* crowd = sample->getCrowd();
	dtNavMesh* navmesh = sample->getNavMesh();
	bool crowdinit = crowd->init(maxagents, maxagentradius, navmesh);  //max agents, max agent radius, mesh

	// Make polygons with 'disabled' flag invalid.
	crowd->getEditableFilter()->setExcludeFlags(SAMPLE_POLYFLAGS_DISABLED);

	return AS3_True();
}

/*
  __  __    ____   __      __  ______                 _____   ______   _   _   _______ 
 |  \/  |  / __ \  \ \    / / |  ____|       /\      / ____| |  ____| | \ | | |__   __|
 | \  / | | |  | |  \ \  / /  | |__         /  \    | |  __  | |__    |  \| |    | |   
 | |\/| | | |  | |   \ \/ /   |  __|       / /\ \   | | |_ | |  __|   | . ` |    | |   
 | |  | | | |__| |    \  /    | |____     / ____ \  | |__| | | |____  | |\  |    | |   
 |_|  |_|  \____/      \/     |______|   /_/    \_\  \_____| |______| |_| \_|    |_|   
                                                                                                                                                                     
*/
static AS3_Val moveAgent(void *data, AS3_Val args)
{

	int idx=0;
	double x=0;
	double y=0;
	double z=0;
	//extract args from actionscript into idx, x,y,z vars
	AS3_ArrayValue(args, "IntType, DoubleType, DoubleType, DoubleType", &idx, &x, &y, &z);

	

	dtNavMeshQuery* navquery = sample->getNavMeshQuery();
	dtCrowd* crowd = sample->getCrowd();
	const dtQueryFilter* filter = crowd->getFilter();
	const float* ext = crowd->getQueryExtents();

	float p[3] = {x, y, z};
	

	dtPolyRef m_targetRef;
	
	dtStatus status = navquery->findNearestPoly(p, ext, filter, &m_targetRef, m_targetPos);

	
	crowd->requestMoveTarget(idx, m_targetRef, m_targetPos);

	//AS3_Trace(AS3_Number(m_targetRef));
	//AS3_Trace( AS3_Number(m_targetPos[0]));
	//AS3_Trace( AS3_Number(m_targetPos[1]));
	//AS3_Trace( AS3_Number(m_targetPos[2]));

	return AS3_True();
}

/*

requestMoveVelocity
*/
static AS3_Val requestMoveVelocity(void *data, AS3_Val args)
{
	int idx=0;
	double x=0;
	double y=0;
	double z=0;
	//extract args from actionscript into idx, x,y,z vars
	AS3_ArrayValue(args, "IntType, DoubleType, DoubleType, DoubleType", &idx, &x, &y, &z);

	dtCrowd* crowd = sample->getCrowd();

	float p[3] = {x, y, z};
	
	crowd->requestMoveVelocity(idx, p);

	return AS3_True();
}

/*
             _____    _____                  _____   ______   _   _   _______ 
     /\     |  __ \  |  __ \        /\      / ____| |  ____| | \ | | |__   __|
    /  \    | |  | | | |  | |      /  \    | |  __  | |__    |  \| |    | |   
   / /\ \   | |  | | | |  | |     / /\ \   | | |_ | |  __|   | . ` |    | |   
  / ____ \  | |__| | | |__| |    / ____ \  | |__| | | |____  | |\  |    | |   
 /_/    \_\ |_____/  |_____/    /_/    \_\  \_____| |______| |_| \_|    |_|   
                                                                              
                                                                              
*/
static AS3_Val addAgent(void *data, AS3_Val args)
{
	dtCrowd* crowd = sample->getCrowd();
	
	double x=0;
	double y=0;
	double z=0;
	double radius = 0.6;
	double height = 2.0f;
	double maxAccel = 8.0f;
	double maxSpeed = 6.5f;
	double collisionQueryRange = 12.0f;
	double pathOptimizationRange = 30.0f;
	double separationWeight = 2.0f;
	//extract args from actionscript into idx, x,y,z vars
	AS3_ArrayValue(args, "DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType,DoubleType, DoubleType, DoubleType, DoubleType", 
				&x, &y, &z,
				&radius, &height, &maxAccel, &maxSpeed, &collisionQueryRange, &pathOptimizationRange, &separationWeight);

	//AS3_Trace( AS3_Number(x));
	//AS3_Trace( AS3_Number(y));
	//AS3_Trace( AS3_Number(z));

	float p[3] = {x, y, z};

	//setup agent params
	
	dtCrowdAgentParams ap;
	memset(&ap, 0, sizeof(ap));
	//ap.radius = 10;
	//ap.height = 12;
	ap.radius = radius;
	ap.height = height;
	ap.maxAcceleration = maxAccel;
	ap.maxSpeed = maxSpeed;
	ap.collisionQueryRange = ap.radius * collisionQueryRange;
	ap.pathOptimizationRange = ap.radius * pathOptimizationRange;
	ap.updateFlags = 0; 
/*
	if (m_toolParams.m_anticipateTurns)
		ap.updateFlags |= DT_CROWD_ANTICIPATE_TURNS;
	if (m_toolParams.m_optimizeVis)
		ap.updateFlags |= DT_CROWD_OPTIMIZE_VIS;
	if (m_toolParams.m_optimizeTopo)
		ap.updateFlags |= DT_CROWD_OPTIMIZE_TOPO;
	if (m_toolParams.m_obstacleAvoidance)
		ap.updateFlags |= DT_CROWD_OBSTACLE_AVOIDANCE;
	if (m_toolParams.m_separation)
		ap.updateFlags |= DT_CROWD_SEPARATION;
	ap.obstacleAvoidanceType = (unsigned char)m_toolParams.m_obstacleAvoidanceType;
	ap.separationWeight = m_toolParams.m_separationWeight;
	*/

	//TODO - add obstacleAvoidanceType to params
	ap.obstacleAvoidanceType = 1.0f;//3.0f; //0, 3.0, 1
	//TODO - add update flags to params
	ap.updateFlags |= DT_CROWD_ANTICIPATE_TURNS;
	ap.updateFlags |= DT_CROWD_OPTIMIZE_VIS;
	ap.updateFlags |= DT_CROWD_OPTIMIZE_TOPO;
	ap.updateFlags |= DT_CROWD_OBSTACLE_AVOIDANCE;
	ap.updateFlags |= DT_CROWD_SEPARATION;
	
	ap.separationWeight = separationWeight;

	int idx = crowd->addAgent(p, &ap);

/* */
	if (idx != -1)
	{
		dtNavMeshQuery* navquery = sample->getNavMeshQuery();
		const dtQueryFilter* filter = crowd->getFilter();
		const float* ext = crowd->getQueryExtents();

		dtPolyRef m_targetRef;
		dtStatus status = navquery->findNearestPoly(p, ext, filter, &m_targetRef, m_targetPos);
		if (m_targetRef)
			crowd->requestMoveTarget(idx, m_targetRef, m_targetPos);

		//AS3_Trace( AS3_Number(m_targetPos[0]));
		//AS3_Trace( AS3_Number(m_targetPos[1]));
		//AS3_Trace( AS3_Number(m_targetPos[2]));
	}
	
	
	return AS3_Int( idx );
}

/*
  _____  ______  _______    ____   ____    _____  _______         _____  _       ______        __      __ ____  _____  _____            _   _   _____  ______ 
 / ____||  ____||__   __|  / __ \ |  _ \  / ____||__   __| /\    / ____|| |     |  ____|     /\\ \    / // __ \|_   _||  __ \    /\    | \ | | / ____||  ____|
| (___  | |__      | |    | |  | || |_) || (___     | |   /  \  | |     | |     | |__       /  \\ \  / /| |  | | | |  | |  | |  /  \   |  \| || |     | |__   
\____ \ |  __|     | |    | |  | ||  _ <  \___ \    | |  / /\ \ | |     | |     |  __|     / /\ \\ \/ / | |  | | | |  | |  | | / /\ \  | . ` || |     |  __|  
 ____) || |____    | |    | |__| || |_) | ____) |   | | / ____ \| |____ | |____ | |____   / ____ \\  /  | |__| |_| |_ | |__| |/ ____ \ | |\  || |____ | |____ 
|_____/ |______|   |_|     \____/ |____/ |_____/    |_|/_/    \_\\_____||______||______| /_/    \_\\/    \____/|_____||_____//_/    \_\|_| \_| \_____||______|
                                                                                                                                                              
        
*/
static AS3_Val setObstacleAvoidanceParams(void *data, AS3_Val args)
{
	int idx;
	dtObstacleAvoidanceParams *params = new dtObstacleAvoidanceParams();
	double velBias = 0.4f,
	weightDesVel = 2.0f,
	weightCurVel = 0.75f,
	weightSide = 0.75f,
	weightToi = 2.5f,
	horizTime = 2.5f,
	gridSize = 33,
	adaptiveDivs = 7,
	adaptiveRings = 2,
	adaptiveDepth = 5;

	//extract args from actionscript 
	AS3_ArrayValue(args, "IntType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType, DoubleType,DoubleType, DoubleType, DoubleType, DoubleType", 
				&idx,
				&velBias,
				&weightDesVel, 
				&weightCurVel,
				&weightSide, 
				&weightToi, 
				&horizTime, 
				&gridSize, 
				&adaptiveDivs, 
				&adaptiveRings, 
				&adaptiveDepth);

	params->velBias = velBias;
	params->weightDesVel =weightDesVel;
	params->weightCurVel = weightCurVel;
	params->weightSide = weightSide;
	params->weightToi = weightToi;
	params->horizTime = horizTime;
	params->gridSize = gridSize;
	params->adaptiveDivs = adaptiveDivs;
	params->adaptiveRings = adaptiveRings;
	params->adaptiveDepth = adaptiveDepth;

	//AS3_Trace(AS3_String("##### ObstacleAvoidanceParams ########"));
	//AS3_Trace(AS3_Int(idx));
	//AS3_Trace(AS3_Number(params->velBias));
	//AS3_Trace(AS3_Number(params->weightDesVel));
	//AS3_Trace(AS3_Number(params->weightCurVel));
	//AS3_Trace(AS3_Number(params->weightSide));

	dtCrowd* crowd = sample->getCrowd();
	crowd->setObstacleAvoidanceParams( idx, params);

	return AS3_True();
}

/*
  _____    ______   __  __    ____   __      __  ______                 _____   ______   _   _   _______ 
 |  __ \  |  ____| |  \/  |  / __ \  \ \    / / |  ____|       /\      / ____| |  ____| | \ | | |__   __|
 | |__) | | |__    | \  / | | |  | |  \ \  / /  | |__         /  \    | |  __  | |__    |  \| |    | |   
 |  _  /  |  __|   | |\/| | | |  | |   \ \/ /   |  __|       / /\ \   | | |_ | |  __|   | . ` |    | |   
 | | \ \  | |____  | |  | | | |__| |    \  /    | |____     / ____ \  | |__| | | |____  | |\  |    | |   
 |_|  \_\ |______| |_|  |_|  \____/      \/     |______|   /_/    \_\  \_____| |______| |_| \_|    |_|   
                                                                                                         
                                                                                                         
*/
static AS3_Val removeAgent(void *data, AS3_Val args)
{
	int idx = AS3_IntValue(args); //get the agent id from the args

	dtCrowd* crowd = sample->getCrowd();
	crowd->removeAgent(idx);
	return AS3_True();
}


/*
  _    _   _____    _____               _______   ______ 
 | |  | | |  __ \  |  __ \      /\     |__   __| |  ____|
 | |  | | | |__) | | |  | |    /  \       | |    | |__   
 | |  | | |  ___/  | |  | |   / /\ \      | |    |  __|  
 | |__| | | |      | |__| |  / ____ \     | |    | |____ 
  \____/  |_|      |_____/  /_/    \_\    |_|    |______|
                                                         
                                                         
*/
static AS3_Val update(void *data, AS3_Val args)
{
	float delta = AS3_NumberValue(args); //get the delta time
	dtCrowd* crowd = sample->getCrowd();

	dtCrowdAgentDebugInfo* debug;

	crowd->update(delta, debug);

	sample->handleUpdate(delta);

	return AS3_True();
}

/*

  _____   ______   _______                  _____   ______   _   _   _______      _____     ____     _____   _____   _______   _____    ____    _   _ 
 / ____| |  ____| |__   __|        /\      / ____| |  ____| | \ | | |__   __|    |  __ \   / __ \   / ____| |_   _| |__   __| |_   _|  / __ \  | \ | |
| |  __  | |__       | |          /  \    | |  __  | |__    |  \| |    | |       | |__) | | |  | | | (___     | |      | |      | |   | |  | | |  \| |
| | |_ | |  __|      | |         / /\ \   | | |_ | |  __|   | . ` |    | |       |  ___/  | |  | |  \___ \    | |      | |      | |   | |  | | | . ` |
| |__| | | |____     | |        / ____ \  | |__| | | |____  | |\  |    | |       | |      | |__| |  ____) |  _| |_     | |     _| |_  | |__| | | |\  |
 \_____| |______|    |_|       /_/    \_\  \_____| |______| |_| \_|    |_|       |_|       \____/  |_____/  |_____|    |_|    |_____|  \____/  |_| \_|
          
	get the memory address of an agents position                                                                                                                                                                                                              
                                                                                                                             
*/
static AS3_Val getAgentPosition(void *data, AS3_Val args)
{
	int idx = AS3_IntValue(args); //get the agent id from the args

	dtCrowd* crowd = sample->getCrowd();
	const dtCrowdAgent* crowdAgent = crowd->getAgent(idx);

	//const float* agentPos = crowdAgent->npos;


	return AS3_Ptr( const_cast<float*>(crowdAgent->npos) );
}

/*
get the memory address of an agent's velocity
*/
static AS3_Val getAgentVelocity(void *data, AS3_Val args)
{
	int idx = AS3_IntValue(args); //get the agent id from the args

	dtCrowd* crowd = sample->getCrowd();
	const dtCrowdAgent* crowdAgent = crowd->getAgent(idx);

	return AS3_Ptr( const_cast<float*>(crowdAgent->vel) );
}



/*
             _____    _____       ____    ____     _____   _______               _____   _        ______ 
     /\     |  __ \  |  __ \     / __ \  |  _ \   / ____| |__   __|     /\      / ____| | |      |  ____|
    /  \    | |  | | | |  | |   | |  | | | |_) | | (___      | |       /  \    | |      | |      | |__   
   / /\ \   | |  | | | |  | |   | |  | | |  _ <   \___ \     | |      / /\ \   | |      | |      |  __|  
  / ____ \  | |__| | | |__| |   | |__| | | |_) |  ____) |    | |     / ____ \  | |____  | |____  | |____ 
 /_/    \_\ |_____/  |_____/     \____/  |____/  |_____/     |_|    /_/    \_\  \_____| |______| |______|
                                                                                                         
                                                                                                         
*/
static AS3_Val addObstacle(void *data, AS3_Val args)
{
	double x=0;
	double y=0;
	double z=0;
	double radius=1.0;
	double height=2.0;
	//extract args from actionscript into idx, x,y,z vars
	AS3_ArrayValue(args, "DoubleType, DoubleType, DoubleType, DoubleType, DoubleType", &x, &y, &z, &radius, &height);

	float p[3] = {x, y, z};
	//AS3_Trace(AS3_String("adding obstacle"));
	//AS3_Trace(AS3_Number(p[0]));
	//AS3_Trace(AS3_Number(p[1]));
	//AS3_Trace(AS3_Number(p[2]));

	dtObstacleRef result = sample->addTempObstacle(p, radius, height);
	//int count = sample->getObstacleCount();
	//AS3_Trace(AS3_Int(count));
	return AS3_Int(result);
}

/*
  _____    ______   __  __    ____   __      __  ______      ____    ____     _____   _______               _____   _        ______ 
 |  __ \  |  ____| |  \/  |  / __ \  \ \    / / |  ____|    / __ \  |  _ \   / ____| |__   __|     /\      / ____| | |      |  ____|
 | |__) | | |__    | \  / | | |  | |  \ \  / /  | |__      | |  | | | |_) | | (___      | |       /  \    | |      | |      | |__   
 |  _  /  |  __|   | |\/| | | |  | |   \ \/ /   |  __|     | |  | | |  _ <   \___ \     | |      / /\ \   | |      | |      |  __|  
 | | \ \  | |____  | |  | | | |__| |    \  /    | |____    | |__| | | |_) |  ____) |    | |     / ____ \  | |____  | |____  | |____ 
 |_|  \_\ |______| |_|  |_|  \____/      \/     |______|    \____/  |____/  |_____/     |_|    /_/    \_\  \_____| |______| |______|
                                                                                                                                    
                                                                                                                                    
*/
static AS3_Val removeObstacle(void *data, AS3_Val args)
{
	int id = AS3_IntValue(args);
	dtObstacleRef ref = dtObstacleRef(id);
	sample->removeTempObstacle(ref);

	return AS3_True();
}


static AS3_Val getMaxTiles(void *data, AS3_Val args)
{
	dtNavMesh* navmesh = sample->getNavMesh();
	if( !navmesh )
		AS3_Trace(AS3_String("nav mesh not defined"));
	int maxTiles = navmesh->getMaxTiles();
	return AS3_Int( maxTiles );
}

/*
static AS3_Val getMesh(void *data, AS3_Val args)
{
	const rcChunkyTriMesh* chunkyTriMesh = geom->getChunkyMesh();

	rcChunkyTriMeshNode* nodes = chunkyTriMesh->nodes;

	//AS3_Object as3_nodes = AS3_Object("bmin: AS3ValType, bmax: AS3ValType, i:IntType,n:IntType");

 	

	AS3_Val minArr = AS3_Array("DoubleType", nodes->bmin);
	AS3_Val maxArr = AS3_Array("DoubleType", nodes->bmax);
	AS3_Val as3_nodes = AS3_Object("bmin:AS3ValType,bmax:AS3ValType,i:IntType,n:IntType", minArr, maxArr,nodes->i, nodes->n);

	AS3_Val result = AS3_Object("nnodes: IntType, ntris: IntType, maxTrisPerChunk: IntType, tris: PtrType, nodes: AS3ValType", 
								chunkyTriMesh->nnodes, 
								chunkyTriMesh->ntris, 
								chunkyTriMesh->maxTrisPerChunk, 
								chunkyTriMesh->tris, 
								as3_nodes);

	return result;
}
*/

/*
   _____   ______   _______     _______   _____   _        ______    _____ 
  / ____| |  ____| |__   __|   |__   __| |_   _| | |      |  ____|  / ____|
 | |  __  | |__       | |         | |      | |   | |      | |__    | (___  
 | | |_ | |  __|      | |         | |      | |   | |      |  __|    \___ \ 
 | |__| | | |____     | |         | |     _| |_  | |____  | |____   ____) |
  \_____| |______|    |_|         |_|    |_____| |______| |______| |_____/ 
                                                                           
                                                                           
*/
//used to debug draw the nav mesh
static AS3_Val getTiles(void *data, AS3_Val args)
{
	AS3_Val result = AS3_Array("");


	const dtNavMesh* mesh = sample->getNavMesh();
	if( !mesh )
		AS3_Trace(AS3_String("nav mesh not defined"));

	for (int i = 0; i < mesh->getMaxTiles(); ++i)
	{
		const dtMeshTile* tile = mesh->getTile(i);
		if (!tile->header) continue;
		dtPolyRef base = mesh->getPolyRefBase(tile);

		AS3_Val as3polys = AS3_Array("");
		AS3_Val as3Tile = AS3_Object("polys: AS3ValType", as3polys);
		AS3_SetS(as3Tile, "vertCount", AS3_Int(tile->header->vertCount));
		AS3_Val as3tileverts = AS3_Array("");
		for( int l=0; l < tile->header->vertCount*3; l+=3)
		{
			AS3_Set(as3tileverts, AS3_Int(l), AS3_Number(tile->verts[l]));
			AS3_Set(as3tileverts, AS3_Int(l+1), AS3_Number(tile->verts[l+1]));
			AS3_Set(as3tileverts, AS3_Int(l+2), AS3_Number(tile->verts[l+2]));
		}
		AS3_SetS(as3Tile, "verts", as3tileverts );
		AS3_Set(result, AS3_Int(i), as3Tile); //push tile to result array

		for (int j = 0; j < tile->header->polyCount; ++j)
		{
			
			const dtPoly* poly = &tile->polys[j];

			AS3_Val as3verts = AS3_Array("");

			
			const unsigned int ip = (unsigned int)(poly - tile->polys);
			const dtPolyDetail* pd = &tile->detailMeshes[ip];
			int vCounter = 0;
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
						
					
					//TODO - this should get the index of the value in tile-verts
					AS3_Set(as3verts, AS3_Int(vCounter), AS3_Number(v[0]));
					vCounter++;
					AS3_Set(as3verts, AS3_Int(vCounter), AS3_Number(v[1]));
					vCounter++;
					AS3_Set(as3verts, AS3_Int(vCounter), AS3_Number(v[2]));
					vCounter++;

				}
			}

			AS3_Val as3poly = AS3_Object("triCount: IntType, verts: AS3ValType", pd->triCount, as3verts);
			AS3_Set(as3polys, AS3_Int(j), as3poly);
		}
	}


	return result;
}

//Function exposed to ActionScript
static AS3_Val detourSqrt(void *data, AS3_Val args)
{
	//vars to hold the parameters from AS
	double x = AS3_NumberValue(args);

	double xsqrt = dtSqrt( x );
	
	return AS3_Number(xsqrt);
}

/*
  __  __              _____   _   _ 
 |  \/  |     /\     |_   _| | \ | |
 | \  / |    /  \      | |   |  \| |
 | |\/| |   / /\ \     | |   | . ` |
 | |  | |  / ____ \   _| |_  | |\  |
 |_|  |_| /_/    \_\ |_____| |_| \_|
                                    
                                    
*/

int main()
{

	ctx = AS3_rcContext();
	ctx.enableLog(true);
	ctx.log(RC_LOG_PROGRESS, "AS3_rcContext logging on");

	geom = new InputGeom;
	//sample = new SoloMesh;
	sample = new Sample_TempObstacles;

	//define the methods exposed to ActionScript
	//typed as an ActionScript Function instance
	
	AS3_Val detourSqrtMethod = AS3_Function( NULL, detourSqrt );
	AS3_Val meshSettingsMethod = AS3_Function(NULL, meshSettings);
	AS3_Val loadMeshMethod = AS3_Function(NULL, loadMesh);
	//AS3_Val getMeshMethod = AS3_Function(NULL, getMesh);
	AS3_Val getTrisMethod = AS3_Function(NULL, getTris);
	AS3_Val buildMeshMethod = AS3_Function(NULL, buildMesh);
	AS3_Val getVertsMethod = AS3_Function(NULL, getVerts);
	AS3_Val getVerts2Method = AS3_Function(NULL, getVerts2);
	AS3_Val getMaxTilesMethod = AS3_Function(NULL, getMaxTiles);
	AS3_Val addAgentMethod = AS3_Function(NULL, addAgent);
	AS3_Val removeAgentMethod = AS3_Function(NULL, removeAgent);
	AS3_Val initCrowdMethod = AS3_Function(NULL, initCrowd);
	AS3_Val moveAgentMethod = AS3_Function(NULL, moveAgent);
	AS3_Val requestMoveVelocityMethod = AS3_Function(NULL, requestMoveVelocity);
	AS3_Val updateMethod = AS3_Function(NULL, update);
	AS3_Val getAgentPositionMethod = AS3_Function(NULL, getAgentPosition);
	AS3_Val getAgentVelocityMethod = AS3_Function(NULL, getAgentVelocity);
	AS3_Val getTilesMethod = AS3_Function(NULL, getTiles);
	AS3_Val addObstacleMethod = AS3_Function(NULL, addObstacle);
	AS3_Val removeObstacleMethod = AS3_Function(NULL, removeObstacle);
	AS3_Val setObstacleAvoidanceParamsMethod = AS3_Function(NULL, setObstacleAvoidanceParams);

	// construct an object that holds references to the functions

	AS3_Val result = AS3_Object("detourSqrt: AS3ValType", detourSqrtMethod);
	AS3_SetS(result, "meshSettings",  meshSettingsMethod);
	AS3_SetS(result, "loadMesh",  loadMeshMethod);
	//AS3_SetS(result, "getMesh",  getMeshMethod);
	AS3_SetS(result, "getTris",  getTrisMethod);
	AS3_SetS(result, "buildMesh",  buildMeshMethod);
	AS3_SetS(result, "getVerts",  getVertsMethod);
	AS3_SetS(result, "getVerts2",  getVerts2Method);
	AS3_SetS(result, "getMaxTiles",  getMaxTilesMethod);
	AS3_SetS(result, "addAgent",  addAgentMethod);
	AS3_SetS(result, "removeAgent",  removeAgentMethod);
	AS3_SetS(result, "initCrowd",  initCrowdMethod);
	AS3_SetS(result, "moveAgent",  moveAgentMethod);
	AS3_SetS(result, "requestMoveVelocity",  requestMoveVelocityMethod);
	AS3_SetS(result, "update",  updateMethod);
	AS3_SetS(result, "getAgentPosition",  getAgentPositionMethod);
	AS3_SetS(result, "getAgentVelocity",  getAgentVelocityMethod);
	AS3_SetS(result, "getTiles",  getTilesMethod);
	AS3_SetS(result, "addObstacle",  addObstacleMethod);
	AS3_SetS(result, "removeObstacle",  removeObstacleMethod);
	AS3_SetS(result, "setObstacleAvoidanceParams",  setObstacleAvoidanceParamsMethod);


	// Release
	AS3_Release( detourSqrtMethod );
	AS3_Release( meshSettingsMethod );
	AS3_Release( loadMeshMethod );
	//AS3_Release( getMeshMethod );
	AS3_Release( getTrisMethod );
	AS3_Release( getVertsMethod );
	AS3_Release( buildMeshMethod );
	AS3_Release( getMaxTilesMethod );
	AS3_Release( addAgentMethod );
	AS3_Release( removeAgentMethod );
	AS3_Release( initCrowdMethod );
	AS3_Release( moveAgentMethod );
	AS3_Release( requestMoveVelocityMethod );
	AS3_Release( updateMethod );
	AS3_Release( getAgentPositionMethod );
	AS3_Release( getAgentVelocityMethod );
	AS3_Release( getTilesMethod );
	AS3_Release( addObstacleMethod );
	AS3_Release( removeObstacleMethod );
	AS3_Release( setObstacleAvoidanceParamsMethod );

	// notify that we initialized -- THIS DOES NOT RETURN!
	AS3_LibInit( result );

	// should never get here!
	return 0;
}

