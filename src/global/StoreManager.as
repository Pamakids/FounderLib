package global
{
	import flash.display.Stage;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import controller.ServiceController;
	
	import model.BoughtGoodsVO;

	/**
	 * 仓库管理
	 * @author Administrator
	 */
	public class StoreManager
	{
		public function StoreManager()
		{
//			reCatchGoods();
		}

		public function reCatchGoods():void
		{
			var goods:Array=ServiceController.instance.boughtGoods;
			if (!goods)
			{
				goods=[];
				var a:Array=[[101, 300], [102, 300], [103, 300], [104, 300], [105, 300], [201, 300], [202, 300], [203, 300], [204, 300], [301, 300], [302, 300], [303, 300], [304, 300], [305, 300]];
				for (var i:int=0; i < a.length; i++)
				{
					var boughtGoodsVO:BoughtGoodsVO=new BoughtGoodsVO();
					boughtGoodsVO.id=a[i][0];
					boughtGoodsVO.quantity=a[i][1];
					goods.push(boughtGoodsVO);
				}
				;
			}
			for each (var vo:BoughtGoodsVO in goods)
			{
				this.addPropByID(vo.id, vo.quantity);
			}
		}

		public function delPropBatch(list:Array):void
		{
			var id:String;
			var num:int;
			for each (var arr:Array in list)
			{
				id=arr[0];
				num=arr[1];
				delPropByID(id, num);
			}
		}

		/**
		 * 添加
		 */
		public function addPropByID(id:String, num:uint):void
		{
			if (dic[id])
				dic[id]+=num;
			else
				dic[id]=num;
			
			test();
		}

		/**
		 * 删除
		 */
		public function delPropByID(id:String, num:uint):void
		{
			if (!dic[id])
				return;
			dic[id]-=num;
//			if (dic[id] <= 0)
//				delete dic[id];
			
			test();
		}
		
		/**
		 * 查找数量
		 */
		public function getPropNumByID(id:String):uint
		{
			return uint(dic[id]);
		}
		private var dic:Object={};

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
			var list:Array=[];
			var arr:Array;
			for (var id:String in dic)
			{
				list.push([id, dic[id]]);
			}
			return list;
		}

		public function clear():void
		{
			dic={};
		}

		public function delGoodsFromSource(list:Array):void
		{
			var goods:Array=ServiceController.instance.boughtGoods;
			if (goods)
			{
				var id:String;
				var count:uint;
				parent: for (var i:int=0; i < list.length; i++)
				{
					id=list[i][0];
					count=list[i][1];
					for each (var vo:BoughtGoodsVO in goods)
					{
						if (id == vo.id)
						{
							vo.quantity-=count;
							continue parent;
						}
					}
				}
			}
		}

		private static var _instance:StoreManager;

		public static function getInstance():StoreManager
		{
			if (!_instance)
				_instance=new StoreManager();
			return _instance;
		}

		/**
		 * 获取物品采购价格
		 * @return 
		 */		
		public static function getInPriceByID(propID:String):Number
		{
			var obj:Object = DC.instance().propObj;
			for each(var o:Object in obj)
			{
				if(o.id == propID)
					return o.inPrice;
			}
			return 0;
		}
		
		private var tf:TextField;
		private function test():void
		{
			if(!tf)
			{
				tf = new TextField();
				tf.width = 500;
				tf.height = 768;
				MC.instance().mainScreen.addChild( tf );
				tf.mouseEnabled = false;
				tf.textColor = 0xffffff;
				tf.filters = [new GlowFilter(0x0, .8, 2, 2, 100, 1)];
			}
			var txt:String = "";
			for(var id:String in _instance.dic)
			{
				txt += ( DC.instance().getPropNameByID(id) + " : " + dic[id] + "\n" );
			}
			tf.text = txt;
		}
		
	}
}
