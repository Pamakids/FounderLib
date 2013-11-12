package model
{
	import com.pamakids.models.BaseVO;

	public class AccountVO extends BaseVO
	{
		public function AccountVO()
		{
			super();
		}

//		log_num:{type:Number, index:{unique:true}, required:true}, //流水号 年月日时分秒三位随机数
//		type:{type:String, index:true, required:true}, //记账类型
//		remark:String,
//		cash:Number,
//		canceled:Boolean,   //撤销

		public var log_num:String;
		public var type:String;
		public var remark:String;
		public var cash:Number;
		public var canceled:Boolean;
	}
}
