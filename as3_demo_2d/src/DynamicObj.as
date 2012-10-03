package  
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Zo
	 */
	public class DynamicObj extends Sprite 
	{
		
		public function DynamicObj() 
		{
			
			//test verts
			var verts:Array = [ new Point( -4.3, -2.6), new Point( -1.2, 6.4), new Point(4.7, 3.2), new Point( 2.7, -5.5), new Point( -2.7, -5.5) ];
			
			var str:String = "";
			
			var i:int = 0;
			var v:Point;
			var v1:int;
			var v2:int;
			var v3:int;
			var v4:int;
			
			var extrudeHeight:Number = 1.0;
			var xSum:Number=0;
			var ySum:Number=0;
			
			str += "o object1\n";
			//first add all the orginal 2d verts
			for ( i = 0; i < verts.length; i++)
			{
				
				v = verts[i];
				str += "v " + v.x + " 0 " + v.y + "\n";  //add the original verts to the obj file, where y is the z value
				xSum += v.x;
				ySum += v.y;
				//str += "v " + v.x + " " + extrudeHeight + " " + v.y + "\n";  //add the extruded 3d vert
			}
			
			var xAvg:Number = xSum / verts.length;
			var yAvg:Number = ySum / verts.length;
			
			//add the extruded 3d vert
			str += "v " + xAvg + " " + extrudeHeight + " " + yAvg + "\n";
			
			//now add the faces for the verts
			/*
			for ( i = 1; i <= verts.length * 2; i+=2 )
			{
				if ( i == (verts.length * 2) -1 ) //last verts, connect back to first 2
				{
					v1 = i ;
					v2 = i + 1;
					v3 = 1;
					v4 = 2;
				}
				else
				{
					v1 = i ;
					v2 = i + 1;
					v3 = i + 2;
					v4 = i + 3;
				}
				str += "f " + v3 + " " + v4 + " " + v2 + " " + v1 + "\n";
 			}
			*/
			for ( i = 1; i <= verts.length; i++ )
			{
				if ( i == verts.length ) //last verts, connect back to first 2
				{
					v1 = i ;
					v2 = 1;
					v3 = verts.length + 1;
				}
				else
				{
					v1 = i ;
					v2 = i + 1;
					v3 = verts.length + 1; //extruded vert
				}
				str += "f " + v2 + " " + v3 + " " + v1 + "\n";
 			}
			
			
			/*
			//add the bottom to close the object
			//now add the top to close the object
			str += "f ";
			for ( i = 1; i < verts.length * 2; i+=2 )
			{
				str += i + " ";
			}
			str += "\n"; 
			
			//now add the top to close the object
			str += "f ";
			for ( i = 2; i <= verts.length * 2; i+=2 )
			{
				str += i + " ";
			}
			str += "\n"; 
			*/
			
			//now add the 'ground plane', face in form of 2 1 3 4
			v4 = verts.length + 1; //the extruded vert
			
			var bounds:Rectangle = new Rectangle( -10, -10, 20, 20);
			
			str += "o ground\n";
			str += "v " + bounds.topLeft.x + " 0 " + bounds.topLeft.y + " \n";
			str += "v " + bounds.topLeft.x + " 0 " + bounds.bottomRight.y + " \n";
			str += "v " + bounds.bottomRight.x + " 0 " + bounds.bottomRight.y + " \n";
			str += "v " + bounds.bottomRight.x + " 0 " + bounds.topLeft.y + " \n";
			str += "f " + (v4 + 1) + " " + (v4 + 2) + " " + (v4 + 3) + " " + (v4 + 4) + "\n";
			trace( str );
		}
		
	}

}