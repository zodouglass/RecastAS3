package  
{
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import org.recastnavigation._wrap_DT_CROWD_ANTICIPATE_TURNS;
	import org.recastnavigation._wrap_DT_CROWD_OBSTACLE_AVOIDANCE;
	import org.recastnavigation._wrap_DT_CROWD_OPTIMIZE_TOPO;
	import org.recastnavigation._wrap_DT_CROWD_OPTIMIZE_VIS;
	import org.recastnavigation._wrap_DT_CROWD_SEPARATION;
	
	import org.recastnavigation.AS3_rcContext;
	import org.recastnavigation.CModule;
	import org.recastnavigation.dtCrowd;
	import org.recastnavigation.dtCrowdAgent;
	import org.recastnavigation.dtCrowdAgentDebugInfo;
	import org.recastnavigation.dtCrowdAgentParams;
	import org.recastnavigation.dtNavMeshQuery;
	import org.recastnavigation.InputGeom;
	import org.recastnavigation.rcMeshLoaderObj;
	import org.recastnavigation.Sample_TempObstacles;
	/**
	 * Example manager class for Recast Detour Path finding
	 */
	public class RecastManager
	{
		
		public var scale:Vector3D = new Vector3D(1, 1, 1); //the scale of the nav mesh to the world
		public var maxAgents:int = 60;
		public var maxAgentRadius:Number= 4;
		//public var maxSpeed:Number = 4.5; 
		//public var maxAcceleration:Number = 8.5; 
		
		public var m_cellSize:Number = 0.3,
					m_cellHeight:Number = 0.2,
					m_agentHeight:Number = 3.0,
					m_agentRadius:Number = 0.32,
					m_agentMaxClimb:Number = 0.9,
					m_agentMaxSlope:Number = 45.0,
					m_regionMinSize:Number = 8,
					m_regionMergeSize:Number = 20,
					m_edgeMaxLen:Number = 12.0,
					m_edgeMaxError:Number = 1.3,
					m_vertsPerPoly:Number = 6.0,
					m_detailSampleDist:Number = 6.0,
					m_detailSampleMaxError:Number = 1.0,
					m_tileSize:int = 48,
					m_maxObstacles:int = 1024;
		
		public function loadMesh(filename:String, obj:ByteArray):void
		{
			CModule.startAsync(this);
			
			//load the mesh file into recast
			CModule.vfs.addFile(filename, obj ); //formly CLibInit.supplyFile from Alchemy
			
			var as3LogContext:AS3_rcContext = AS3_rcContext.create();
			_sample = Sample_TempObstacles.create();
			geom = InputGeom.create();
			
			var loadResult:Boolean = geom.loadMesh(as3LogContext.swigCPtr, filename);
			
			//update mesh settings
			sample.m_cellSize = m_cellSize;
			sample.m_cellHeight = m_cellHeight;
			sample.m_agentHeight = m_agentHeight;
			sample.m_agentRadius = m_agentRadius;
			sample.m_agentMaxClimb = m_agentMaxClimb;
			sample.m_agentMaxSlope = m_agentMaxSlope;
			sample.m_regionMinSize = m_regionMinSize;
			sample.m_regionMergeSize = m_regionMergeSize;
			sample.m_edgeMaxLen = m_edgeMaxLen;
			sample.m_edgeMaxError = m_edgeMaxError;
			sample.m_vertsPerPoly = m_vertsPerPoly;
			sample.m_detailSampleDist = m_detailSampleDist;
			sample.m_detailSampleMaxError = m_detailSampleMaxError;
			sample.m_tileSize = m_tileSize;
			sample.m_maxObstacles = m_maxObstacles;
			
			//build mesh
			sample.setContext(as3LogContext.swigCPtr);
			sample.handleMeshChanged(geom.swigCPtr);
			sample.handleSettings();
			
			var startTime:Number = new Date().valueOf();
			var buildSuccess:Boolean = sample.handleBuild();
			trace("build time", new Date().valueOf() - startTime, "ms");
			
			crowd = new dtCrowd();
			crowd.swigCPtr = sample.getCrowd();
			crowd.init(maxAgents, maxAgentRadius, sample.getNavMesh() );
			
			//var debug:dtCrowdAgentDebugInfo = dtCrowdAgentDebugInfo.create();
			//crowdDebugPtr = debug.swigCPtr;
		}
		
		public function advanceTime(deltaTime:Number):void
		{
			if( crowd )
				crowd.update(deltaTime, crowdDebugPtr);
				
			sample.handleUpdate(deltaTime); //update the tileCache
		}
		
		//todo - this should take 2 params, position, and dtCrowdAgentParams
		public function addAgentNear(scenePosition:Vector3D, radius:Number = 1.0, height:Number = 2.0, maxAccel:Number=8.5, maxSpeed:Number=4.5, collisionQueryRange:Number=12, pathOptimizationRange:Number=30 ):int
		{
			var navPosition:Vector3D = new Vector3D(scenePosition.x / scale.x, scenePosition.y / scale.y, scenePosition.z / scale.z );
			
			var posPtr:int = CModule.alloca(12);
			CModule.writeFloat(posPtr, navPosition.x);
			CModule.writeFloat(posPtr + 4, navPosition.y);
			CModule.writeFloat(posPtr + 8, navPosition.z);
			
			var params:dtCrowdAgentParams = dtCrowdAgentParams.create();
			params.radius  = radius / scale.x;
			params.height  = height / scale.y;
			params.maxAcceleration = maxAccel;
			params.maxSpeed = maxSpeed;
			params.collisionQueryRange = collisionQueryRange;
			params.pathOptimizationRange = pathOptimizationRange;
			
			params.separationWeight = 2.0;
			params.obstacleAvoidanceType = String.fromCharCode(3.0); //0, 3.0, 1
			var updateFlags:uint = 0;
			updateFlags |= _wrap_DT_CROWD_ANTICIPATE_TURNS();
			updateFlags |= _wrap_DT_CROWD_OPTIMIZE_VIS();
			updateFlags |= _wrap_DT_CROWD_OPTIMIZE_TOPO();
			updateFlags |= _wrap_DT_CROWD_OBSTACLE_AVOIDANCE();
			//updateFlags |= _wrap_DT_CROWD_SEPARATION();
			params.updateFlags = String.fromCharCode(updateFlags); //since updateFlags is stored as a char in recast, need to save the string as the char code value
			trace(params.updateFlags.charCodeAt(0) );
			
			
			//params.updateFlags = String(1);
			
			//params.updateFlags = "0";
			//params.obstacleAvoidanceType = 1.0;
			//params.updateFlags |= "1";
			
			var idx:int = crowd.addAgent(posPtr, params.swigCPtr );
			
			var navquery:dtNavMeshQuery  = new dtNavMeshQuery();
			navquery.swigCPtr =  sample.getNavMeshQuery();
			//const dtQueryFilter* filter = crowd->getFilter();
			//const float* ext = crowd->getQueryExtents();

			var targetRef:int = CModule.alloca(4);
			var targetPos:int = CModule.alloca(12);
			
			var statusPtr:int = navquery.findNearestPoly(posPtr, crowd.getQueryExtents(), crowd.getFilter(), targetRef, targetPos);
			//var status:int = findNearestPoly2(navquery, posPtr, crowd.getQueryExtents(), crowd.getFilter(), targetRef, targetPos);
			
			trace(CModule.readFloat(targetPos), CModule.readFloat(targetPos+4), CModule.readFloat(targetPos+8));
			
			//var test1:int = CModule.read32(targetRef);
			//var test2:Number = CModule.readFloat(targetPos);
		
			if (targetRef > 0)
				crowd.requestMoveTarget(idx, targetRef, targetPos);
			
				
			
			return idx;
		}
		
		
		public function moveAgentNear(idx:int, scenePosition:Vector3D):void
		{
			var navPosition:Vector3D = new Vector3D(scenePosition.x / scale.x, scenePosition.y / scale.y, scenePosition.z / scale.z );
			
			var posPtr:int = CModule.alloca(12);
			CModule.writeFloat(posPtr, navPosition.x);
			CModule.writeFloat(posPtr + 4, navPosition.y);
			CModule.writeFloat(posPtr + 8, navPosition.z);
			
			var navquery:dtNavMeshQuery  = new dtNavMeshQuery();
			navquery.swigCPtr =  sample.getNavMeshQuery();
			
			var targetRef:int = CModule.alloca(4);
			var targetPos:int = CModule.alloca(12);
			
			var status:int = navquery.findNearestPoly(posPtr, crowd.getQueryExtents(), crowd.getFilter(), targetRef, targetPos);
			//var status:int = findNearestPoly2(navquery,posPtr, crowd.getQueryExtents(), crowd.getFilter(), targetRef, targetPos);
			
			
			//trace(CModule.readFloat(targetPos), CModule.readFloat(targetPos+4), CModule.readFloat(targetPos+8));
			
			//var test1:int = CModule.read32(targetRef);
			//var test2:Number = CModule.readFloat(targetPos);
		
			if ( targetRef > 0)
				crowd.requestMoveTarget(idx,targetRef, targetPos);
			
		}
		
		public function addObstacle(scenePosition:Vector3D, obstacleRadius:Number, obstacleHeight:Number):int
		{
			var navPosition:Vector3D = new Vector3D(scenePosition.x / scale.x, scenePosition.y / scale.y, scenePosition.z / scale.z );
			
			var posPtr:int = CModule.alloca(12);
			CModule.writeFloat(posPtr, navPosition.x);
			CModule.writeFloat(posPtr + 4, navPosition.y);
			CModule.writeFloat(posPtr + 8, navPosition.z);
			
			return sample.addTempObstacle(posPtr, obstacleRadius / scale.x, obstacleHeight * scale.y);
		}
		
		public function removeObstalce(oid:int):void
		{
			sample.removeTempObstacle(oid);
		}
		
		
		
		public function get geomerty():InputGeom
		{
			return geom;
		}
		
		/**
		 * get the X position of the agent in world space
		 * @param	idx
		 * @return
		 */
		public function getAgentX(idx:int):Number
		{
			var agent:dtCrowdAgent = new dtCrowdAgent();
			agent.swigCPtr = crowd.getAgent(int(idx));
			return CModule.readFloat( agent.npos ) * scale.x;
		}
		
		public function getAgentY(idx:int):Number
		{
			var agent:dtCrowdAgent = new dtCrowdAgent();
			agent.swigCPtr = crowd.getAgent(int(idx));
			return CModule.readFloat( agent.npos +4 ) * scale.x;
		}
		public function getAgentZ(idx:int):Number
		{
			var agent:dtCrowdAgent = new dtCrowdAgent();
			agent.swigCPtr = crowd.getAgent(int(idx));
			return CModule.readFloat( agent.npos +8 ) * scale.x;
		}
		
		public function get sample():Sample_TempObstacles
		{
			return _sample;
		}
		
			//recast variables
		private var _sample:Sample_TempObstacles;
		private var geom:InputGeom;
		private var crowd:dtCrowd;
		private var crowdDebugPtr:int;
		private var mLastFrameTimestamp:Number;
		
	}

}