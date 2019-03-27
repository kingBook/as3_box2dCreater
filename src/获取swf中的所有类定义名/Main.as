package {

	import flash.display.MovieClip;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.display.LoaderInfo;


	public class Main extends MovieClip {

		//[Embed(source="items.swf",mimeType="application/octet-stream")]
		private const Items_SWF:Class;
		
		public function Main() {
			if (stage) init();
			else       addEventListener(Event.ADDED_TO_STAGE,init);

		}
		
		private function init(e:Event=null):void {
			if(e) removeEventListener(Event.ADDED_TO_STAGE,init);
			
			////嵌入形式
			var lc:LoaderContext = new LoaderContext();
			lc.applicationDomain = ApplicationDomain.currentDomain;
			var ldr:Loader;
			ldr = new Loader();
			ldr.load(new URLRequest("items.swf"), lc);
			ldr.contentLoaderInfo.addEventListener(Event.INIT, embedCompelte);
			
			/////使用urlloader加载形式
			/* var loader:URLLoader=new URLLoader();
            loader.dataFormat=URLLoaderDataFormat.BINARY;
            loader.addEventListener(Event.COMPLETE,completeHandler);
            loader.load(new URLRequest("items.swf"));*/
		}
		
		private function embedCompelte(e:Event):void {
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			
			var bytes:ByteArray =loaderInfo.bytes;
            bytes.endian=Endian.LITTLE_ENDIAN;
            bytes.writeBytes(bytes,8);
           // bytes.uncompress();////嵌入形式不需要解压
            bytes.position=Math.ceil(((bytes[0]>>>3)*4+5)/8)+4;
            while(bytes.bytesAvailable>2){
                var head:int=bytes.readUnsignedShort();
				
                var size:int=head&63;
                if (size==63)size=bytes.readInt();
                if (head>>6!=76)bytes.position+=size;
                else {
                    head=bytes.readShort();
                    for(var i:int=0;i<head;i++){
                        bytes.readShort();
                        size=bytes.position;
                        while(bytes.readByte()!=0){}
                        size=bytes.position-(bytes.position=size);
                        trace("loader:",bytes.readUTFBytes(size));
                    }
                }
            }
			//trace(ApplicationDomain.currentDomain.getDefinition("AA"));
		}
		
		private function completeHandler(e:Event):void {
			e.target.removeEventListener(Event.COMPLETE, arguments.callee);
			//
			trace("------------------------------------------------------------");
			var bytes:ByteArray=URLLoader(e.target).data;
            bytes.endian=Endian.LITTLE_ENDIAN;
            bytes.writeBytes(bytes,8);
            bytes.uncompress();
            bytes.position=Math.ceil(((bytes[0]>>>3)*4+5)/8)+4;
            while(bytes.bytesAvailable>2){
                var head:int=bytes.readUnsignedShort();
                var size:int=head&63;
                if (size==63)size=bytes.readInt();
                if (head>>6!=76)bytes.position+=size;
                else {
                    head=bytes.readShort();
                    for(var i:int=0;i<head;i++){
                        bytes.readShort();
                        size=bytes.position;
                        while(bytes.readByte()!=0){}
                        size=bytes.position-(bytes.position=size);
                        trace("urlloader:",bytes.readUTFBytes(size));
                    }
                }
            }
			
		}
	}

}