package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite
	import flash.events.MouseEvent;
	import com.adobe.images.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.net.FileReference;
	/**
	 * ...
	 * @author SXH
	 */
	public class Main extends Sprite
	{
		public var _Sprite:Sprite;
		public var Preservation_mc:MovieClip;
		//-----------------------------------
		public var content:BitmapData = new BitmapData(550,400,true,0x00FFFFFF);
		public function Main() {
			init();
		}
		public function init():void {
			
			_Sprite = new Sprite();
			_Sprite.graphics.beginFill(0xffffff);
            _Sprite.graphics.drawRect(0, 0, 550, 400);
            _Sprite.graphics.endFill();
			addChildAt(_Sprite,0);	
			_Sprite.addEventListener(MouseEvent.MOUSE_DOWN, OnMouaeDown);
			_Sprite.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			//--------------
			Preservation_mc.addEventListener(MouseEvent.CLICK, P_Click);
		}
		public function OnMouaeDown(e:MouseEvent):void {
			_Sprite.graphics.lineStyle(2, 0, 2);
            _Sprite.graphics.moveTo(mouseX, mouseY);
			_Sprite.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
		}
		public function OnMouseUp(e:MouseEvent):void {
			_Sprite.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
		}
		public function OnMouseMove(e:MouseEvent):void {
			_Sprite.graphics.lineTo(mouseX, mouseY);
		}
		public function P_Click(e:MouseEvent):void {
			var bit:BitmapData = new BitmapData(content.width,content.height);
        	bit.draw(_Sprite);
        	var jpg:JPGEncoder = new JPGEncoder();
        	var file:FileReference = new FileReference();
	       file.save(jpg.encode(bit), "flash.png"); 
		}
	}
	
}