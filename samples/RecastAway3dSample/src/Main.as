package 
{
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.controllers.FirstPersonController;
	import away3d.controllers.HoverController;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
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
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import org.recastnavigation.AS3_rcContext;
	import org.recastnavigation.CModule;
	import org.recastnavigation.dtCrowd;
	import org.recastnavigation.InputGeom;
	import org.recastnavigation.Sample_TempObstacles;
	
	/**
	 * ...
	 * @author Zo
	 */
	public class Main extends Sprite 
	{
		
		[Embed(source="../assets/dungeon.obj",mimeType="application/octet-stream")]
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
		
		private static var OBJ_FILE:String = "nav_test.obj";// "dungeon.obj"; //dungeon
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
		}
		
		private function initRecast():void
		{
			
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
			
			var startTime:Number = new Date().valueOf();
			var buildSuccess:Boolean = sample.handleBuild();
			trace("build time", new Date().valueOf() - startTime, "ms");
		}
		
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
 
			view = new View3D();
			
			view.camera.z = -600;
			view.camera.y = 500;
			view.camera.lookAt(new Vector3D());
			
			_plane = new Mesh(new PlaneGeometry(700, 700), new TextureMaterial(Cast.bitmapTexture(FloorDiffuse)));
			_plane.material.lightPicker = lightPicker;
			view.scene.addChild(_plane);
 
			//setup controller to be used on the camera
			
			//firstPersonCameraController = new FirstPersonController(view.camera);
 
			addChild(view);
 
			addChild(new AwayStats(view));
			
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);

		}
		
		private function initMaterials():void
		{
			//setup custom bitmap material
			geomMaterial = new TextureMaterial(new BitmapTexture(new Diffuse().bitmapData));
			//geomMaterial.normalMap = new BitmapTexture(new Normal().bitmapData);
			//geomMaterial.specularMap = new BitmapTexture(new Specular().bitmapData);
			//geomMaterial.lightPicker = lightPicker;
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
			light.z = 0;
			light.color = 0xffddbb;
			light.ambient = 1;
			
			lightPicker = new StaticLightPicker([light]);
 
			view.scene.addChild(light);
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
				geomMesh.geometry.scale(10); //TODO scale cannot be performed on mesh when using sub-surface diffuse method
				//geomMesh.y = -50;
				//geomMesh.rotationY = 180;
				//geomMesh.material =  new TextureMaterial(Cast.bitmapTexture(Diffuse));
				//geomMesh.material = geomMaterial;
				geomMesh.material = new ColorMaterial(0xcccccc);
				geomMesh.material.lightPicker = lightPicker;
				
				//cameraController = new HoverController(view.camera, geomMesh);
				
				view.scene.addChild(geomMesh);
			}
		}
		
		/**
		 * render loop
		 */
		private function _onEnterFrame(e:Event):void
		{
			view.render();
		}

 
		
		//recast variables
		private var sample:Sample_TempObstacles;
		private var geom:InputGeom;
		private var crowd:dtCrowd;
		
		//engine variables
		private var view:View3D;
		private var cameraController:HoverController;
		private var firstPersonCameraController:FirstPersonController;
		
		//material objects
		private var geomMaterial:TextureMaterial;
		private var subsurfaceMethod:SubsurfaceScatteringDiffuseMethod;
		private var fresnelMethod:FresnelSpecularMethod;
		private var diffuseMethod:BasicDiffuseMethod;
		private var specularMethod:BasicSpecularMethod;
 
		private var _plane:Mesh;
		private var geomMesh:Mesh;
		private var light:PointLight;
		private var lightPicker:StaticLightPicker;
	}
	
}