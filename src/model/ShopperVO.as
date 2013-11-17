package model
{
	import global.PlansManager;

	/**
	 * 购物者数据
	 * @author Administrator
	 */	
	public class ShopperVO
	{
		/**
		 * @param type
		 * @param list
		 */		
		public function ShopperVO(type:uint, list:Array)
		{
			this.type = type;
			this.shopperList = list;
			init();
		}
		
		private function init():void
		{
			var price:Number;
			for(var i:int = shopperList.length-1;i>=0;i--)
			{
				var arr:Array = shopperList[i];
				price = PlansManager.getInstance().getPriceByID( arr[0] );
				arr.push( price );	//当前单价
			}
		}
		
		/**
		 * 购物者类型
		 */		
		public var type:uint;
		/**
		 * [
		 * 		[id, num, crtPrice, catched]
		 * ]
		 */		
		public var shopperList:Array;
	}
}