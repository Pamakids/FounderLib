package global
{
	/**
	 * 仓库管理
	 * @author Administrator
	 */	
	public class StoreManager
	{
		public function StoreManager()
		{
			dic = {};
		}
		
		/**
		 * 批量添加
		 */		
		public function addPropBatch(obj:Object):void
		{
			for(var id:String in obj)
			{
				addPropByID(id, obj.id);
			}
		}
		
		public function delPropBatch(list:Array):void
		{
			var id:String;
			var num:uint;
			for each(var arr:Array in list)
			{
				id = arr[0];
				num = arr[1];
				delPropByID( id, num );
			}
		}
		
		/**
		 * 添加
		 */		
		public function addPropByID(id:String, num:uint):void
		{
			if(dic[id])
				dic[id] += num;
			else
				dic[id] = num;
		}
		
		/**
		 * 删除
		 */		
		public function delPropByID(id:String, num:uint):void
		{
			if(!dic[id])
				return;
			dic[id] -= num;
			if(dic[id] <= 0)
				delete dic[id];
		}
		/**
		 * 查找数量
		 */		
		public function getPropNumByID(id:String):uint
		{
			return dic[id];
		}
		
		private var dic:Object;
		
		/**
		 * 获取物品清单
		 */		
		public function getPropList():Vector.<Array>
		{
			var list:Vector.<Array> = new Vector.<Array>();
			var arr:Array;
			for(var id:String in dic)
			{
				arr = [id, dic[id]];
				list.push( arr );
			}
			return list;
		}
		
		private static var _instance:StoreManager;
		public static function getInstance():StoreManager
		{
			if(!_instance)
				_instance = new StoreManager();
			return _instance;
		}
	}
}