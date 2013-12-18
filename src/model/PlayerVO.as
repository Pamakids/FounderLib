package model
{

	[Bindable]
	public class PlayerVO
	{
		public function PlayerVO()
		{
		}

		private var _cash:Number=0;

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

		/**
		 * 现金
		 */
		public function get cash():Number
		{
			return _cash;
		}

		public function getProperty():int
		{
			var pv:int;

			if (goods)
			{
				for each (var vo:BoughtGoodsVO in goods)
				{
					pv+=vo.quantity * vo.inPrice;
				}
			}

			return pv + money;
		}

		/**
		 * @private
		 */
		public function set cash(value:Number):void
		{
//			if (value < 0 && value + loan > 0)
//			{
//				loan+=value;
//				value=0;
//			}
			_cash=value;
		}

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
			trace('Money:', cash + loan);
			return cash + loan;
		}

		public function set money(value:int):void
		{
			_money=value;
		}

		/**
		 * 获得所有需要支付的成本
		 */
		public function getAllNeedPay():int
		{
			var all:int;
			if (shop)
				all+=shop.rent;
			if (staffes)
			{
				var m:int;
				for each (var vo:StaffVO in staffes)
				{
					m+=vo.salary;
				}
				all+=m;
			}
			return all;
		}

		/**
		 * 付房租和工资
		 */
		public function payRentAndSalary():Array
		{
			var arr:Array=[];
			if (shop)
			{
				cash-=shop.rent;
				arr.push('扣除租金 ' + shop.rent);
			}
			var m:int;
			for each (var vo:StaffVO in staffes)
			{
				m+=vo.salary;
			}
			cash-=m;
			arr.push('扣除员工工资 ' + m);
			return arr;
		}
	}
}
