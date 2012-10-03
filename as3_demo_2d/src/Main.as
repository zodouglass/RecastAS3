/**
 * Demo project for Recast navigation AS3 library (alpha)
 * Very simple 2d example
 * 
 * @author Zo Douglass
 * 
 * Source: https://github.com/zodouglass/RecastAS3
 * Email: zo@zodotcom.com
 * 
 * TODO - add wrapper class for swc library for autocomplete and compile checking
 */
package  
{
	import cmodule.recast.CLibInit;
	import cmodule.recast.MemUser;
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
	public class Main extends Sprite
	{
		[Embed(source="../bin/nav_test.obj",mimeType="application/octet-stream")]
		private var myObjFile:Class;
		
		private static var OBJ_FILE:String = "nav_test.obj";// "dungeon.obj"; //dungeon
		private static var OBJ_HEIGHT:Number = -2.2; //since we are doing 2d, need to pass an appropriate surface height of the obj mesh
		
		private static var MAX_AGENTS:int = 60;
		private static var MAX_AGENT_RADIUS:Number = 0.32;
		private static var MAX_SPEED:Number = 4.5; //3.5
		private static var MAX_ACCEL:Number = 8.5; //8.0
		
		private static var SCALE:Number = 10;
		
		
		private var lib:Object;
		
		private var agentPos:Array;
		
		private var agentPosition:ByteArray;
		private var agentPtr:int; //pointer to the address location in memory
		
		private var agentSprites:Array = [];
		private var agentPtrs:Array = [];
		
		private var memUser:MemUser = new MemUser();
		
		private var targetSprite:Sprite = new Sprite();
		
		private var tiles:Array;
		private var obstacleRefs:Array = [];

		public function Main() 
		{
			if ( stage)
				init();
			else
				stage.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event=null):void
		{
			stage.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var loader:CLibInit = new CLibInit;
			
			//pass any files required by the C lib before calling init
			var b:ByteArray = new myObjFile();
			loader.supplyFile( OBJ_FILE, b ); 
			
			//now call the CLib init function
			lib = loader.init();
			
			var bloadMesh:Boolean = lib.loadMesh( OBJ_FILE );
			
			//set mesh settings		
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
			
			lib.meshSettings(m_cellSize, 
							m_cellHeight, 
							m_agentHeight, 
							m_agentRadius, 
							m_agentMaxClimb, 
							m_agentMaxSlope, 
							m_regionMinSize, 
							m_regionMergeSize, 
							m_edgeMaxLen, 
							m_edgeMaxError, 
							m_vertsPerPoly, 
							m_detailSampleDist, 
							m_detailSampleMaxError, 
							m_tileSize, 
							m_maxObstacles,
							false);
			var startTime:Number = new Date().valueOf();
			var bbuildMesh:Boolean = lib.buildMesh( );
			trace("build time", new Date().valueOf() - startTime, "ms");
			
			var tris:Array = lib.getTris();
			var verts:Array = lib.getVerts();
			//var mesh:Object = lib.getMesh();
			drawMesh(tris, verts); //try obj mesh
			
			//var maxTiles:int = lib.getMaxTiles();
			var crowdInit:Boolean = lib.initCrowd(MAX_AGENTS, MAX_AGENT_RADIUS); //maxagents, max agent radius
			
			
			tiles = lib.getTiles();
			drawNavMesh(tiles);
			
			//add 'game loop' and update crowd
			setInterval( updateCrowd, 33 );
			
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
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
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
			
			var agentId:int = addAgent(this.mouseX, this.mouseY);
			
			var agentSprite:MovieClip = new MovieClip();
			agentSprite.graphics.beginFill(0xff0000);
			agentSprite.graphics.drawCircle(0,0, MAX_AGENT_RADIUS);
			agentSprite.graphics.endFill();
			agentSprite.x = this.mouseX;
			agentSprite.y = this.mouseY;
			agentSprite["idx"] = agentId;
			this.addChild(agentSprite);
			agentSprite.addEventListener(MouseEvent.RIGHT_CLICK, removeAgent );
			agentSprites.push(agentSprite);
			
			//get the agent position in memory
			var agentPtr:uint = lib.getAgentPosition(agentId);
			agentPtrs.push(agentPtr);
			
			var ux:Number = memUser._mrf(agentPtr);
			var uy:Number = memUser._mrf(agentPtr + 4); // + 4 since a float takes up 4 bytes
			var uz:Number = memUser._mrf(agentPtr + 8);
			trace("agent added at ", ux, uy, uz );
		}
		
		private function addAgent(ax:Number, ay:Number):int
		{
			
			var radius:Number = MAX_AGENT_RADIUS;
			var height:Number = 2;
			var maxAccel:Number = MAX_ACCEL;
			var maxSpeed:Number = MAX_SPEED;
			var collisionQueryRange:Number = 12.0;
			var pathOptimizationRange:Number = 30.0;
			
			var agentId:int = lib.addAgent(ax, OBJ_HEIGHT, ay, radius, height, maxAccel, maxSpeed, collisionQueryRange, pathOptimizationRange);
			return agentId;
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
				lib.moveAgent(idx, this.mouseX, OBJ_HEIGHT, this.mouseY); 
				//moveVelocity(idx);
			}
			
			//move one
			//var idx:int = 0;
			//lib.moveAgent(idx, this.mouseX, OBJ_HEIGHT, this.mouseY);
		}
		
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
		}
		
		private function updateCrowd():void
		{
			lib.update(0.03); //pass dt in seconds
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
			var ux:Number = memUser._mrf(agentPtr);
			
			return ux;
		}
		
		private function getAgentY(i:int):Number
		{
			var agentPtr:uint = agentPtrs[i]; //get the memory address of the agents position
			var uy:Number = memUser._mrf(agentPtr + 4); // + 4 since a float takes up 4 bytes
			
			return uy;
		}
		
		
		private function getAgentZ(i:int):Number
		{
			var agentPtr:uint = agentPtrs[i]; //get the memory address of the agents position
			var uz:Number = memUser._mrf(agentPtr + 8);
			
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
		
	}

}