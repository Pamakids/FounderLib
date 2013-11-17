package view.unit
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	import global.AssetsManager;
	import global.StoreManager;
	
	import model.ShelfVO;

	public class Shelf extends BasicUnit
	{
		/**
		 * 货架
		 */		
		public function Shelf(vo:ShelfVO)
		{
			this.vo = vo;
			super();
		}
		
		private var vo:ShelfVO;
		private var type:int;
		override protected function init():void
		{
			type = int(vo.icon);
			action = AssetsManager.instance().getResByName("shelf_"+vo.icon) as MovieClip;
			this.addChild( action );
			
			creatBtns();
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private var btns:Vector.<SimpleButton>;
		private function creatBtns():void
		{
			var btn:SimpleButton;
			btns = new Vector.<SimpleButton>();
			for(var i:int = 0;i<vo.count;i++)
			{
				var mc:MovieClip = action["sprite_"+i];
				btn = AssetsManager.instance().getResByName("button_add") as SimpleButton;
				action.addChild( btn );
				btn.x = mc.x + (mc.width - btn.width >> 1);
				btn.y = mc.y;
				btn.addEventListener(MouseEvent.CLICK, onClick);
				btns.push( btn );
			}
		}
		
		protected function onClick(e:MouseEvent):void
		{
			if(e.target is SimpleButton)		//摆放物品
			{
				e.stopImmediatePropagation();
				var btn:SimpleButton = e.currentTarget as SimpleButton;
				var i:int = btns.indexOf( btn );
				trace(i);
				
			}
			else		//货架商品补全
			{
				trace("shelf");
			}
		}
		
		/**
		 * 摆放物品
		 * @param place		货架层次，从上至下依次为0,1,2
		 * @param propId	物品id
		 * @param num		物品数量
		 */		
		public function putInProp(place:int, propId:String, num:uint):void
		{
			var arr:Array;
			if(!props)
				props = [];
			arr = props[place];
			if(!arr)		//货架为空
			{
				props[place] = [propId, (vo.volume>num)?num:vo.volume];
				StoreManager.getInstance().delPropByID(propId, props[place][1]);
			}
			else
			{
				if(arr[0] != propId)		//更换货物种类
				{
					//将货架原有物品退回仓库
					StoreManager.getInstance().addPropByID(arr[0], arr[1]);
					props[place] = [propId, (vo.volume>num)?num:vo.volume];
					StoreManager.getInstance().delPropByID(propId, props[place][1]);
				}
				else		//货物补全
				{
					var n:uint = arr[1];
					arr[1] = (vo.volume>n+num)?n+num:vo.volume;
					StoreManager.getInstance().delPropByID( propId, arr[1]-n); 
				}
				
			}
		}
		public var props:Array;
		
		private function gettPropNumByID(propID:String):uint
		{
			var num:uint = 0;
			if(!props)
				return num;
			for(var arr:Array in props)
			{
				if(arr[0] == propID)	return arr[1];
			}
			return num;
		}
	}
}