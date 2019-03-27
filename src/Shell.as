package {
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author kingBook
	 * 2015/8/28 16:28
	 */
	public class Shell {
		public var loopMax:uint = 500;//允许查找文件夹的最大数量
		public var inputPath:String;
		public var imgOutputPath:String;
		public var xmlOutputPath:String;
		private const _pt:Point = new Point(0, 0);
		
		/**判断两个日期是不是一样*/
		public function equalDate(date0:Date, date1:Date):Boolean {
			return date0.fullYear == date1.fullYear
				&& date0.getMonth() == date1.getMonth()
				&& date0.day == date1.day
				&& date0.hours == date1.hours
				&& date0.getMinutes() == date1.getMinutes()
				&& date0.getSeconds() == date1.getSeconds();
		}
		
		/**打开浏览目录对话框*/
		public function browseForDirectory(file:File, title:String):void {
			file.browseForDirectory(title);
		}
		
		/**获取类*/
		public function getClass(domain:ApplicationDomain, defName:String):Class {
			var __Class:Class = domain.getDefinition(defName) as Class;
			return __Class;
		}
		
		/**获取定义对象*/
		public function getDefObj(domain:ApplicationDomain, defName:String):* {
			var __Class:Class = getClass(domain, defName);
			return (new __Class());
		}
		
		/** 将一个显示对象转换为bitmapData,记住x,y偏移量*/
		public function cacheDisObj(source:DisplayObject, transparent:Boolean = true, fillColor:uint = 0x00000000, scale:Number = 1):FrameInfo {
			var matrix:Matrix = source.transform.matrix;
			var w:uint, h:uint, x:int, y:int, rect:Rectangle;
			if (source.parent){
				rect = source.getBounds(source.parent);
				matrix.a *= scale;
				matrix.d *= scale;
				matrix.tx = int((matrix.tx - rect.x) * scale + 0.5);
				matrix.ty = int((matrix.ty - rect.y) * scale + 0.5);
			}else {
				rect = source.getBounds(null);
				matrix.a = scale;
				matrix.d = scale;
				matrix.tx = -int(rect.x * scale + 0.5);
				matrix.ty = -int(rect.y * scale + 0.5);
			} 
			//w, h 取上限
			w = uint(rect.width * scale + 0.9);
			h = uint(rect.height * scale + 0.9);
			//x,y 取source的局部坐标
			x = -matrix.tx;
			y = -matrix.ty;
			var bitmapData:BitmapData = new BitmapData(w < 1 ? 1 : w, h < 1 ? 1 : h , transparent, fillColor);
			bitmapData.draw(source, matrix, null, null, null, true);
			
			//剔除边缘空白像素
			var realRect:Rectangle = bitmapData.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if (!realRect.isEmpty() && (bitmapData.width != realRect.width || bitmapData.height != realRect.height)) {
				var realBitData:BitmapData = new BitmapData(realRect.width, realRect.height, transparent, fillColor);
				realBitData.copyPixels(bitmapData, realRect, _pt);
				bitmapData.dispose();
				bitmapData = realBitData;
				x += realRect.x;
				y += realRect.y;
			}
			
			//动态文本时tx,ty会出错
			if (source is TextField) {
				x = 0;
				y = 0 ;
			}
			return new FrameInfo(x, y, bitmapData);
		}
		
		/**将bitmapData保存为本地图片*/
		public function writeImage(file:File, bmd:BitmapData, isPng:Boolean=true, quality:Number=100):void {
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			var bytes:ByteArray;
			if(isPng) bytes = PNGEncoder.encode(bmd);
			else      bytes = (new JPGEncoder(quality)).encode(bmd);
			stream.writeBytes(bytes);
			stream.close();
		}
		
		/**保存文本文件*/
		public function writeTextFile(file:File, content:String, charSet:String = "utf-8"):void {
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeMultiByte(content,charSet);
			stream.close();
		}
		
		/**读取文本文件*/
		public function readTxtFile(file:File, charSet:String = "utf-8"):String {
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var str:String = stream.readMultiByte(stream.bytesAvailable, charSet);
			stream.close();
			return str;
		}

		/** 返回一个节点xmlStr*/
		public function getNodeXmlStr(nodeName:String, propXmlStr:String, content:String = ""):String {
			return "<" + nodeName+propXmlStr + (content?">"+content+"</"+nodeName+">":"/>");
		}
		
		/**返回属性xmlStr*/
		public function getPropXmlStr(propName:String, value:*):String{
			return " "+propName+"="+"\""+value+"\"";
		}
		
		public function spriteHasSprite(sp:Sprite):Boolean {
			var i:int = sp.numChildren;
			var child:DisplayObject;
			while (--i >= 0) {
				child = sp.getChildAt(i);
				if (child is Sprite) return true;
			}
			return false;
		}
		
		/**是否为空容器*/
		public function isEmptyContainer(container:DisplayObjectContainer):Boolean {
			if (container is MovieClip && (container as MovieClip).totalFrames > 1) {
				if (isEmptyMovieClip(container as MovieClip)) return true;
			}else if (container is Sprite) {
				if (isEmptySprite(container as Sprite)) return true;
			}
			return false;
		}
		
		public function isEmptyMovieClip(mc:MovieClip):Boolean {
			var len:int = mc.totalFrames;
			for (var i:int = 1; i <= len; i++ ) {
				mc.gotoAndStop(i);
				if (!isEmptySprite(mc as Sprite)) return false;
			}
			return true;
		}
		
		public function isEmptySprite(sprite:Sprite):Boolean {
			if (sprite.numChildren == 0) return true;
			var i:int = sprite.numChildren;
			var child:DisplayObject;
			while (--i>=0) {
				child = sprite.getChildAt(i);
				if (child is Shape) {
					return false
				}else if (child is MovieClip && (child as MovieClip).totalFrames > 1) {
					if (!isEmptyMovieClip(child as MovieClip)) return false;
				}else if (child is Sprite) {
					if (!isEmptySprite(child as Sprite)) return false;
				}
			}
			return true;
		}
		
		/**这个容器的所有子对象都是shape*/
		public function isShapeContainer(container:DisplayObjectContainer):Boolean {
			if (container is MovieClip && (container as MovieClip).totalFrames == 1) {
				if (isShapeSprite(container as Sprite)) return true;
			}else if (container is Sprite) {
				if (isShapeSprite(container as Sprite)) return true;
			}
			return false;
		}

		public function isShapeSprite(sprite:Sprite):Boolean {
			var i:int = sprite.numChildren;
			var child:DisplayObject;
			while (--i>=0) {
				child = sprite.getChildAt(i);
				if (child is MovieClip && (child as MovieClip).totalFrames > 1) {
					return false;
				}else if (child is Sprite) {
					if (!isShapeSprite(child as Sprite)) return false;
				}
			}
			return true;
		}
		
		/**将路径中的'\'转换为'/'*/
		public function convertNativePath(nativePath:String):String{
			return nativePath.replace(/\\/g,"/");
		}
		
	}

}