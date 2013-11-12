package model
{
	import com.pamakids.models.BaseVO;

	public class TopicVO extends BaseVO
	{
		public function TopicVO()
		{
			super();
		}

		public var title:String;
		public var answers:Array;
		public var enabled:Boolean;
	}
}
