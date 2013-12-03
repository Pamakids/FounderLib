package model
{
	import com.pamakids.models.BaseVO;

	[Bindable]
	public class GameConfigVO extends BaseVO
	{
		public function GameConfigVO()
		{
			required.push('loanRate', 'params', 'name', 'type', 'startupMoney', 'prepareTime', 'roundTime', 'minShopVisitors', 'minShopRent', 'visitorsAscendingRatio', 'rentAscendingRatio', 'goodsSaleMax');
		}

		override public function isValidate():Boolean
		{
			if (super.isValidate())
			{
				if (startupMoney < minShopRent + 30000)
					invalidMessage='启动资金低于一月租金+30000最低运营资金';
				else if (prepareTime < 60)
					invalidMessage='筹备时间不可低于60秒';
				else if (roundTime < 180)
					invalidMessage='月时间不可低于180秒';
				else if (minShopRent < 5000)
					invalidMessage='最低房租不可低于5000元';
				else if (minShopVisitors < 10)
					invalidMessage='最低人流吸引力不可低于10%';
				else if (minShopVisitors > 88)
					invalidMessage='最低人流吸引力不可高于88%';
				else if (visitorsAscendingRatio < 1)
					invalidMessage='最低人流吸引力增长率不可低于1%';
				else if ((1 + 3 * visitorsAscendingRatio / 100) * minShopVisitors > 100)
					invalidMessage='最低人流吸引力增长率不可高于' + Math.floor((100 / minShopVisitors - 1) * 100 / 3) + '%';
				else if (rentAscendingRatio < 1)
					invalidMessage='最低租金增长率不可低于1%';
				else if (goodsSaleMax < 100)
					invalidMessage='物品最高售价不可低于物品进货价';
				else if (loanRate > 50)
					invalidMessage='贷款利率不能超出50%';
				else if (validateParams(params))
					return true;
				return false;
			}
			return false;
		}

		private function validateParams(arr:Array):Boolean
		{
			var a:Array=arr;
			if (a)
			{
				if (a[0] < 100)
					invalidMessage='采购员最低采购物品数不得低于100';
				else if (a[1] < 1000 || a[4] < 1000 || a[8] < 1000)
					invalidMessage='最低薪资不得低于1000';
				else if (a[2] < 1 || a[5] < 1 || a[9] < 1)
					invalidMessage='增长率不得低于1%';
				else if (a[3] < 1)
					invalidMessage='收银员最快收银速度不可低于1秒';
				else if (a[6] < a[3] + 1)
					invalidMessage='顾客能忍受的最长排队时间不可低于收银员最快收银速度+1秒';
				else if (a[7] < 1)
					invalidMessage='理货员最快理货时间不可低于1秒';
				else if (a[10] < 1)
					invalidMessage='顾客能忍受的最长等货时间不可低于1秒';
				else
					return true;
				return false;
			}
			return true;
		}

		public function getShopperInTime():Number
		{
			return parseFloat(params[3]);
		}

		/**
		 * 最长排队时间
		 */
		public function getMaxQueueTime():Number
		{
			return parseFloat(params[6]);
		}

		/**
		 * 最长等货时间
		 */
		public function getMaxWaitGoodsTime():Number
		{
			return parseFloat(params[10]);
		}


		/**
		 * 物品售价最大倍数
		 */
		public var goodsSaleMax:int;
		/**
		 * 贷款利率
		 */
		public var loanRate:Number;
		public var name:String;
		public var isDefault:Boolean;
		public var type:int;
		public var params:Array;
		/**
		 * 启动资金
		 */
		public var startupMoney:Number;
		/**
		 * 筹备限时
		 */
		public var prepareTime:Number;
		/**
		 * 月时长
		 */
		public var roundTime:Number;
		/**
		 * 最低店铺人流
		 */
		public var minShopVisitors:Number;
		/**
		 * 最低店铺租金
		 */
		public var minShopRent:Number;
		/**
		 * 人流增长率
		 */
		public var visitorsAscendingRatio:Number;
		/**
		 * 租金增长率
		 */
		public var rentAscendingRatio:Number;
	}
}
