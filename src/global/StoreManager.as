package global
{
	import model.BoughtGoodsVO;

	/**
	 * 仓库管理
	 * @author Administrator
	 */	
	public class StoreManager
	{
		public function StoreManager()
		{
			reCatchGoods();
		}
		
		public function reCatchGoods():void
		{
			dic = {};
			var goods:Array = [];
			
			//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
			//test
			var a:Array = [
				[101, 30],
				[102, 30],
				[103, 30],
				[104, 30],
				[105, 30],
				[201, 30],
				[202, 30],
				[203, 30],
				[204, 30],
				[301, 30],
				[302, 30],
				[303, 30],
				[304, 30],
				[305, 30]
			];
			for(var i:int = 0;i<a.length;i++)
			{
				var boughtGoodsVO:BoughtGoodsVO = new BoughtGoodsVO();
				boughtGoodsVO.id = a[i][0];
				boughtGoodsVO.quantity = a[i][1];
				goods.push( boughtGoodsVO );
			};
			//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
			
			//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
			//正确版本
			//goods = ServiceController.instance.boughtGoods;
			//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
			for each(var vo:BoughtGoodsVO in goods)
			{
				this.addPropByID( vo.id, vo.quantity );
			}
		}
		
		/**
		 * 批量添加
		 * [
		 * 		[id, num],
		 * 		[id, num]
		 * ]
		 */		
		public function addPropBatch(obj:Array):void
		{
			for each(var arr:Array in obj)
			{
				addPropByID(arr[0], arr[1]);
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
		 * [
		 * 		[id, num],
		 * 		[id, num],
		 * 		[id, num]
		 * ]
		 */		
		public function getPropList():Array
		{
			var list:Array = [];
			var arr:Array;
			for(var id:String in dic)
			{
				list.push( [id, dic[id]] );
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