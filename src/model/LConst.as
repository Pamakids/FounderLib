package model
{
	import com.pamakids.services.ServiceBase;
	import com.pamakids.utils.URLUtil;

	public class LConst
	{
		public function LConst()
		{
		}

		public static const ID_PIC_W:Number=500;
		public static const ID_PIC_H:Number=309;

		public static function getPic(url:String, w:Number=0, h:Number=0):String
		{
			var type:String=URLUtil.getExtenion(url);
			var us:String=url;
			if (w || h)
				us=url.replace(type, w + 'x' + h + type);
			return ServiceBase.HOST + us;
		}

		public static const GOODS_CATEGORIES:String="GOODS_CATEGORIES";
		public static const USER_INFO:String="USER_INFO";
		public static const ACCOUNT_TYPES:String="ACCOUNT_TYPES";
		public static const DEPOSIT:String="DEPOSIT";

		public static const KEYS:Array=[{tip: '单机关卡数', value: GOODS_CATEGORIES}];

		public static function getLabel(arr:Array, value:String):String
		{
			var s:String;
			if (value)
			{
				for each (var o:Object in arr)
				{
					if (o.value == value)
					{
						s=o.label;
						break;
					}
				}
			}
			return s;
		}

	}
}
