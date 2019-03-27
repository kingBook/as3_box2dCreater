package {
	import com.bit101.components.CheckBox;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import nape.phys.Body;
	import nape.shape.Polygon;
	import nape.geom.Vec2;
	/**
	 * ...
	 * @author kingBook
	 * 2015/8/28 16:27
	 */
	public class Main extends MovieClip {
		private var _ui:UI;
		private var _shell:Shell;
		private var _exproting:Boolean;
		private var _modifiDateList:*;
		private var _nativeDragEnterPath:String = "";
		private var _browseInputRootFile:File;//浏览输入的根文件夹
		private var _loaderDomain:ApplicationDomain;
		//
		private var _convertDataList:Array;
		private var _convertCount:int;
		//
		private var _multiframeMc:MovieClip;
		private var _multiframeMcName:String;
		private var _multiframeCount:int;
		
		public function Main() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(e:Event = null):void {
			if (e) removeEventListener(Event.ADDED_TO_STAGE, init);
			_shell = new Shell();
			_ui = new UI(this, _shell);
			initInputPath();
			initOutputPath();
			_browseInputRootFile = File.desktopDirectory;
			_ui.browseInputBtn.addEventListener(MouseEvent.CLICK, browseInputHandler);
			
			_ui.xmlPathBrowseBtn.addEventListener(MouseEvent.CLICK, browseXmlOutputPathHandler);
			_ui.exportBtn.addEventListener(MouseEvent.CLICK, exportHandler);
			
			stage.nativeWindow.addEventListener(Event.CLOSING, closeingHandler);
			stage.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnter);
			stage.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, nativeDragExit);
		}
		
		private function nativeDragEnter(e:NativeDragEvent):void{
			var format:String = ClipboardFormats.FILE_LIST_FORMAT;
			var files:Array = e.clipboard.getData(format) as Array;
			var file:File = files[0] as File;
			_nativeDragEnterPath=file.nativePath;
		}
		private function nativeDragExit(e:NativeDragEvent):void {
			if (!_nativeDragEnterPath) return;
			var file:File = new File(_nativeDragEnterPath);
			if(file.extension=="swf"||file.extension=="png"){
				setInputPath(_nativeDragEnterPath);
			}
			_nativeDragEnterPath = "";
		}
		
		/**关闭程序前*/
		private function closeingHandler(e:Event):void {
			//保存输入地址列表
			var xmlStr:String="";
			if(_ui.importBox.items.length>0){
				xmlStr += _shell.getNodeXmlStr("items", "", _ui.importBox.items[0]);
				xmlStr = _shell.getNodeXmlStr("site", "", xmlStr);
				var xml:XML = new XML(xmlStr);
				exportInputItemsXML(xml);
			}
			//保存xml输出地址列表
			xmlStr = "";
			if (_ui.xmlPathBox.items.length > 0) {
				xmlStr += _shell.getNodeXmlStr("items", "", _ui.xmlPathBox.items[0]);
				xmlStr = _shell.getNodeXmlStr("site", "", xmlStr);
				xml = new XML(xmlStr);
				exportOutputItemsXML(null, xml);
			}
		}
		/**更新修改日期列表*/
		private function updateModifiDateList():void {
			var file:File = new File(File.applicationDirectory.nativePath + "/config/modifiDate.xml");
			_modifiDateList = { };
			if (file.exists) {
				var xml:XML = new XML(_shell.readTxtFile(file));
				var i:int = xml.items.length();
				while (--i>=0) _modifiDateList[xml.items[i].@name] = xml.items[i].@date;
			}
		}
		private function initInputPath():void {
			var xmlFile:File = new File(File.applicationDirectory.nativePath+"/config/inputItems.xml");
			var xml:XML;
			if (xmlFile.exists) xml = new XML(_shell.readTxtFile(xmlFile));
			
			//检查是否存在，更换电脑时会变
			if(xml){
				var file:File = new File(xml.items[0]);
				if (file.exists) setInputPath(xml.items[0]);
			}
		}
		private function initOutputPath():void {
			var xml:XML;
			var imgFile:File = new File(File.applicationDirectory.nativePath+"/config/imgOutputItems.xml");
			if (imgFile.exists) {
				xml = new XML(_shell.readTxtFile(imgFile));
				
				//检查是否存在，更换电脑时会变
				imgFile = new File(xml.items[0]);
				if(imgFile.exists) setOutputPath(xml.items[0], null);
			}
			var xmlFile:File = new File(File.applicationDirectory.nativePath + "/config/xmlOutputItems.xml");
			if (xmlFile.exists) {
				xml = new XML(_shell.readTxtFile(xmlFile));
				
				//检查是否存在，更换电脑时会变
				xmlFile = new File(xml.items[0]);
				if(xmlFile.exists) setOutputPath(null, xml.items[0]);
			}
		}
		private function browseInputHandler(e:MouseEvent):void {
			//浏览输入位置
			_browseInputRootFile.browse([new FileFilter("文件","*.swf;*.png")]);
			_browseInputRootFile.addEventListener(Event.SELECT, selectInputHandler);
		}
		private function selectInputHandler(e:Event):void {
			//返回输入位置
			var file:File = e.target as File;
			file.removeEventListener(Event.SELECT, selectInputHandler);
			setInputPath(file.nativePath);
		}
		private function setInputPath(path:String):void {
			// 设置输入位置
			_ui.importBox.addItemAt(path, 0);
			_ui.importBox.selectedItem = path;
			_shell.inputPath = path;
		}

		private function browseXmlOutputPathHandler(e:MouseEvent):void {
			//浏览xml输出位置
			var file:File;
			//如果输入位置不为null时，输入位置作为根目录打开浏览对话框
			if (_shell.inputPath) {
				var path:String = _shell.inputPath.substring(0, _shell.inputPath.lastIndexOf("\\"));
				file = new File(path);
			}else{
				file = File.desktopDirectory;
			}
			file.browseForDirectory("xml导出位置");
			file.addEventListener(Event.SELECT, selectXmlOutputPathHandler);
		}
		private function selectXmlOutputPathHandler(e:Event):void {
			var file:File = e.target as File;
			file.removeEventListener(Event.SELECT, selectXmlOutputPathHandler);
			var item:Object = file.nativePath;
			setOutputPath(null, file.nativePath);
		}
		private function setOutputPath(imgOutputPath:String, xmlOutputPath:String):void {
			if (imgOutputPath) {
				_ui.imgPathBox.addItemAt(imgOutputPath,0);
				_ui.imgPathBox.selectedItem = imgOutputPath;
				_shell.imgOutputPath = imgOutputPath;
			}
			if (xmlOutputPath) {
				_ui.xmlPathBox.addItemAt(xmlOutputPath,0);
				_ui.xmlPathBox.selectedItem = xmlOutputPath;
				_shell.xmlOutputPath = xmlOutputPath;
			}
		}
		/**导出*/
		private function exportHandler(e:MouseEvent):void {
			if(_shell.inputPath == null){
				print("请填写swf/png文件位置", 0xff0000);
				return;
			}
			if (_shell.xmlOutputPath == null) {
				print("请填写xml保存位置", 0xff0000);
				return;
			}
			
			if (_exproting) {
				print("已经在导出了......", 0xff0000);
				return;
			}
			_exproting = true;
			
			var file:File = new File(_shell.inputPath);
			if (file.extension == "swf" || file.extension == "png") {
				var loader:Loader = new Loader();
				loader.load(new URLRequest(_shell.convertNativePath(file.nativePath)));
				loader.contentLoaderInfo.addEventListener(Event.INIT,loaded);
			}
		}
		
		private function loaded(e:Event):void{
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			loaderInfo.removeEventListener(Event.INIT, loaded);
			//
			var file:File = new File(_shell.inputPath);
			if (file.extension == "swf") {
				_convertDataList = getSingleFrameMcNamesList();
				_loaderDomain = loaderInfo.applicationDomain;
				_convertCount=0;
				//
				_multiframeMcName=_ui.frameMcInputText.text;
				if(_multiframeMcName){
					_multiframeMc=getDefObj(_multiframeMcName) as MovieClip;
					_multiframeMc.gotoAndStop(1);
					if(!_multiframeMc)print("没有找到定义名为"+_multiframeMcName+"的MovieClip");
				}
				_multiframeCount=1;
				//
				if(_convertDataList.length>0||_multiframeMc){
					this.addEventListener(Event.ENTER_FRAME,update);
				}else{
					print("请正确填写元件定义名...",0xff0000);
					dispose();
				}
			}else if(file.extension == "png"){
				var bmd:BitmapData = (loaderInfo.content as Bitmap).bitmapData;
				var name:String = file.name.substring(0, file.name.length - 4);//去掉扩展名后的名字
				convertBitmapData(name, bmd);
				_exproting = false;
				print("正在导出 "+file.name+" ...");
				print("完成导出!");
			}
		}
		
		private function dispose():void{
			_convertDataList = null;
			_loaderDomain = null;
			_multiframeMc=null;
			_exproting = false;
			_multiframeMcName=null;
		}
		
		private function getSingleFrameMcNamesList():Array{
			var list:Array=[];
			//
			var keyStr:String = _ui.mcKeyInputText.text;
			var min:uint = uint(_ui.mcIdMinInputText.text);
			var max:uint = uint(_ui.mcIdMaxInputText.text);
			if(min>0&&max>0&&keyStr){
				for(var i:int=min; i<=max; i++){
					list.push(keyStr+i);
				}
			}
			//
			list = list.concat(_ui.customKeyInputText.text.split(","));
			return list;
		}
		
		private function update(e:Event):void{
			var name:String;
			//
			if(_multiframeMc&&_multiframeCount<=_multiframeMc.totalFrames){
				_multiframeMc.gotoAndStop(_multiframeCount);
				addChildAt(_multiframeMc,0);
				name=_multiframeMcName+"_"+_multiframeCount;
				convertDisObj(name,_multiframeMc);
				_multiframeMc.parent.removeChild(_multiframeMc);
				_multiframeCount++;
			}else if(_convertCount<_convertDataList.length){
				name = _convertDataList[_convertCount];
				if(name){
					var obj:*=getDefObj(name);
					if(obj is DisplayObject){
						var disObj:DisplayObject = obj as DisplayObject;
						addChildAt(disObj,0);
						convertDisObj(name,disObj);
						disObj.parent.removeChild(disObj);
					}else if(obj is BitmapData){
						convertBitmapData(name,obj as BitmapData);
					}
				}
				_convertCount++;
			}else{
				e.target.removeEventListener(Event.ENTER_FRAME,update);
				dispose();
				print("完成导出!");
			}
			
		}
		
		private function getDefObj(defName:String):*{
			if(_loaderDomain==null)return;
			if(_loaderDomain.hasDefinition(defName)){
			var _Class:Class = _loaderDomain.getDefinition(defName) as Class;
			var obj:*=new _Class();
			return obj;
			}
			return null;
		}
		
		private function convertDisObj(name:String,disObj:DisplayObject):void{
			var iso:DisplayObjectIso=new DisplayObjectIso(disObj);
			var body:Body=IsoBody.run(iso,iso.bounds,Vec2.weak(1,1));
			var xml:XML=createXML(body);
			exprortXml(xml.toXMLString(), name);
			print("正在导出 " + name+".xml ...");
		}
		
		private function convertBitmapData(name:String,bmd:BitmapData):void{
			var iso:BitmapDataIso = new BitmapDataIso(bmd);
			var body:Body = IsoBody.run(iso, iso.bounds,Vec2.weak(1,1));
			var xml:XML = createXML(body);
			exprortXml(xml.toXMLString(), name);
			print("正在导出 " + name+".xml ...");
		}
		
		private function createXML(body:Body):XML{
			var xml:XML = 
				<bodydef>
					<bodies numBodies="1">
						<body>
							<fixture></fixture>
						</body>
					</bodies>
				</bodydef>;
			var fixtureNode:XML = xml.bodies[0].body[0].fixture[0];
			fixtureNode.@numPolygons=body.shapes.length;
			var i:int,j:int;
			var polygon:Polygon;
			for(i=0; i<body.shapes.length; i++){
				polygon=body.shapes.at(i).castPolygon;
				fixtureNode.polygon[i]="";
				fixtureNode.polygon[i].@numVertexes=polygon.localVerts.length;
				for(j=0; j<polygon.localVerts.length;j++){
					fixtureNode.polygon[i].vertex[j]="";
					fixtureNode.polygon[i].vertex[j].@x=polygon.localVerts.at(j).x;
					fixtureNode.polygon[i].vertex[j].@y=polygon.localVerts.at(j).y;
				}
			}
			xml.normalize();
			return xml;
		}
		
		/** 导出元件完成消息*/
		private function exprotMcFinishMssage(curSwfName:String, defName:String, frame:uint):void {
			print("导出"+curSwfName+"中的元件：" + defName+" "+ (frame<10?"0":"") + frame +" 帧完成!", 0xff0000);
		}
		/**导出xml到本地*/
		private function exprortXml(xmlStr:String, fileName:String):void {
			var file:File = new File(_shell.xmlOutputPath + "/" + fileName+".xml");
			xmlStr = xmlStr.replace(/ xmlns="Main">/g,">");
			//trace(xmlStr);
			_shell.writeTextFile(file, xmlStr);
		}
		/**保存输入位置列表*/
		private function exportInputItemsXML(xml:XML):void {
			var file:File = new File(File.applicationDirectory.nativePath + "/config/inputItems.xml");
			_shell.writeTextFile(file, xml.toXMLString())
		}
		/**保存输出位置列表*/
		private function exportOutputItemsXML(imgOutputXml:XML, xmlOutPutXml:XML):void {
			if(imgOutputXml){
				var file:File = new File(File.applicationDirectory.nativePath + "/config/imgOutputItems.xml");
				_shell.writeTextFile(file, imgOutputXml.toXMLString());
			}
			if (xmlOutPutXml) {
				file = new File(File.applicationDirectory.nativePath + "/config/xmlOutputItems.xml");
				_shell.writeTextFile(file, xmlOutPutXml.toXMLString());
			}
		}
		/**保存记录swf的修改日期*/
		private function exportModifiDateXML():void {
			var xmlStr:String = "";
			for (var key:String in _modifiDateList) {
				xmlStr += _shell.getNodeXmlStr("items", _shell.getPropXmlStr("name", key)
													  + _shell.getPropXmlStr("date", _modifiDateList[key])
													  ,"");
			}
			xmlStr = _shell.getNodeXmlStr("site", "", xmlStr);
			var xml:XML = new XML(xmlStr);
			var file:File = new File(File.applicationDirectory.nativePath + "/config/modifiDate.xml");
			_shell.writeTextFile(file, xml.toXMLString());
		}
		/**打印消息*/
		private function print(text:String, color:uint = 0x000000):void {
			var date:Date = new Date();
			text = (date.getHours()   <10?"0":"")  +date.getHours()        + ":" +
				   (date.getMinutes() <10?"0":"")  +date.getMinutes()      + ":" +
				   (date.getSeconds() <10?"0":"")  +date.getSeconds()      + " " + text;
			text = "<font color='#" + color.toString(16) + "'>" +text + "</font>";
			_ui.textArea.text = _ui.textArea.text+"\n"+text;
		}
	
	}

}



import nape.geom.AABB;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.IsoFunction;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.shape.Polygon;
 
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
 
class IsoBody {
    public static function run(iso:IsoFunction, bounds:AABB, granularity:Vec2=null, quality:int=2, simplification:Number=1.5):Body {
        var body:Body = new Body();
 
        if (granularity==null) granularity = Vec2.weak(8, 8);
        var polys:GeomPolyList = MarchingSquares.run(iso, bounds, granularity, quality);
        for (var i:int = 0; i < polys.length; i++) {
            var p:GeomPoly = polys.at(i);
 
            var qolys:GeomPolyList = p.simplify(simplification).convexDecomposition(true);
            for (var j:int = 0; j < qolys.length; j++) {
                var q:GeomPoly = qolys.at(j);
 
                body.shapes.add(new Polygon(q));
 
                // Recycle GeomPoly and its vertices
                q.dispose();
            }
            // Recycle list nodes
            qolys.clear();
 
            // Recycle GeomPoly and its vertices
            p.dispose();
        }
        // Recycle list nodes
        polys.clear();
 
        // Align body with its centre of mass.
        // Keeping track of our required graphic offset.
        var pivot:Vec2 = body.localCOM.mul(-1);
       // body.translateShapes(pivot);
 
        body.userData.graphicOffset = pivot;
        return body;
    }
}
 
class DisplayObjectIso implements IsoFunction {
    public var displayObject:DisplayObject;
    public var bounds:AABB;
 
    public function DisplayObjectIso(displayObject:DisplayObject):void {
        this.displayObject = displayObject;
        this.bounds = AABB.fromRect(displayObject.getBounds(displayObject));
    }
 
    public function iso(x:Number, y:Number):Number {
        // Best we can really do with a generic DisplayObject
        // is to return a binary value {-1, 1} depending on
        // if the sample point is in or out side.
 
        return (displayObject.hitTestPoint(x, y, true) ? -1.0 : 1.0);
    }
}
 
class BitmapDataIso implements IsoFunction {
    public var bitmap:BitmapData;
    public var alphaThreshold:Number;
    public var bounds:AABB;
 
    public function BitmapDataIso(bitmap:BitmapData, alphaThreshold:Number = 0x80):void {
        this.bitmap = bitmap;
        this.alphaThreshold = alphaThreshold;
        bounds = new AABB(0, 0, bitmap.width, bitmap.height);
    }
 
    public function graphic():DisplayObject {
        return new Bitmap(bitmap);
    }
 
    public function iso(x:Number, y:Number):Number {
        // Take 4 nearest pixels to interpolate linearly.
        // This gives us a smooth iso-function for which
        // we can use a lower quality in MarchingSquares for
        // the root finding.
 
        var ix:int = int(x); var iy:int = int(y);
        //clamp in-case of numerical inaccuracies
        if(ix<0) ix = 0; if(iy<0) iy = 0;
        if(ix>=bitmap.width)  ix = bitmap.width-1;
        if(iy>=bitmap.height) iy = bitmap.height-1;
 
        // iso-function values at each pixel centre.
        var a11:Number = alphaThreshold - (bitmap.getPixel32(ix,iy)>>>24);
        var a12:Number = alphaThreshold - (bitmap.getPixel32(ix+1,iy)>>>24);
        var a21:Number = alphaThreshold - (bitmap.getPixel32(ix,iy+1)>>>24);
        var a22:Number = alphaThreshold - (bitmap.getPixel32(ix+1,iy+1)>>>24);
 
        // Bilinear interpolation for sample point (x,y)
        var fx:Number = x - ix; var fy:Number = y - iy;
        return a11*(1-fx)*(1-fy) + a12*fx*(1-fy) + a21*(1-fx)*fy + a22*fx*fy;
    }
}