package model
{

	/**
	 * 员工VO
	 * @author mani
	 */
	public class StaffVO
	{
		public function StaffVO()
		{
		}

		/**
		 * 头像
		 */
		public var portrait:String;

		/**
		 * 星级
		 */
		public var level:int;

		/**
		 * 名称
		 */
		public var name:String;

		/**
		 * 工资
		 */
		public var salary:Number;

		/**
		 * 能力
		 */
		public var ability:Number;

		/**
		 * 1 采购员
		 * 2 收银员
		 * 3 理货员
		 */
		public var type:int;
	}
}
