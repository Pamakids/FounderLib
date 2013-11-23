package view.unit
{
	import com.astar.expand.ItemTile;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import global.AssetsManager;
	import global.ShelfManager;
	import global.ShopperManager;
	import global.WorkerManager;
	
	import model.ShopperVO;
	
	import view.component.LogicalMap;

	/**
	 * 顾客
	 * @author Administrator
	 */	
	public class Shopper extends Walker
	{
		/**
		 * 每采购到一种物品即派发
		 */		
		public static const SHOP_CATCHED:String = "shop_catched";
		/**
		 * 采购到清单中的所有物品即派发
		 */		
		public static const SHOP_FINISHED:String = "shop_finished";
		/**
		 * 采购失败派发
		 */		
		public static const SHOP_FAILED:String = "shop_failed";
		
		private var vo:ShopperVO;
		public function Shopper(vo:ShopperVO)
		{
			this.vo = vo;
			super();
		}
		
		override protected function init():void
		{
			initAction();
			updateIcon();
			this.mouseChildren = this.mouseEnabled = false;
		}
		
		private var isFinish:Boolean = false;
		public function shopping():void
		{
			var arr:Array;
			for(var i:int = 0;i<vo.shopperList.length;i++)
			{
				arr = vo.shopperList[i];
				if(arr[3])	continue;
				crtIndex = i;
				targetShelf = ShelfManager.getInstance().getShelfByPropID( arr[0] );
				var points:Vector.<Point> = targetShelf.vo.target;
				var point:Point = points[ Math.floor( Math.random()*points.length ) ];
				var tile:ItemTile = LogicalMap.getInstance().getTileByPosition( point );
				(tile == crtTile) ? shopHandler() : LogicalMap.getInstance().moveBody(this, tile);
				return;
			}
			isFinish = true;
			this.title.visible = false;
			dispatchEvent(new Event(Shopper.SHOP_FINISHED));
		}
		/**
		 *	[id, num, crtPrice, catched] 
		 */		
		private var crtIndex:int;
		private var targetShelf:Shelf;
		
		override protected function onArrived(e:Event):void
		{
			if(isFinish)
			{
				switch(crtTile)
				{
					case LogicalMap.getInstance().TITLE_PAY:
						WorkerManager.getInstance().getCashier().serviceFor( this );
						action.gotoAndStop(ACTION_STAY_UP);
						break;
					case LogicalMap.getInstance().TITLE_OUT_SHOP:
						ShopperManager.getInstance().delShopper( this );
						break;
					default:
						action.gotoAndStop(ACTION_STAY_LEFT);
						break;
				}
				return;
			}
			shopHandler();
		}
		
		private function shopHandler():void
		{
			var arr:Array = vo.shopperList[crtIndex];
			var id:String = arr[0];
			var num:uint = arr[1];
			if(targetShelf.getPropNumByID(id) >= num)
			{
				targetShelf.delProp( id, num ); 
				arr[3] = true;
				updateIcon();
				dispatchEvent(new Event(SHOP_CATCHED));
			}
			else
			{
				waitForReplenish();
			}
		}
		
		
		private var timer:Timer;
		private function waitForReplenish():void
		{
			if(!timer)
			{
				timer = new Timer(1000, 5);
				timer.addEventListener(TimerEvent.TIMER, timerListener);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerListener);
			}
			timer.start();
		}
		
		protected function timerListener(e:TimerEvent):void
		{
			var id:String = vo.shopperList[crtIndex][0];
			var num:uint = vo.shopperList[crtIndex][1];
			switch(e.type)
			{
				case TimerEvent.TIMER_COMPLETE:
					if(targetShelf.getPropNumByID(id) < num)
					{
						dispatchEvent(new Event(SHOP_FAILED));
						return;
					}
				case TimerEvent.TIMER:
					if(targetShelf.getPropNumByID(id) >= num)
					{
						targetShelf.delProp( id, num );
						vo.shopperList[crtIndex][3] = true;
						dispatchEvent(new Event(SHOP_CATCHED));
						timer.reset();
					}
					break;
			}
		}
		
		private var vecIcon:Vector.<Sprite> = new Vector.<Sprite>();
		private function updateIcon():void
		{
			const gap:uint = 10;
			const w:uint = 20;
			const padding:uint = 5;
			var num:uint = vo.shopperList.length;
			//清除旧图标
			title.removeChildren(1);
			vecIcon.splice(0, vecIcon.length);
			
			var arr:Array;
			var icon:Sprite;
			for(var i:int = 0;i<num;i++)
			{
				arr = vo.shopperList[i];
				if(arr[3])		continue;
				icon = AssetsManager.instance().getResByName("sprite_"+arr[0]) as Sprite;
				title.addChild( icon );
				icon.x = padding + i*(w+gap) - title.width/2;
				icon.y = -30;
				vecIcon.push( icon );
			}
			
			num = vecIcon.length;
			title.bg.width = (num-1)*gap + w*num + padding*2;
		}
		
		private var title:MovieClip;
		private function initAction():void
		{
			action = AssetsManager.instance().getResByName("shopper_"+vo.type) as MovieClip;
			action.gotoAndStop(ACTION_STAY_RIGHT);
			this.addChild( action );
			
			title = AssetsManager.instance().getResByName("title") as MovieClip;
			title.y = -action.height;
			this.addChild( title );
		}
		
		public function getShoppingList():Array
		{
			return vo.shopperList;
		}
		
		override public function dispose():void
		{
		}
	}
}