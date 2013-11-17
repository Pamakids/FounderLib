package global
{
	public class DC
	{
		private static var _instance:DC;
		public static function instance():DC
		{
			if(_instance == null)
				_instance = new DC();
			return _instance;
		}
		
		public function DC()
		{
		}
		
		public var sampleXML:XML;
		public var mapXML:XML;
		public var propXML:XML;
	}
}