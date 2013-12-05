package global
{
	import flash.display.DisplayObject;
	import flash.media.Sound;
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
		
		public function getResByName(name:String):DisplayObject
		{
			var c:Class=getDefinitionByName(name) as Class;
			return new c;
		}
		
		public function getSounds(name:String):Sound
		{
			var c:Class = getDefinitionByName(name) as Class;
			return new c;
		}
	}
}