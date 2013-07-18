/**
 * Demo project for Recast navigation AS3 library (alpha)
 * Very simple 2d example
 * 
 * @author Zo Douglass
 * 
 * Source: https://github.com/zodouglass/RecastAS3
 * Email: zo@zodotcom.com
 * 
 */
package  
{
	//import cmodule.recast.CLibInit;
	//import cmodule.recast.MemUser;
	import flash.utils.getTimer;
	import org.recastnavigation.AS3_rcContext;
	import org.recastnavigation.CModule;
	import org.recastnavigation.dtCrowd;
	import org.recastnavigation.dtCrowdAgent;
	import org.recastnavigation.dtCrowdAgentDebugInfo;
	import org.recastnavigation.dtCrowdAgentParams;
	import org.recastnavigation.dtMeshTile;
	import org.recastnavigation.dtNavMesh;
	import org.recastnavigation.dtNavMeshQuery;
	import org.recastnavigation.dtPoly;
	import org.recastnavigation.dtQueryFilter;
	import org.recastnavigation.InputGeom;
	import org.recastnavigation.rcMeshLoaderObj;
	import org.recastnavigation.Sample_TempObstacles;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	 [SWF(width="800", height="600", frameRate="30")]
	public class MainCC extends Sprite
	{
		[Embed(source="../bin/nav_test.obj",mimeType="application/octet-stream")]
		private var myObjFile:Class;
		
		private static var OBJ_FILE:String = "nav_test.obj";// "dungeon.obj"; //dungeon
		private static var OBJ_HEIGHT:Number = -2.2; //since we are doing 2d, need to pass an appropriate surface height of the obj mesh
		
		private static var MAX_AGENTS:int = 60;
		private static var MAX_AGENT_RADIUS:Number = 0.32;
		private static var MAX_SPEED:Number = 4.5; //3.5
		private static var MAX_ACCEL:Number = 8.5; //8.0
		
		private static var SCALE:Number = 1;
		
		
		private var lib:Object;
		
		private var agentPos:Array;
		
		private var agentPosition:ByteArray;
		private var agentPtr:int; //pointer to the address location in memory
		
		private var agentSprites:Array = [];
		private var agentPtrs:Array = [];
		
		//private var memUser:MemUser = new MemUser();
		
		private var targetSprite:Sprite = new Sprite();
		
		private var tiles:Array;
		private var obstacleRefs:Array = [];
		
		private var sample:Sample_TempObstacles;
		private var geom:InputGeom;
		private var crowd:dtCrowd;
		private var crowdDebugPtr:int;
		private var targetPosPtr:int;

		public function MainCC() 
		{
			if ( stage)
				init();
			else
				stage.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event=null):void
		{
			stage.removeEventListener(Event.ADDED_TO_STAGE, init);
			
		//	CModule.vfs.console = this
			CModule.startAsync(this);
			
			//load the mesh file into recast
			var b:ByteArray = new myObjFile();
			CModule.vfs.addFile(OBJ_FILE, b ); //formly CLibInit.supplyFile from Alchemy
			
			var as3LogContext:AS3_rcContext = AS3_rcContext.create();
			sample = Sample_TempObstacles.create();
			geom = InputGeom.create();
			
			var loadResult:Boolean = geom.loadMesh(as3LogContext.swigCPtr, OBJ_FILE);
			trace("loadMesh", loadResult);
			
			var m_cellSize:Number = 0.3,
			m_cellHeight:Number = 0.2,
			m_agentHeight:Number = 3.0,
			m_agentRadius:Number = MAX_AGENT_RADIUS,
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
			
			var startTime:Number = new Date().valueOf();
			var buildSuccess:Boolean = sample.handleBuild();
			
			trace("build time", new Date().valueOf() - startTime, "ms");
			
			trace("buildsuccess", buildSuccess);
			
			var meshLoader:rcMeshLoaderObj = new rcMeshLoaderObj();
			meshLoader.swigCPtr = geom.getMesh();
			
			var triPtr:int = meshLoader.getTris();
			var ntris:int = meshLoader.getTriCount();
			
			var tris:Vector.<int> = CModule.readIntVector(triPtr, ntris * 3); 
			
			var vertPtr:int = meshLoader.getVerts()
			var nVerts:int = meshLoader.getVertCount();
			
			var verts:Vector.<Point> = new Vector.<Point>();
			var p:Point;
			
			for ( var i:int = 0; i < nVerts * 3; i+=3 )
			{
				p = new Point( CModule.readFloat(vertPtr + (i * 4)),  CModule.readFloat(vertPtr + ((i + 2) * 4)) ); //* 4 since floats take up 4 bytes , where x=i, z=i+1, y=i+2                      
				verts.push(p);
			}
			debugDrawMesh(tris, verts); //try obj mesh
			
			
			crowd = new dtCrowd();
			crowd.swigCPtr = sample.getCrowd();
			
			var crowdInit:Boolean = crowd.init(MAX_AGENTS, MAX_AGENT_RADIUS, sample.getNavMesh() );
			trace("crowdInit", crowdInit);
			
			var debug:dtCrowdAgentDebugInfo = dtCrowdAgentDebugInfo.create();
			crowdDebugPtr = debug.swigCPtr;
			
			// Make polygons with 'disabled' flag invalid.
			//crowd. getEditableFilter()->setExcludeFlags(SAMPLE_POLYFLAGS_DISABLED);
			
			var navMesh:dtNavMesh = new dtNavMesh();
			navMesh.swigCPtr = sample.getNavMesh();
			
			for ( i = 0; i < navMesh.getMaxTiles(); i++ )
			{
				var meshTile:dtMeshTile = new dtMeshTile();
				meshTile.swigCPtr = navMesh.getTile(i);
				
				var verts:Vector.<Number> = meshTile.
			}
			/*
			tiles = lib.getTiles();
			drawNavMesh(tiles);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			*/
			
			
			//add 'game loop' and update crowd
			this.stage.addEventListener(Event.ENTER_FRAME, updateCrowd );
			
			this.stage.addEventListener(MouseEvent.CLICK, onClick );
			this.stage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick );
			this.stage.addEventListener(MouseEvent.MIDDLE_CLICK, onMiddleClick );
			
			
			
			this.scaleX = this.scaleY = SCALE;
			this.x = 300;
			this.y = 300;
			
			stage.addChild( new Stats());
			
			//add directions
			var tf:TextField = new TextField();
			tf.multiline = true;
			tf.text = " Right Click - Add Agent.\n Left Click - Move Target.\n Middle Click - add/remove obstacle";
			tf.x = 150;
			tf.y = 20;
			tf.width = tf.textWidth;
			tf.height = 200;
			tf.selectable = false;
			stage.addChild(tf);
			
			//setup move target sprite
			targetSprite.graphics.lineStyle(0.5, 0xffff00);
			targetSprite.graphics.moveTo( -1, 0);
			targetSprite.graphics.lineTo( 1, 0);
			targetSprite.graphics.moveTo( 0, -1);
			targetSprite.graphics.lineTo( 0, 1);
			
			this.addChild(targetSprite);
			
			targetPosPtr= CModule.alloca(12); 
		}
		
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.O:
					break;
				case Keyboard.R:
					break;
			}
		}
		
		private function onMiddleClick(e:MouseEvent):void
		{
			var obstacleRadius:Number = Math.random() * 2;
			var obstacleHeight:Number = 2;
			var oid:int = lib.addObstacle(this.mouseX, OBJ_HEIGHT, this.mouseY, obstacleRadius, obstacleHeight);
			obstacleRefs.push(oid);
			
			var obstacleSprite:MovieClip = new MovieClip();
			obstacleSprite.graphics.beginFill(0x00aaaa);
			obstacleSprite.graphics.drawCircle(0,0, obstacleRadius);
			obstacleSprite.graphics.endFill();
			obstacleSprite.x = this.mouseX;
			obstacleSprite.y = this.mouseY;
			this.addChild(obstacleSprite);
			obstacleSprite["oid"] = oid;
			obstacleSprite.addEventListener(MouseEvent.MIDDLE_CLICK, removeObstacle );
			setTimeout(redrawMesh, 50 );
		}
		
		private function removeObstacle(e:MouseEvent):void
		{
			var target:MovieClip = e.target as MovieClip;
			var oid:int = target["oid"];
			lib.removeObstacle( oid );
			this.removeChild( target );
			target.removeEventListener(MouseEvent.MIDDLE_CLICK, removeObstacle );
			target = null;
			e.stopImmediatePropagation();
			e.stopPropagation();
			setTimeout(redrawMesh, 50 );
		}
		
		
		private function redrawMesh():void
		{
			this.graphics.clear();
			
			var tris:Array = lib.getTris();
			var verts:Array = lib.getVerts();
			//var mesh:Object = lib.getMesh();
			drawMesh(tris, verts); //try obj mesh
			
			tiles = lib.getTiles();
			
			drawNavMesh(tiles);
		}
		
		private function onRightClick(e:MouseEvent):void
		{
			trace("add target ", this.mouseX, this.mouseY);
			
			
			var posPtr:int = CModule.alloca(12); //x,y,z floats, 32 bits (4 bytes) each
			CModule.writeFloat(posPtr, this.mouseX);//x
			CModule.writeFloat(posPtr + 4, OBJ_HEIGHT); //y
			CModule.writeFloat(posPtr + 8, mouseY); //z
			
			var agentIdx:int = addAgent(posPtr);
			
			var agentSprite:MovieClip = new MovieClip();
			agentSprite.graphics.beginFill(0xff0000);
			agentSprite.graphics.drawCircle(0,0, MAX_AGENT_RADIUS);
			agentSprite.graphics.endFill();
			agentSprite.x = this.mouseX;
			agentSprite.y = this.mouseY;
			agentSprite["idx"] = agentIdx;
			this.addChild(agentSprite);
			agentSprite.addEventListener(MouseEvent.RIGHT_CLICK, removeAgent );
			agentSprites.push(agentSprite);
			
			//get the agent position in memory
			//var agentPtr:uint = lib.getAgentPosition(agentId);
			var agentPtr:uint = crowd.getAgent(agentIdx);
			var agent:dtCrowdAgent = new dtCrowdAgent();
			agent.swigCPtr = agentPtr;
			agentPtrs.push(agent.npos);
			
			
			trace("agentIdx", agentIdx);
			trace("agentPtr", agentPtr);
			trace("agent.npos", agent.npos);
			trace("agent.targetPos", agent.targetPos);
			
			var ux:Number = CModule.readFloat(posPtr);
			var uy:Number =  CModule.readFloat(posPtr + 4); // + 4 since a float takes up 4 bytes
			var uz:Number =  CModule.readFloat(posPtr + 8);
			trace("agent added at ", ux, uy, uz );
		}
		
		private function addAgent(posPtr:int):int
		{
			
			var params:dtCrowdAgentParams = dtCrowdAgentParams.create();
			params.maxAcceleration = MAX_ACCEL;
			params.radius = MAX_AGENT_RADIUS;
			params.height = 2;
			params.maxSpeed = MAX_SPEED;
			params.collisionQueryRange = 12;
			params.pathOptimizationRange = 30;
			
			//var agentId:int = crowd.addAgent(ax, OBJ_HEIGHT, ay, radius, height, maxAccel, maxSpeed, collisionQueryRange, pathOptimizationRange);
			var agentIdx:int = crowd.addAgent(posPtr, params.swigCPtr);
			
			//moveagent
			var navquery:dtNavMeshQuery = new dtNavMeshQuery();
			navquery.swigCPtr = sample.getNavMeshQuery();
			
			var filter:dtQueryFilter = new dtQueryFilter();
			filter.swigCPtr = crowd.getFilter();
			
			var dtPolyRefPtr:int;
			var nearestResult:int = navquery.findNearestPoly(posPtr, crowd.getQueryExtents(), crowd.getFilter(), dtPolyRefPtr, targetPosPtr);
			if ( nearestResult > 0 )
			{
				crowd.requestMoveTarget(agentIdx, nearestResult, targetPosPtr);
			}
			
			return agentIdx;
		}
		
		private function removeAgent(e:MouseEvent):void
		{
			var target:MovieClip = e.target as MovieClip;
			var idx:int = target["idx"];
			lib.removeAgent( idx );
			this.removeChild( target );
			target.removeEventListener(MouseEvent.RIGHT_CLICK, removeAgent );
			target = null;
			e.stopImmediatePropagation();
			e.stopPropagation();
		}
		
		private function onClick(e:MouseEvent):void
		{
			trace("move target ", this.mouseX, this.mouseY);
			
			targetSprite.x = this.mouseX;
			targetSprite.y = this.mouseY;
			
			//test move agent
			//move all
			for ( var i:int = 0; i < agentSprites.length; i++ )
			{
				var idx:int = i;
				
				moveAgent(idx, this.mouseX, this.mouseY, OBJ_HEIGHT );
				//lib.moveAgent(idx, this.mouseX, OBJ_HEIGHT, this.mouseY); 
				
				//trace("moveto", nearestResult, dtPolyRefPtr, targetPosPtr);
				//moveVelocity(idx);
				
			}
			
			//move one
			//var idx:int = 0;
			//lib.moveAgent(idx, this.mouseX, OBJ_HEIGHT, this.mouseY);
		}
		
		private function moveAgent(idx:int, x:Number, y:Number, z:Number):void
		{
			var navquery:dtNavMeshQuery = new dtNavMeshQuery();
			navquery.swigCPtr = sample.getNavMeshQuery();
			
			var filter:dtQueryFilter = new dtQueryFilter();
			filter.swigCPtr = crowd.getFilter();
			
			var posPtr:int = CModule.alloca(12); //x,y,z floats, 32 bits (4 bytes) each
			CModule.writeFloat(posPtr, x);//x
			CModule.writeFloat(posPtr + 4, y); //z
			CModule.writeFloat(posPtr + 8,  z); //y
		
		
			var dtPolyRefPtr:int;
			var nearestResult:int = navquery.findNearestPoly(posPtr, crowd.getQueryExtents(), crowd.getFilter(), dtPolyRefPtr, targetPosPtr);
			if ( nearestResult > 0 )
			{
				crowd.requestMoveTarget(idx, nearestResult, targetPosPtr);
			}
			
			//CModule.free(posPtr);
		}
		
		/*
		private function moveVelocity(idx:int):void
		{
			var ux:Number = getAgentX(idx);
			var uz:Number = getAgentZ(idx);
			var diff:Point = new Point( ux, uz).subtract( new Point( this.mouseX, this.mouseY));
			diff.normalize(1);
			
			lib.removeAgent(idx);
			
			var agentSprite:MovieClip = agentSprites[idx];
			var agentId:int = addAgent( ux, uz);
			agentSprite["idx"] = agentId;
			
			lib.requestMoveVelocity(agentId, -diff.x * MAX_SPEED, 0, -diff.y * MAX_SPEED );
		}*/
		
		private var mLastFrameTimestamp:Number = 0;
		private function updateCrowd(e:Event=null):void
		{
			var now:Number = getTimer() / 1000.0;
            var passedTime:Number = now - mLastFrameTimestamp;
            mLastFrameTimestamp = now;
			
			crowd.update(passedTime, crowdDebugPtr); //todo - debug in
			drawAgents();
		}
		
		private function drawAgents():void
		{
			if ( agentSprites.length == 0 )
				return;
			
			for ( var i:int = 0; i < agentSprites.length; i++ )
			{
				var ux:Number = getAgentX(i);
				var uz:Number = getAgentZ(i);
				agentSprites[i].x = ux;
				agentSprites[i].y = uz;
			}
			
		}
		
		private function getAgentX(i:int):Number
		{
			var agentPtr:uint = agentPtrs[i]; //get the memory address of the agents position
			var ux:Number = CModule.readFloat(agentPtr);//memUser._mrf(agentPtr);
			
			return ux;
		}
		
		private function getAgentY(i:int):Number
		{
			var agentPtr:uint = agentPtrs[i]; //get the memory address of the agents position
			var uy:Number =  CModule.readFloat(agentPtr + 4); // + 4 since a float takes up 4 bytes
			
			return uy;
		}
		
		
		private function getAgentZ(i:int):Number
		{
			var agentPtr:uint = agentPtrs[i]; //get the memory address of the agents position
			var uz:Number =  CModule.readFloat(agentPtr + 8);
			
			return uz;
		}
		
		private function drawNavMesh(tiles:Array):void
		{
			//draw each nav mesh tile
			for ( var t:int = 0; t < tiles.length; t++)
			{
				var polys:Array = tiles[t].polys;
				//draw each poly
				for ( var p:int = 0; p < polys.length; p++)
				{
					var poly:Object = polys[p];
					//draw each tri in the poly
					var triVerts:Array = poly.verts;
					this.graphics.beginFill(0x6796a5, 0.5 );
					for ( var i:int = 0; i < poly.triCount; i++)
					{
						//each triangle has 3 vertices
						//each vert has 3 points, xyz
						var p1:Object = {x: triVerts[(i * 9) + 0], y: triVerts[(i * 9) + 1], z: triVerts[(i * 9) + 2]  };
						var p2:Object = {x: triVerts[(i * 9) + 3], y: triVerts[(i * 9) + 4], z: triVerts[(i * 9) + 5]  };
						var p3:Object = {x: triVerts[(i * 9) + 6], y: triVerts[(i * 9) + 7], z: triVerts[(i * 9) + 8]  };
					
						this.graphics.lineStyle(0.1, 0x123d4b);
						
						this.graphics.moveTo(p1.x, p1.z);
						this.graphics.lineTo(p2.x, p2.z);
						this.graphics.lineTo(p3.x, p3.z);
						this.graphics.lineTo(p1.x, p1.z);
						
					}
					this.graphics.endFill();
				}
			}
			
			//draw origin
			this.graphics.lineStyle(0.1, 0x00ff00);
			this.graphics.moveTo(0, 0);
			this.graphics.lineTo(0, 10 );
			this.graphics.lineStyle(0.1, 0x0000ff);
			this.graphics.moveTo(0, 0);
			this.graphics.lineTo(10, 0);
		}
		
		private function drawMesh(tris:Array, verts:Array):void
		{
			
			//this.graphics.clear();
			
			for ( var i:int = 0; i < tris.length; i += 3)
			{
				var v1:Object = verts[tris[i]];
				var v2:Object = verts[tris[i + 1]];
				var v3:Object = verts[tris[i + 2]];
				
				this.graphics.lineStyle(0.1, 0x514a3c);
				this.graphics.beginFill(0x92856d, 1 );
				this.graphics.moveTo(v1.x, v1.z);
				this.graphics.lineTo(v2.x, v2.z);
				this.graphics.lineTo(v3.x, v3.z);
				this.graphics.lineTo(v1.x, v1.z);
				this.graphics.endFill();
			}
			
		}
		
		
		private function debugDrawMesh(tris:Vector.<int>, verts:Vector.<Point>):void
		{
			
			//this.graphics.clear();
			
			for ( var i:int = 0; i < tris.length; i += 3)
			{
				var v1:Object = verts[tris[i]];
				var v2:Object = verts[tris[i + 1]];
				var v3:Object = verts[tris[i + 2]];
				
				this.graphics.lineStyle(0.1, 0x514a3c);
				this.graphics.beginFill(0x92856d, 1 );
				this.graphics.moveTo(v1.x, v1.y);
				this.graphics.lineTo(v2.x, v2.y);
				this.graphics.lineTo(v3.x, v3.y);
				this.graphics.lineTo(v1.x, v1.y);
				this.graphics.endFill();
			}
			
		}
	}

}