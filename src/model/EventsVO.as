package model
{
	import com.pamakids.models.BaseVO;

	/**
	 * 随机事件VO
	 * @author mani
	 */
	public class EventsVO extends BaseVO
	{
		public function EventsVO()
		{
			super();
		}

		public var content:String;
		public var money:int;
		public var enabled:Boolean;
	}
}
