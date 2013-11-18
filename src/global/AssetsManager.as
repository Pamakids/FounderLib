package global
{
//	import com.riaidea.utils.zip.ZipArchive;
//	import com.riaidea.utils.zip.ZipEvent;
	
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;
	
	public class AssetsManager
	{
		private static var _instance:AssetsManager;
		public static function instance():AssetsManager
		{
			if(!_instance)
				_instance = new AssetsManager();
			return _instance;
		}
		
		public function AssetsManager()
		{
		}
		
//		private var info:LoaderInfo;
//		public var zipArchive:ZipArchive;
//		private var onComplete:Function;
		
//		public function loadZip(url:String/*, loadBar:loadBar=null*/, complete:Function=null):void
//		{
//			
//			if(!zipArchive)
//				zipArchive = new ZipArchive();
//			zipArchive.load(url);
////			zipArchive.addEventListener(ZipEvent.LOADED, loadHandler);
//			zipArchive.addEventListener(ZipEvent.PROGRESS, loadHandler);
//			zipArchive.addEventListener(ZipEvent.INIT, loadHandler);
//			zipArchive.addEventListener(ZipEvent.ERROR, loadHandler);
//			
//			onComplete = complete;
//		}
		
//		protected function loadHandler(e:ZipEvent):void
//		{
//			switch(e.type)
//			{
//				case ZipEvent.PROGRESS:
//					trace(e.message.bytesLoaded + "/" + e.message.bytesTotal);
//					break;
////				case ZipEvent.LOADED:
////					break;
//				case ZipEvent.INIT:
//					initAssets();
//					break;
//				case ZipEvent.ERROR:
//					break;
//			}
//		}		
		
//		public var initialized:Boolean = false;
//		private var assets:Loader;
//		private function initAssets():void
//		{
//			assets = new Loader();
//			assets.contentLoaderInfo.addEventListener(Event.COMPLETE, onAsyncBitmap);
//			assets.loadBytes(zipArchive.getFileByName("assets.swf").data);
//			function onAsyncBitmap(evt:Event):void 
//			{
//				initialized = true;
//				onComplete.call();
//			}
//		}
		
//		public function parse():void
//		{
//			DC.instance().mapXML = new XML( zipArchive.getFileByName("map.xml").data );
//			DC.instance().sampleXML = new XML( zipArchive.getFileByName("sample.xml").data );
//			DC.instance().propXML = new XML( zipArchive.getFileByName("prop.xml").data );
//		}
		
		public function getResByName(name:String):DisplayObject
		{
			var c:Class=getDefinitionByName(name) as Class;
			return new c;
		}
	}
}