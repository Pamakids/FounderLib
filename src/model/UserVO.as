package model
{
	import com.pamakids.models.BaseVO;

	public class UserVO extends BaseVO
	{

		public static const NORMAL:String="normal";
		public static const PARTNER:String="partner";

		public function UserVO()
		{
			super();
		}

		public var username:String;
		public var lose_times:int;
		public var win_times:int;
		public var company_name:String;
		public var single_level:int;
		public var single_cash:int;
		public var single_loan:int;
		public var password:String='123456';
		public var portrait:String;
		public var signed_in_times:int;
		public var boughtGoods:String;

		public var birthday:String;
		public var come_from:String;
		public var email:String;
		public var enabled:String;
		public var gender:String
		public var id_card_num:String;
		public var id_card_pic_back:String;
		public var id_card_pic_front:String;
		public var last_check_in_time:String;
		public var last_login_time:String;
		public var member_id:String;
		public var mobile_phone_num:String;
		public var note:String;
		public var provider:String;
		public var total_check_in:int;
		public var true_name:String;
		public var type:String;
		public var verified:String;
	}
}
