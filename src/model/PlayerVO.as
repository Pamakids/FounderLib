package model
{

	[Bindable]
	public class PlayerVO
	{
		public function PlayerVO()
		{
		}

		/**
		 * 现金
		 */
		public var cash:Number=0;

		/**
		 * 贷款
		 */
		public var loan:Number=0;

		/**
		 * 员工
		 */
		public var staffes:Array;

		/**
		 * 货物
		 */
		public var goods:Array;

		/**
		 * 销售策略
		 */
		public var saleStrategies:Array;

		public var shop:ShopVO;

		public var user:UserVO;

		private var _money:int;

		public function get money():int
		{
			return cash + loan;
		}

		public function set money(value:int):void
		{
			_money=value;
		}

	}
}
