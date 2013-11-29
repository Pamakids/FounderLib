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

		private var _loan:Number=0;

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

		public function getStaff(type:int):StaffVO
		{
			var vo:StaffVO;
			for each (vo in staffes)
			{
				if (vo.type == type)
					break;
			}
			return vo;
		}

		/**
		 * 贷款
		 */
		public function get loan():Number
		{
			return _loan;
		}

		/**
		 * @private
		 */
		public function set loan(value:Number):void
		{
			_loan=value;
			money=value + cash;
		}

		public function get money():int
		{
			return cash + loan;
		}

		public function set money(value:int):void
		{
			_money=value;
		}

		public function payRent():void
		{
			cash-=shop.rent;
		}
	}
}
