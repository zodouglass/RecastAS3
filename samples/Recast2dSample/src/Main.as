package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import org.recastnavigation.AS3_rcContext;
	import org.recastnavigation.CModule;
	import org.recastnavigation.dtCrowd;
	import org.recastnavigation.dtCrowdAgent;
	import org.recastnavigation.dtCrowdAgentDebugInfo;
	import org.recastnavigation.dtCrowdAgentParams;
	import org.recastnavigation.dtMeshHeader;
	import org.recastnavigation.dtMeshTile;
	import org.recastnavigation.dtNavMesh;
	import org.recastnavigation.dtNavMeshQuery;
	import org.recastnavigation.dtPoly;
	import org.recastnavigation.dtPolyDetail;
	import org.recastnavigation.InputGeom;
	import org.recastnavigation.rcMeshLoaderObj;
	import org.recastnavigation.Sample_TempObstacles;
	import org.recastnavigation.util.getTiles;
	
	/**
	 * Simple 2D Recast Example.
	 * @author Zo
	 */
	public class Main extends Sprite 
	{
		[Embed(source="../assets/nav_test.obj",mimeType="application/octet-stream")]
		private var myObjFile:Class;
		
		private static var OBJ_FILE:String = "nav_test.obj";
		private static var WORLD_Z:Number = -2.2; //needed for example obj file.  obj files should have the ground at 0, but the example its about -2.2
		
		private static var SCALE:Number = 10; //the scale of the nav mesh to the world
		private static var MAX_AGENTS:int = 60;
		private static var MAX_AGENT_RADIUS:Number = 32;
		private static var MAX_SPEED:Number = 4.5; 
		private static var MAX_ACCEL:Number = 8.5; 
		
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			initRecast();
			initEngine();
			initDebugRenders();
			initWorld();
			initListeners();
		}
		
		private function initRecast():void
		{
			recastManager = new RecastManager();
			recastManager.scale.x = SCALE;
			recastManager.scale.y = SCALE;
			recastManager.scale.z = SCALE;
			
			//load the object file mesh
			var b:ByteArray = new myObjFile();
			recastManager.m_agentRadius = 1.5;
			recastManager.loadMesh(OBJ_FILE, b);
		}
		
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
 
		}
		
		
		private function initWorld():void
		{
			world = new Sprite();
			
			this.x = 200;
			this.y = 300;
			
			addChild(world);
		}
		
		private function initDebugRenders():void
		{
			
			debugSprite = new Sprite();
			addChild(debugSprite);
			
			
			//render the mesh
			debugRender();
			debugSprite.scaleX = debugSprite.scaleY = SCALE;
			
		}
		
		
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.CLICK, onMouseClick);
			stage.addEventListener(MouseEvent.RIGHT_CLICK, onMouseRightClick);
			stage.addEventListener(MouseEvent.MIDDLE_CLICK, onMiddleClick);
		}
		
		
		
		private function onMouseRightClick(e:MouseEvent):void
		{
			var scenePosition:Vector3D = new Vector3D(world.mouseX, WORLD_Z * SCALE, world.mouseY );
			
			//move all agents to the mouse position
			//todo - change this to a vector or use domain memory to speed this up.  for each in a dictionary is very slow when called every frame!
			for ( var idx:Object in agentObjectsByAgendIdx ) //iteratore through each object key
			{
				recastManager.moveAgentNear(int(idx), scenePosition );
			}
			//recastManager.moveAgentNear(0, scenePosition );
		}
		private function onMouseClick(e:MouseEvent):void
		{
			var scenePosition:Vector3D = new Vector3D(world.mouseX, WORLD_Z * SCALE, world.mouseY  );
			
			var agentRadius:Number = Math.random() * MAX_AGENT_RADIUS
			var agentAcceleration:Number = MAX_AGENT_RADIUS - agentRadius; //make it the larger you are, the slower you are
			var agentMaxSpeed:Number = (MAX_AGENT_RADIUS - agentRadius) / 2; //make it the larger you are, the slower you are
			var idx:int = recastManager.addAgentNear(scenePosition, agentRadius, 20, agentAcceleration, agentMaxSpeed);
			
			var s:Sprite = new Sprite();
			s.graphics.lineStyle(2, 0x3a4e84);
			s.graphics.beginFill(0x5275d3,0.8);
			s.graphics.drawCircle(0, 0, agentRadius);
			s.graphics.endFill();
			s.x = scenePosition.x;
			s.y =scenePosition.z
			
			world.addChild(s);
			
			
			agentObjectsByAgendIdx[ idx ] = s;
		}
		
		
		private function onMiddleClick(e:MouseEvent):void
		{
			var obstacleRadius:Number = 5 + Math.random() * 20;
			var obstacleHeight:Number = 20;
			var oid:int = recastManager.addObstacle(new Vector3D(world.mouseX, WORLD_Z * SCALE, world.mouseY), obstacleRadius, obstacleHeight);
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
			setTimeout(debugRender, 50 );
		}
		
		private function removeObstacle(e:MouseEvent):void
		{
			var target:MovieClip = e.target as MovieClip;
			var oid:int = target["oid"];
			recastManager.removeObstalce( oid );
			this.removeChild( target );
			target.removeEventListener(MouseEvent.MIDDLE_CLICK, removeObstacle );
			target = null;
			e.stopImmediatePropagation();
			e.stopPropagation();
			setTimeout(debugRender, 50 );
		}
		
	
		
		/**
		 * render loop
		 */
		private function onEnterFrame(e:Event):void
		{
			var now:Number = getTimer() / 1000.0;
            var passedTime:Number = now - mLastFrameTimestamp;
            mLastFrameTimestamp = now;
			
			recastManager.advanceTime(passedTime);
			
			updateAgents();
			
		}
		
		/**
		 * updates the position of the agent render objects with the recast agent positions
		 */
		private function updateAgents():void
		{
			//todo - change this to a vector or use domain memory to speed this up.  for each in a dictionary is very slow when called every frame!
			for ( var idx:Object in agentObjectsByAgendIdx ) //iteratore through each object key
			{
				//trace("agent at:",CModule.readFloat( agent.npos ), CModule.readFloat( agent.npos + 4 ), CModule.readFloat( agent.npos + 8));
				agentObjectsByAgendIdx[ idx ].x = recastManager.getAgentX(int(idx));
				//agentObjectsByAgendIdx[ idx ].y = recastManager.getAgentY(int(idx));
				agentObjectsByAgendIdx[ idx ].y = recastManager.getAgentZ(int(idx));
			}
		}
		
		
		protected function debugRender():void
		{
			debugSprite.graphics.clear();
			//get the trianges and verties of the object file
			var meshLoader:rcMeshLoaderObj = new rcMeshLoaderObj();
			meshLoader.swigCPtr = recastManager.geomerty.getMesh();
			
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
			
			
			
			//now draw the actual nav mesh
			//debugDrawNavMesh();
			var tiles:Array = getTiles(recastManager.sample.swigCPtr);
			drawNavMesh(tiles);
		}
		
		//draw the obj mesh that the nav-mesh is generated from
		private function debugDrawMesh(tris:Vector.<int>, verts:Vector.<Point>):void
		{
			//this.graphics.clear();
			for ( var i:int = 0; i < tris.length; i += 3)
			{
				var v1:Object = verts[tris[i]];
				var v2:Object = verts[tris[i + 1]];
				var v3:Object = verts[tris[i + 2]];
				
				debugSprite.graphics.lineStyle(0.1, 0x514a3c);
				debugSprite.graphics.beginFill(0x92856d, 1 );
				debugSprite.graphics.moveTo(v1.x, v1.y);
				debugSprite.graphics.lineTo(v2.x, v2.y);
				debugSprite.graphics.lineTo(v3.x, v3.y);
				debugSprite.graphics.lineTo(v1.x, v1.y);
				debugSprite.graphics.endFill();
			}
		}
		/*
		private function debugDrawNavMesh():void
		{
			var navMesh:dtNavMesh = new dtNavMesh();
			navMesh.swigCPtr = recastManager.sample.getNavMesh();
			
			//debugSprite.graphics.beginFill(0x00ff00, 0.8 );
			//debugSprite.graphics.drawCircle( 200,0, 0.5 );
			//debugSprite.graphics.endFill();
					
			//loop through every nav mesh tile
			for ( var t:int = 0; t < navMesh.getMaxTiles(); t++)
			{
				var tile:dtMeshTile = new dtMeshTile();
				tile.swigCPtr = navMesh.getTile(t);
				
				if (tile.header == 0 ) //check if the ptr points anywhere
					continue;
				var header:dtMeshHeader = new dtMeshHeader();
				header.swigCPtr = tile.header;
				
				var as3tileverts:Vector.<Vector3D> = new Vector.<Vector3D>();
				
				var v:Vector3D;
				
				trace(header.polyCount, header.vertCount, header.detailTriCount );
				
				
				var poly:dtPoly = new dtPoly();
				poly.swigCPtr = tile.polys;
				
				for ( var p:int = 0; p < header.polyCount; p++)
				{
					var polyDetail:dtPolyDetail = new dtPolyDetail();
					polyDetail.swigCPtr = getPolyDetail(tile.swigCPtr, p );
					
					var triCount:int = getPolyDetailTriCount(tile.swigCPtr, p );
					var triBase:int = getPolyDetailTriBase(tile.swigCPtr, p );
					
					var tricCountChar:int = polyDetail.triCount.charCodeAt(0);
					var vertCountChar:int = polyDetail.vertCount.charCodeAt(0);
					//trace("tricount", getPolyDetail(tile.swigCPtr, p ) );
					
				}
				
			}
		}
		
		*/
		//draw the actual walkable navigation mesh
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
					debugSprite.graphics.beginFill(0x6796a5, 0.5 );
					for ( var i:int = 0; i < poly.triCount; i++)
					{
						//each triangle has 3 vertices
						//each vert has 3 points, xyz
						var p1:Object = {x: triVerts[(i * 9) + 0], y: triVerts[(i * 9) + 1], z: triVerts[(i * 9) + 2]  };
						var p2:Object = {x: triVerts[(i * 9) + 3], y: triVerts[(i * 9) + 4], z: triVerts[(i * 9) + 5]  };
						var p3:Object = {x: triVerts[(i * 9) + 6], y: triVerts[(i * 9) + 7], z: triVerts[(i * 9) + 8]  };
					
						debugSprite.graphics.lineStyle(0.1, 0x123d4b);
						
						debugSprite.graphics.moveTo(p1.x, p1.z);
						debugSprite.graphics.lineTo(p2.x, p2.z);
						debugSprite.graphics.lineTo(p3.x, p3.z);
						debugSprite.graphics.lineTo(p1.x, p1.z);
						
					}
					debugSprite.graphics.endFill();
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
		
		private var mLastFrameTimestamp:Number;
		private var recastManager:RecastManager;
		
		private var obstacleRefs:Array = [];
		
		//2d world objects with simple display list
		private var debugSprite:Sprite;
		private var world:Sprite;
		private var agentObjectsByAgendIdx:Dictionary = new Dictionary(); //sprites by their agent id
	}
	
}