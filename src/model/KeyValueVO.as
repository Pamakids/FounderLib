package model
{
	import com.pamakids.models.BaseVO;

	[Bindable]
	public class KeyValueVO extends BaseVO
	{
		public function KeyValueVO()
		{
			super();
		}

		public var key:String;
		public var value:String;
		public var tip:String;
	}
}
