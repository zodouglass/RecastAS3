package 
{
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.controllers.FirstPersonController;
	import away3d.controllers.HoverController;
	import away3d.core.pick.PickingColliderType;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.MouseEvent3D;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.loaders.parsers.OBJParser;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.BasicSpecularMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.SubsurfaceScatteringDiffuseMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import org.recastnavigation.AS3_rcContext;
	import org.recastnavigation.CModule;
	import org.recastnavigation.dtCrowd;
	import org.recastnavigation.dtCrowdAgent;
	import org.recastnavigation.dtCrowdAgentDebugInfo;
	import org.recastnavigation.dtCrowdAgentParams;
	import org.recastnavigation.dtNavMeshQuery;
	import org.recastnavigation.findNearestPoly2;
	import org.recastnavigation.InputGeom;
	import org.recastnavigation.Sample_TempObstacles;
	
	/**
	 * ...
	 * @author Zo
	 */
	public class Main extends Sprite 
	{
		
		[Embed(source="../assets/nav_test.obj",mimeType="application/octet-stream")]
		private var myObjFile:Class;
		
		//Diffuse map texture
		[Embed(source="../assets/checkers.png")]
		private var FloorDiffuse:Class;
		[Embed(source="../assets/checkers.png")]
		private var Diffuse:Class;
		[Embed(source="../assets/checkers.png")]
		private var Specular:Class;
		[Embed(source="../assets/checkers.png")]
		private var Normal:Class;
		
		private static var OBJ_FILE:String = "nav_test.obj";// "dungeon.obj"; //nav_test, dungeon
		private static var OBJ_HEIGHT:Number = -2.2; //since we are doing 2d, need to pass an appropriate surface height of the obj mesh
		
		private static var MAX_AGENTS:int = 60;
		private static var MAX_AGENT_RADIUS:Number = 0.32;
		private static var MAX_SPEED:Number = 4.5; //3.5
		private static var MAX_ACCEL:Number = 8.5; //8.0
		
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
			initMaterials();
			initLights();
			initObjects();
			initListeners();
		}
		
		private function initRecast():void
		{
			CModule.startAsync(this);
			
			//load the mesh file into recast
			var b:ByteArray = new myObjFile();
			CModule.vfs.addFile(OBJ_FILE, b ); //formly CLibInit.supplyFile from Alchemy
			
			var as3LogContext:AS3_rcContext = AS3_rcContext.create();
			sample = Sample_TempObstacles.create();
			geom = InputGeom.create();
			
			var loadResult:Boolean = geom.loadMesh(as3LogContext.swigCPtr, OBJ_FILE);
			
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
			sample.handleSettings();
			
			var startTime:Number = new Date().valueOf();
			var buildSuccess:Boolean = sample.handleBuild();
			trace("build time", new Date().valueOf() - startTime, "ms");
			
			crowd = new dtCrowd();
			crowd.swigCPtr = sample.getCrowd();
			crowd.init(MAX_AGENTS, MAX_AGENT_RADIUS, sample.getNavMesh() );
			
			var debug:dtCrowdAgentDebugInfo = dtCrowdAgentDebugInfo.create();
			crowdDebugPtr = debug.swigCPtr;
		}
		
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
 
			view = new View3D();
			
			
			camera = view.camera;
			camera.lens.far = 14000;
			camera.lens.near = .05;
			camera.x = -30;
			camera.y = 46;
			camera.z = -30;
			//view.camera.lookAt(new Vector3D());
			
			_plane = new Mesh(new PlaneGeometry(700, 700), new TextureMaterial(Cast.bitmapTexture(FloorDiffuse)));
			_plane.material.lightPicker = lightPicker;
			//view.scene.addChild(_plane);
 
			//setup controller to be used on the camera
			
			cameraController = new FirstPersonController(camera, 180, 0, -80, 80);
			cameraController.fly = true;
			cameraController.panAngle = 396;
			cameraController.tiltAngle = 31;
 
			addChild(view);
 
			awayStats = new AwayStats(view);
			addChild(awayStats);
			

		}
		
		private function initMaterials():void
		{
			//setup custom bitmap material
			geomMaterial = new TextureMaterial(new BitmapTexture(new Diffuse().bitmapData));
			geomMaterial.normalMap = new BitmapTexture(new Normal().bitmapData);
			geomMaterial.specularMap = new BitmapTexture(new Specular().bitmapData);
			geomMaterial.lightPicker = lightPicker;
			//geomMaterial.gloss = 10;
			//geomMaterial.specular = 3;
			//geomMaterial.ambientColor = 0x303040;
			//geomMaterial.ambient = 1;
 
			//create subscattering diffuse method
			//subsurfaceMethod = new SubsurfaceScatteringDiffuseMethod(2048, 2);
			//subsurfaceMethod.scatterColor = 0xff7733;
			//subsurfaceMethod.scattering = .05;
			//subsurfaceMethod.translucency = 4;
			//geomMaterial.diffuseMethod = subsurfaceMethod;
 
			//create fresnel specular method
			//fresnelMethod = new FresnelSpecularMethod(true);
			//geomMaterial.specularMethod = fresnelMethod;
 //
			//add default diffuse method
			diffuseMethod = new BasicDiffuseMethod();
 
			//add default specular method
			specularMethod = new BasicSpecularMethod();
		}
		
		private function initLights():void
		{
			light = new PointLight();
			light.x = 0;
			light.y = 100;
			light.color = 0xffddbb;
			light.ambient = 0.2;
			
			light2 = new DirectionalLight();
			light2.direction = new Vector3D(1, -1, 1);
			light2.color = 0xece9d3;
			light2.ambient = 0.8;
			light2.diffuse = 0.5;
			
			lightPicker = new StaticLightPicker([light2]);
 
//			view.scene.addChild(light);


		}
		
		private function initObjects():void
		{
			//default available parsers to all
			Parsers.enableAllBundled()
 
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.loadData(new myObjFile());
		}
		
		private function onAssetComplete(event:AssetEvent):void
		{
			if (event.asset.assetType == AssetType.MESH) {
				geomMesh = event.asset as Mesh;
				//geomMesh.geometry.scale(10); 
				geomMesh.mouseEnabled = true;
				geomMesh.pickingCollider = PickingColliderType.AS3_BEST_HIT;
				geomMesh.addEventListener(MouseEvent3D.CLICK, onMeshClick );
				//geomMesh.y = -50;
				//geomMesh.rotationY = -180; 
				//geomMesh.material =  new TextureMaterial(Cast.bitmapTexture(Diffuse));
				//geomMesh.material = geomMaterial;
				geomMesh.material = new ColorMaterial(0xcccccc);
				geomMesh.material.lightPicker = lightPicker;
				
				//cameraController = new HoverController(view.camera, geomMesh);
				
				view.scene.addChild(geomMesh);
			}
		}
		
		private function onMeshClick(e:MouseEvent3D):void
		{
			//trace(e.scenePosition);
			
			if ( e.shiftKey ) //add agent
			{
				var idx:int = addAgentNear( e.scenePosition );
				
				//test the location
				var agent:dtCrowdAgent = new dtCrowdAgent();
				agent.swigCPtr = crowd.getAgent(idx);
				
				trace("agent added at ",e.scenePosition," added to:",CModule.readFloat( agent.npos ), CModule.readFloat( agent.npos + 4 ), CModule.readFloat( agent.npos + 8));
				//agentObjectsByAgendIdx[ idx ].x = CModule.readFloat( agent.npos );
				//agentObjectsByAgendIdx[ idx ].y = CModule.readFloat( agent.npos +4 );
				//agentObjectsByAgendIdx[ idx ].z = CModule.readFloat( agent.npos +8 );
			}
			else
			{
				
				for ( var idx2:Object in agentObjectsByAgendIdx ) //iteratore through each object key
				{
					moveAgentNear(int(idx2), e.scenePosition);
				}
			}
		}
		
		private function moveAgentNear(idx:int, scenePosition:Vector3D):void
		{
			
			var posPtr:int = CModule.alloca(12);
			CModule.writeFloat(posPtr, scenePosition.x);
			CModule.writeFloat(posPtr + 4, scenePosition.y);
			CModule.writeFloat(posPtr + 8, scenePosition.z);
			
			var navquery:dtNavMeshQuery  = new dtNavMeshQuery();
			navquery.swigCPtr =  sample.getNavMeshQuery();
			
			var targetRef:int = CModule.alloca(4);
			var targetPos:int = CModule.alloca(12);
			
			var status:int = navquery.findNearestPoly(posPtr, crowd.getQueryExtents(), crowd.getFilter(), targetRef, targetPos);
			//var status:int = findNearestPoly2(navquery,posPtr, crowd.getQueryExtents(), crowd.getFilter(), targetRef, targetPos);
			
			
			//trace(CModule.readFloat(targetPos), CModule.readFloat(targetPos+4), CModule.readFloat(targetPos+8));
			
			var test1:int = CModule.read32(targetRef);
			var test2:Number = CModule.readFloat(targetPos);
		
			if ( targetRef > 0)
				crowd.requestMoveTarget(idx,targetRef, targetPos);
			
		}
		
		private function addAgentNear(scenePosition:Vector3D):int
		{
			var cube:CubeGeometry = new CubeGeometry(1, 1, 1);
			var cubeMesh:Mesh = new Mesh(cube, new ColorMaterial(0xff0000, 0.5));
			cubeMesh.position = scenePosition;
			view.scene.addChild(cubeMesh);
			
			var posPtr:int = CModule.alloca(12);
			CModule.writeFloat(posPtr, scenePosition.x);
			CModule.writeFloat(posPtr + 4, scenePosition.y);
			CModule.writeFloat(posPtr + 8, scenePosition.z);
			
			var params:dtCrowdAgentParams = dtCrowdAgentParams.create();
			params.radius  = MAX_AGENT_RADIUS;
			params.height  = 2;
			params.maxAcceleration = MAX_ACCEL;
			params.maxSpeed = MAX_SPEED;
			params.collisionQueryRange = 12;
			params.pathOptimizationRange = 30;
			
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
			
			var test1:int = CModule.read32(targetRef);
			var test2:Number = CModule.readFloat(targetPos);
		
			if (targetRef > 0)
				crowd.requestMoveTarget(idx, targetRef, targetPos);
			
				
			agentObjectsByAgendIdx[ idx ] = cubeMesh;
			
			return idx;
		}
		/**
		 * render loop
		 */
		private function onEnterFrame(e:Event):void
		{
			
			//set the camera height based on the terrain (with smoothing)
			///camera.y += 0.2*(terrain.getHeightAt(camera.x, camera.z) + 20 - camera.y);
			
			if (move) {
				cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
				
			}
			
			if (walkSpeed || walkAcceleration) {
				walkSpeed = (walkSpeed + walkAcceleration)*drag;
				if (Math.abs(walkSpeed) < 0.01)
					walkSpeed = 0;
				cameraController.incrementWalk(walkSpeed);
			}
			
			//trace(camera.x, camera.y, camera.z, cameraController.panAngle, cameraController.tiltAngle);
			
			if (strafeSpeed || strafeAcceleration) {
				strafeSpeed = (strafeSpeed + strafeAcceleration)*drag;
				if (Math.abs(strafeSpeed) < 0.01)
					strafeSpeed = 0;
				cameraController.incrementStrafe(strafeSpeed);
			}
			
			updateCrowd();
			
			updateAgents();
			
			
			view.render();
		}
		
		private function updateCrowd():void
		{
			var now:Number = getTimer() / 1000.0;
            var passedTime:Number = now - mLastFrameTimestamp;
            mLastFrameTimestamp = now;
			
			
			crowd.update(passedTime, crowdDebugPtr);
			
		}
		
		/**
		 * updates the position of the agent render objects with the recast agent positions
		 */
		private function updateAgents():void
		{
			//todo - change this to a vector or use domain memory to speed this up
			for ( var idx:Object in agentObjectsByAgendIdx ) //iteratore through each object key
			{
				var agent:dtCrowdAgent = new dtCrowdAgent();
				agent.swigCPtr = crowd.getAgent(int(idx));
				
				//trace("agent at:",CModule.readFloat( agent.npos ), CModule.readFloat( agent.npos + 4 ), CModule.readFloat( agent.npos + 8));
				agentObjectsByAgendIdx[ idx ].x = CModule.readFloat( agent.npos );
				agentObjectsByAgendIdx[ idx ].y = CModule.readFloat( agent.npos +4 );
				agentObjectsByAgendIdx[ idx ].z = CModule.readFloat( agent.npos +8 );
			}
		}
		
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			//onResize();
		}

		/**
		 * Key down listener for camera control
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
					walkAcceleration = walkIncrement;
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					walkAcceleration = -walkIncrement;
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
					strafeAcceleration = -strafeIncrement;
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					strafeAcceleration = strafeIncrement;
					break;
			}
		}
		
		/**
		 * Key up listener for camera control
		 */
		private function onKeyUp(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.DOWN:
				case Keyboard.S:
					walkAcceleration = 0;
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.RIGHT:
				case Keyboard.D:
					strafeAcceleration = 0;
					break;
				
			}
		}
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
		{
			move = true;
			lastPanAngle = cameraController.panAngle;
			lastTiltAngle = cameraController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Mouse up listener for navigation
		 */
		private function onMouseUp(event:MouseEvent):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Mouse stage leave listener for navigation
		 */
		private function onStageMouseLeave(event:Event):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
			awayStats.x = stage.stageWidth - awayStats.width;
		}
 
		
		//recast variables
		private var sample:Sample_TempObstacles;
		private var geom:InputGeom;
		private var crowd:dtCrowd;
		private var crowdDebugPtr:int;
		private var mLastFrameTimestamp:Number;
		private var agentObjectsByAgendIdx:Dictionary = new Dictionary();
		
		//engine variables
		private var view:View3D;
		private var camera:Camera3D;
		private var cameraController:FirstPersonController;
		
		//material objects
		private var geomMaterial:TextureMaterial;
		private var subsurfaceMethod:SubsurfaceScatteringDiffuseMethod;
		private var fresnelMethod:FresnelSpecularMethod;
		private var diffuseMethod:BasicDiffuseMethod;
		private var specularMethod:BasicSpecularMethod;
 
		private var _plane:Mesh;
		private var geomMesh:Mesh;
		private var light:PointLight;
		private var light2:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		
		//rotation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		//movement variables
		private var drag:Number = 0.5;
		private var walkIncrement:Number = 2;
		private var strafeIncrement:Number = 2;
		private var walkSpeed:Number = 10;
		private var strafeSpeed:Number = 10;
		private var walkAcceleration:Number = 0;
		private var strafeAcceleration:Number = 0;
		
		private var awayStats:AwayStats;
	}
	
}