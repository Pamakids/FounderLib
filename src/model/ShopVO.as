package model
{

	/**
	 * 店铺VO
	 * @author mani
	 */
	[Bindable]
	public class ShopVO
	{
		public function ShopVO()
		{
		}

		public var id:String;
		public var name:String;
		public var rent:Number;
		public var visit:Number;
	}
}
