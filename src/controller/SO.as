package controller
{
	import com.pamakids.utils.Singleton;

	import flash.net.SharedObject;

	public class SO extends Singleton
	{
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
			var so:SharedObject=SharedObject.getLocal(key);
			so.data[key]=value;
			so.flush();
		}

		public function deleteKey(key:String):void
		{
			var so:SharedObject=SharedObject.getLocal(key);
			delete so.data[key];
			so.flush();
		}

		public function getKV(key:String):Object
		{
			var so:SharedObject=SharedObject.getLocal(key);
			return so.data[key];
		}
	}
}
