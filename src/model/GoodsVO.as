package model
{
	import com.pamakids.models.BaseVO;

	public class GoodsVO extends BaseVO
	{
		public function GoodsVO()
		{
			required.push('name', 'inPrice', 'outPrice');
		}

		public var id:String;
		public var name:String;
		public var inPrice:Number;
		public var outPrice:Number;

		public function validate(saleMax:int):Boolean
		{
			if (isValidate())
			{
				if (inPrice * (saleMax / 100) < outPrice)
					invalidMessage='售价不可高于进货价 ' + saleMax + '%';
				else
					return true;
				return false;
			}
			return false;
		}
	}
}
