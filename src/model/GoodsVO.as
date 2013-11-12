package model
{
	import com.pamakids.models.BaseVO;

	public class GoodsVO extends BaseVO
	{
		public function GoodsVO()
		{
			required.push('name', 'inPrice', 'outPrice');
		}

		public var name:String;
		public var inPrice:Number;
		public var outPrice:Number;
	}
}
