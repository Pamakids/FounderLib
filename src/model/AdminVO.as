package model
{
	import com.pamakids.models.BaseVO;

	public class AdminVO extends BaseVO
	{
		public function AdminVO()
		{
		}

		override public function getIgnoreFields():Array
		{
			return ['create_at', 'updated_at'];
		}

		/**
		 * 管理员
		 */
		public static const ADMIN:String="admin";

		public var worker_id:String;
		public var mobile_phone_num:String;
		public var enabled:Boolean;
		public var privilege:String;
		public var email:String;
		public var birthday:String;
		public var portrait:String;
		public var id_card_num:String;
		public var id_card_pic_front:String;
		public var id_card_pic_back:String;
		public var true_name:String;
		public var enty_date:String;
		public var monthly_salary:String;
		public var departure_date:String;
		public var password:String;
		public var native_place:String;
	}
}
