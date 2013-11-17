package model
{
	import flash.geom.Point;

	/**
	 * 货架数据
	 * @author Administrator
	 */	
	public class ShelfVO
	{
		public function ShelfVO(id:String)
		{
			this.id = id;
		}
		
		public var id:String;
		/**
		 * 所在位置行列
		 */		
		public var position:Point;
		/**
		 * 响应目标行列集合
		 */		
		public var target:Vector.<Point>;
		/**
		 * 资源索引
		 */		
		public var icon:String;
		/**
		 * 搁板数量
		 */		
		public var count:uint;
		/**
		 * 单个搁板容量
		 */		
		public var volume:uint;
		
		public function parseByXmlContent(str:String):void
		{
			//搁板数量（可放种类数量）|单搁板容量|资源索引|货架位置数据|响应位置集合
			//1|30|2|2,11|3,12●4,12●5,12
			var arr:Array = str.split("|");
			this.count = arr[0];
			this.volume = arr[1];
			this.icon = arr[2];
			
			var arr_1:Array = arr[3].split(",");
			this.position = new Point(arr_1[0], arr_1[1]);
			
			this.target = new Vector.<Point>();
			arr_1 = arr[4].split("●");
			var arr_2:Array;
			var point:Point;
			for each(var s:String in arr_1)
			{
				arr_2 = s.split(",");
				point = new Point(arr_2[0], arr_2[1]);
				this.target.push( point );
			}
		}
		
	}
}