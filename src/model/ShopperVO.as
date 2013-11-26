package model
{
	

	/**
	 * 购物者数据
	 * @author Administrator
	 */	
	public class ShopperVO
	{
		/**
		 * @param type	素材索引
		 * @param list	需求清單
		 * @param wait	等待時間
		 */		
		public function ShopperVO(type:uint, list:Array, wait:Number)
		{
			this.type = type;
			this.shopperList = list;
			this.waitMax = wait;
		}
		
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
		/**
		 * 等待时间
		 */		
		public var waitMax:uint;
	}
}