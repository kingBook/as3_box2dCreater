package  {
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author kingBook
	 * 2014-08-21 10:56
	 */
	public class FrameInfo {
		private var _x:Number;
		private var _y:Number;
		private var _bitmapData:BitmapData;
		public function FrameInfo(x:Number, y:Number, bitmapData:BitmapData) {
			_x = x;
			_y = y;
			_bitmapData = bitmapData;
		}
		
		public function get x():Number { return _x; }
		
		public function get y():Number { return _y; }
		
		public function get bitmapData():BitmapData { return _bitmapData; }
		
	}

}