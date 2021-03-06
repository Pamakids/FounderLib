package global
{
	import com.pamakids.manager.SoundManager;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.media.Sound;
	
	import model.ShopperVO;
	
	import view.component.LogicalMap;
	import view.screen.MainScreen;
	import view.unit.Shopper;

	/**
	 * 顾客管理类
	 * @author Administrator
	 */
	public class ShopperManager extends EventDispatcher
	{
		private static var _instance:ShopperManager;

		public static function getInstance():ShopperManager
		{
			if (!_instance)
				_instance=new ShopperManager();
			return _instance;
		}

		public function ShopperManager()
		{
		}
		private var openDoor:Sound;

		private var main:MainScreen;
		private var map:LogicalMap;

		public function initialize():void
		{
			this.map=LogicalMap.getInstance();
			this.main=MC.instance().mainScreen;
			this.openDoor = AssetsManager.instance().getSounds("sound_openDoor");
		}

		private var vecShopper:Vector.<Shopper>=new Vector.<Shopper>();
		private var waitForPay:Vector.<Shopper>=new Vector.<Shopper>();

		public function creatShopper(vo:ShopperVO):void
		{
			var shopper:Shopper=new Shopper(vo);
			shopper.setCrtTile(map.getTileByPosition(LogicalMap.POSITION_INTO_SHOP));
			main.addUnit(shopper);
			vecShopper.push(shopper);

			shopper.addEventListener(Shopper.SHOP_FINISHED, shopListener);
			shopper.addEventListener(Shopper.SHOP_FAILED, shopListener);
			shopper.addEventListener(Shopper.SHOP_CATCHED, shopListener);

			SoundManager.instance.play(openDoor);
			
			shopper.shopping();
		}

		protected function shopListener(e:Event):void
		{
			var shopper:Shopper=e.target as Shopper;
			switch (e.type)
			{
				case Shopper.SHOP_FINISHED: //采购成功
					trace("购物完成，前往前台等待结账");
					map.moveBody(shopper, map.TITLE_QUEUE);
					break;
				case Shopper.SHOP_CATCHED:
					trace("取得物品");
					shopper.shopping();
					break;
				case Shopper.SHOP_FAILED: //采购失败
					trace("购物失败");
					shopper.shopFailed();
					break;
			}
		}

		public function insertQueue(shopper:Shopper):void
		{
			var count:uint=waitForPay.length;
			waitForPay.push(shopper);
			map.moveBody(shopper, map.getTileByPosition(new Point(LogicalMap.POSITION_PAY.x, LogicalMap.POSITION_PAY.y + count)));
		}

		public function outShop(shopper:Shopper):void
		{
			waitForPay.splice(waitForPay.indexOf(shopper), 1);
			map.moveBody(shopper, map.getTileByPosition(LogicalMap.POSITION_OUT_SHOP));
			//后续队伍前移
			var point:Point;
			var target:Point;
			for (var i:int=waitForPay.length - 1; i >= 0; i--)
			{
				shopper=waitForPay[i];
				point=new Point(LogicalMap.POSITION_PAY.x, LogicalMap.POSITION_PAY.y + i);
				map.moveBody(shopper, map.getTileByPosition(point));
			}
		}

		public function delShopper(shopper:Shopper):void
		{
			vecShopper.splice(vecShopper.indexOf(shopper), 1);
			shopper.removeEventListener(Shopper.SHOP_FINISHED, shopListener);
			shopper.removeEventListener(Shopper.SHOP_FAILED, shopListener);
			shopper.removeEventListener(Shopper.SHOP_CATCHED, shopListener);
			main.delUnit(shopper);
		}

		//获取当前需要的等待时间
		public function getTotalWaitTime():uint
		{
			var time:uint=waitForPay.length * WorkerManager.getInstance().getWaitTime();
			return time;
		}

		public function getShopperNum():int
		{
			return this.vecShopper.length;
		}

		public function clear():void
		{
			vecShopper.splice(0, vecShopper.length);
			waitForPay.splice(0, waitForPay.length);
			this.main=null;
			this.map=null;
		}
	}
}