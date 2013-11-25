package global
{
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import model.ShopperVO;
	
	import view.component.LogicalMap;
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
			if(!_instance)
				_instance = new ShopperManager();
			return _instance;
		}
		
		public function ShopperManager()
		{
			init();
		}
		
		private function init():void
		{
			this.map = LogicalMap.getInstance();
		}
		
		private var timer:Timer;
		
		private var time:uint;
		private const Interval:uint = 1000;
		
		private var vecShopper:Vector.<Shopper> = new Vector.<Shopper>();
		private var waitForPay:Vector.<Shopper> = new Vector.<Shopper>();
		
		public function creatShopper():void
		{
			var arr:Array = [
//				[[101, 5], [102, 5]], 
//				[[201, 5], [301, 5]], 
				[[302, 5]]
			];
			
			var vo:ShopperVO = new ShopperVO(0, arr[int(Math.random()*arr.length)]);
			var shopper:Shopper = new Shopper(vo);
			shopper.setCrtTile( map.getTileByPosition( LogicalMap.POSITION_INTO_SHOP ) );
			container.addChild( shopper );
			vecShopper.push( shopper );
			
			shopper.addEventListener(Shopper.SHOP_FINISHED, shopListener);
			shopper.addEventListener(Shopper.SHOP_FAILED, shopListener);
			shopper.addEventListener(Shopper.SHOP_CATCHED, shopListener);
			
			shopper.shopping();
		}
		
		protected function shopListener(e:Event):void
		{
			var shopper:Shopper = e.target as Shopper;
			switch(e.type)
			{
				case Shopper.SHOP_FINISHED:			//采购成功
					trace("购物完成，前往前台等待结账");
					insertQueue(shopper);
					break;
				case Shopper.SHOP_CATCHED:
					trace("取得物品");
					shopper.shopping();
					break;
				case Shopper.SHOP_FAILED:			//采购失败
					trace("购物失败");
					break;
			}
		}
		
		private var container:Sprite;
		private var map:LogicalMap;
		public function setContainer(container:Sprite):void
		{
			this.container = container;
		}
		
		public function insertQueue(shopper:Shopper):void
		{
			var count:uint = waitForPay.length;
			waitForPay.push( shopper );
			map.moveBody(shopper, map.getTileByPosition(new Point(LogicalMap.POSITION_PAY.x+count*2, LogicalMap.POSITION_PAY.y)));
		}
		
		public function outShop(shopper:Shopper):void
		{
			waitForPay.splice( waitForPay.indexOf( shopper ), 1);
			map.moveBody(shopper, map.getTileByPosition(LogicalMap.POSITION_OUT_SHOP));
			
			var point:Point;
			var target:Point;
			for(var i:int = waitForPay.length-1;i>=0;i--)
			{
				shopper = waitForPay[i];
				if(i == 0)
					map.moveBody(shopper, map.getTileByPosition(LogicalMap.POSITION_PAY));
				else
					map.moveBody(shopper, waitForPay[i-1].getCrtTile());
			}
		}
		
		public function delShopper(shopper:Shopper):void
		{
			vecShopper.splice( vecShopper.indexOf( shopper ), 1 );
			shopper.removeEventListener(Shopper.SHOP_FINISHED, shopListener);
			shopper.removeEventListener(Shopper.SHOP_FAILED, shopListener);
			shopper.removeEventListener(Shopper.SHOP_CATCHED, shopListener);
			container.removeChild( shopper );
			shopper.dispose();
		}
	}
}