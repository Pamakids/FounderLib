package view.unit
{
	import com.astar.expand.ItemTile;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import global.AssetsManager;
	import global.ShelfManager;
	import global.StoreManager;
	
	import model.ShelfVO;
	
	import view.component.LogicalMap;

	public class Shelf extends BasicUnit
	{
		/**
		 * 货架
		 */		
		public function Shelf(vo:ShelfVO)
		{
			this.vo = vo;
			super();
			init();
		}
		
		public var vo:ShelfVO;
		private var type:int;
		private function init():void
		{
			type = int(vo.icon);
			action = AssetsManager.instance().getResByName("shelf_"+vo.icon) as MovieClip;
			this.addChild( action );
			
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		
		protected function onClick(e:MouseEvent):void
		{
			trace("shelf");
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
			
			updatePropIcon(place);
		}
		
		
		public function delProp(propId:String, num:uint):void
		{
			var arr:Array;
			for(var i:int = props.length-1;i>=0;i--)
			{
				arr = props[i];
				if(arr[0] == propId)
				{
					if(arr[1] >= num)
					{
//						trace("货品充足");
						arr[1] -= num;
						updatePropIcon(i);
						break;
					}else
					{
						trace("货架物品不足！");
					}
				}
			}
			ShelfManager.getInstance().addToWait( this );
		}
		
		private function updatePropIcon(place:int):void
		{
			var num:int;
			var id:String;
			var icon:Sprite;
			
			var sprite:Sprite = action["sprite_"+place];
			sprite.removeChildren(1);
			sprite.mouseEnabled = sprite.mouseChildren = false;
			
			if(!props[place] || props[place][1] == 0)
				return;
			id = props[place][0];
			
			icon = AssetsManager.instance().getResByName("sprite_"+id) as Sprite;
			const w:Number = icon.width;
			const h:Number = icon.height;
			
			var d:Number = (sprite.width*3%w)/(Math.floor(sprite.width*3/w)-1);
			num = Math.floor( props[place][1]/vo.volume *(Math.floor(sprite.width*3/w)-1));
			if(!(num%2))	num+=1;
			for (var i:int = 0; i < num; i++) 
			{
				icon = AssetsManager.instance().getResByName("sprite_"+id) as Sprite;
				icon.x = w/3 + i*(w+d)/3;
				icon.y = -(i%2)*h/3;
				if(i%2==1)
					sprite.addChildAt(icon, sprite.numChildren-1);
				else
					sprite.addChild( icon );
			}
		}
		
		/**
		 * [
		 * 		[id, num],
		 * 		[id, num],
		 * 		[id, num]
		 * ]
		 */		
		public var props:Array = [];
		
		public function getPropNumByID(propID:String):uint
		{
			for each(var arr:Array in props)
			{
				if(arr[0] == propID)	return arr[1];
			}
			return 0;
		}
		
		/**
		 * 货物补充
		 */		
		public function resplenish():void
		{
			var id:String;
			for (var i:int = 0; i < props.length; i++) 
			{
				id = props[i][0];
				this.putInProp(i, id, StoreManager.getInstance().getPropNumByID(id));
			}
			
			ShelfManager.getInstance().delFromWait( this );
		}
		
		public function ifPropIn(propID:String):Boolean
		{
			for each(var arr:Array in props)
			{
				if(arr[0] == propID)
					return true;
			}
			return false;
		}
		
		public function getTargetTile():ItemTile
		{
			var points:Vector.<Point> = vo.target;
			var point:Point = points[ Math.floor( Math.random()*points.length ) ];
			return LogicalMap.getInstance().getTileByPosition( point );
		}
	}
}