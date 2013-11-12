package model
{
	import com.pamakids.models.BaseVO;

	public class GameConfigVO extends BaseVO
	{
		public function GameConfigVO()
		{
			required.push('name', 'type', 'startupMoney', 'prepareTime', 'roundTime', 'minShopVisitors', 'minShopRent', 'visitorsAscendingRatio', 'rentAscendingRatio');
		}

		override public function isValidate():Boolean
		{
			if (super.isValidate())
			{
				if (startupMoney < minShopRent * 5 + 30000)
					invalidMessage='启动资金低于3月租金+2月押金+30000最低运营资金';
				else if (prepareTime < 60)
					invalidMessage='筹备时间不可低于60秒';
				else if (roundTime < 180)
					invalidMessage='回合时间不可低于180秒';
				else if (minShopRent < 5000)
					invalidMessage='最低房租不可低于5000元';
				else if (visitorsAscendingRatio < 1)
					invalidMessage='最低人流增长率不可低于1%';
				else if (rentAscendingRatio < 1)
					invalidMessage='最低租金增长率不可低于1%';
				else
					return true;
				return false;
			}
			return false;
		}

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
		 * 回合时长
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
