package model
{
	import controller.ServiceController;


	/**
	 * 购物者数据
	 * @author Administrator
	 */
	public class ShopperVO
	{
		/**
		 * @param type	素材索引
		 * @param list	需求清單
		 */
		public function ShopperVO(type:uint, list:Array)
		{
			this.type=type;

			var m:Number=Math.random();
			if (m > 0.5)
				this.type=0;
			else
				this.type=1;

			this.shopperList=list;
			var c:GameConfigVO=ServiceController.instance.config;
			maxQueueTime=c.getMaxQueueTime();
			maxWaitGoodsTime=c.getMaxWaitGoodsTime();
		}

		/**
		 * 最大排队时间
		 */
		public var maxQueueTime:Number;
		/**
		 * 最大等货时间
		 */
		public var maxWaitGoodsTime:Number;

		/**
		 * 购物者类型
		 */
		public var type:uint;
		/**
		 * [
		 * 		[id, num, crtPrice, catched],
		 * 		[id, num, crtPrice, catched]
		 * ]
		 */
		public var shopperList:Array;
	}
}
