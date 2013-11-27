package controller
{
	import com.pamakids.utils.Singleton;

	import flash.net.SharedObject;

	public class SO extends Singleton
	{
		private var so:SharedObject;

		public function SO()
		{
			super();
		}

		public static function get i():SO
		{
			return Singleton.getInstance(SO);
		}

		public function setKV(key:String, value:Object):void
		{
			loadSO();
			so.data[key]=value;
			unloadSO();
		}

		public function deleteKey(key:String):void
		{
			loadSO();
			delete so.data[key];
			so.flush();
			unloadSO();
		}

		public function getKV(key:String):Object
		{
			loadSO();
			var data:Object=so.data[key];
			unloadSO();
			return data;
		}

		private function loadSO():void
		{
			so=SharedObject.getLocal("founder", "/");
		}

		private function unloadSO():void
		{
			so.flush();
			so=null;
		}
	}
}
