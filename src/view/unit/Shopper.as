package view.unit
{
	import com.astar.expand.ItemTile;
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import global.AssetsManager;
	import global.ShelfManager;
	import global.ShopperManager;
	import global.StatusManager;
	import global.StoreManager;
	import global.WorkerManager;
	
	import model.ShopperVO;
	
	import view.component.LogicalMap;
	import view.unit.w.Walker;

	/**
	 * 顾客
	 * @author Administrator
	 */
	public class Shopper extends Walker
	{
		/**
		 * 每采购到一种物品即派发
		 */
		public static const SHOP_CATCHED:String="shop_catched";
		/**
		 * 采购到清单中的所有物品即派发
		 */
		public static const SHOP_FINISHED:String="shop_finished";
		/**
		 * 采购失败派发
		 */
		public static const SHOP_FAILED:String="shop_failed";

		private var vo:ShopperVO;

		public function Shopper(vo:ShopperVO)
		{
			this.vo=vo;
			super();
			init();
		}

		private function init():void
		{
			initAction();
			initIcon();
			this.mouseChildren=this.mouseEnabled=false;
		}

		private var isFinish:Boolean=false;

		public function shopping():void
		{
			var arr:Array;
			for (var i:int=0; i < vo.shopperList.length; i++)
			{
				arr=vo.shopperList[i];
				if (arr[3])
					continue;
				crtIndex=i;
				targetShelf=ShelfManager.getInstance().getShelfByPropID(arr[0]);
				if (!targetShelf)
				{
					dispatchEvent(new Event(SHOP_FAILED));
					return;
				}
				var tile:ItemTile=targetShelf.getTargetTile();
				(tile == crtTile) ? shopHandler() : LogicalMap.getInstance().moveBody(this, tile);
				return;
			}
			isFinish=true;
			dispatchEvent(new Event(Shopper.SHOP_FINISHED));
		}
		/**
		 *	[id, num, crtPrice, catched]
		 */
		private var crtIndex:int;
		private var targetShelf:Shelf;

		override protected function onArrived(e:Event):void
		{
			if (isFinish)
			{
				switch (crtTile)
				{
					case LogicalMap.getInstance().TITLE_PAY:
						WorkerManager.getInstance().getCashier().serviceFor(this);
						action.gotoAndStop(ACTION_STAY_UP);
						break;
					case LogicalMap.getInstance().TITLE_OUT_SHOP:
						ShopperManager.getInstance().delShopper(this);
						break;
					case LogicalMap.getInstance().TITLE_QUEUE:
						var time:uint=ShopperManager.getInstance().getTotalWaitTime();
						if (time > vo.maxQueueTime)
							dispatchEvent(new Event(SHOP_FAILED));
						else
							ShopperManager.getInstance().insertQueue(this);
						break;
					default:
						action.gotoAndStop(ACTION_STAY_UP);
						break;
				}
				return;
			}
			if (isFailed)
			{
				ShopperManager.getInstance().delShopper(this);
				return;
			}
			shopHandler();
		}

		private function shopHandler():void
		{
			this.action.gotoAndStop(ACTION_STAY_UP);

			var arr:Array=vo.shopperList[crtIndex];
			var id:String=arr[0];
			var num:uint=arr[1];
			var countShelf:uint=targetShelf.getPropNumByID(id);
			if (countShelf >= num)
			{
				targetShelf.delProp(id, num);
				arr[3]=true;
				updateIcon();
				TweenLite.delayedCall(0.5, function():void
				{
					dispatchEvent(new Event(SHOP_CATCHED));
				});
			}
			else
			{
				var countStore:uint=StoreManager.getInstance().getPropNumByID(id);
				if (countShelf + countStore >= num)
					waitForReplenish();
				else
					dispatchEvent(new Event(SHOP_FAILED));
			}
		}


		private function waitForReplenish():void
		{
			start=getTimer();
			StatusManager.getInstance().addFunc(onTimer, 0.5);
		}

		private function onTimer():void
		{
			var crtTime:uint=getTimer();
			if (crtTime - start >= vo.maxWaitGoodsTime * 1000)
			{
				dispatchEvent(new Event(SHOP_FAILED));
				StatusManager.getInstance().delFunc(onTimer);
				return;
			}
			var id:String=vo.shopperList[crtIndex][0];
			var num:uint=vo.shopperList[crtIndex][1];
			if (targetShelf.getPropNumByID(id) >= num)
			{
				StatusManager.getInstance().delFunc(onTimer);
				targetShelf.delProp(id, num);
				vo.shopperList[crtIndex][3]=true;
				updateIcon();
				dispatchEvent(new Event(SHOP_CATCHED));
			}
		}
		private var start:uint;

		private var vecIcon:Vector.<Sprite>;

		private function updateIcon():void
		{
			var arr:Array;
			var icon:Sprite;
			var icons:Array=[];
			var num:uint=vo.shopperList.length;
			for (var i:int=vo.shopperList.length - 1; i >= 0; i--)
			{
				arr=vo.shopperList[i];
				icon=vecIcon[i];
				if (arr[3])
				{
					if (icon)
					{
						this.removeChild(icon);
						vecIcon[i]=null;
					}
				}
				else
				{
					icons.push(icon);
				}
			}
			//重新排列位置
			var kinds:uint=icons.length;
			for (i=0; i < kinds; i++)
			{
				icon=icons[i];
				icon.x=-(kinds - 1) * gap / 2 + i * gap;
			}
		}

		private function initAction():void
		{
			action=AssetsManager.instance().getResByName("shopper_" + vo.type) as MovieClip;
			action.gotoAndStop(ACTION_STAY_RIGHT);
			this.addChild(action);
			if (vo.type == 0)
				action.scaleX=action.scaleY=.4;
			else if (vo.type == 1 || vo.type == 2)
				action.scaleX=action.scaleY=.8;
		}
		private const gap:uint=40;

		private function initIcon():void
		{
			var icon:Sprite;
			var id:String;
			var num:uint;
			const kinds:uint=vo.shopperList.length;
			vecIcon=new Vector.<Sprite>(kinds);
			for (var i:int=kinds - 1; i >= 0; i--)
			{
				id=vo.shopperList[i][0];
				num=vo.shopperList[i][1];
				icon=AssetsManager.instance().getResByName("sprite_" + id) as Sprite;
				this.addChild(icon);
				icon.x=-(kinds - 1) * gap / 2 + i * gap;
				icon.y=-action.height - 10;
				vecIcon[i]=icon;
			}
		}

		public function getShoppingList():Array
		{
			return vo.shopperList;
		}

		override public function dispose():void
		{
			StatusManager.getInstance().delFunc(onTimer);
			vo=null;
			this.removeChild(action);
			action=null;
			targetShelf=null;
			clearIcon();
			vecIcon=null;
			super.dispose();
		}

		private var isFailed:Boolean=false;

		public function shopFailed():void
		{
			isFailed=true;
			clearIcon();
			addFailedIcon();
			LogicalMap.getInstance().moveBody(this, LogicalMap.getInstance().TITLE_OUT_SHOP);
			//将已购买的物品扔回仓库
			for each(var arr:Array in vo.shopperList)
			{
				if(arr[3])
					StoreManager.getInstance().addPropByID(arr[0], arr[1]);
			}
		}

		private function addFailedIcon():void
		{
			var icon:MovieClip=AssetsManager.instance().getResByName("mc_angry") as MovieClip;
			icon.y=-action.height - 5;
			this.addChild(icon);
			icon.mouseEnabled=false;
		}

		private function clearIcon():void
		{
			var s:Sprite;
			for (var i:int=vecIcon.length - 1; i >= 0; i--)
			{
				s=vecIcon[i];
				if (s && s.parent)
					s.parent.removeChild(s);
				vecIcon.pop();
			}
		}
	}
}
