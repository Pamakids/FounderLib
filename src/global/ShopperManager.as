package global
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
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
			timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		protected function onTimer(e:TimerEvent):void
		{
			if(Math.random()*100 < 25)
				creatShopper();
		}
		private var timer:Timer;
		
		private var time:uint;
		private const Interval:uint = 1000;
		
		private const creatPosition:Point = new Point(3, 8);
		/** 等待队列起始位置 */		
		private const queuePosition:Point = new Point(8, 7);
		private var vecShopper:Vector.<Shopper>;
		private var waitForPay:Vector.<Shopper>;
		
		public function creatShopper():void
		{
			var vo:ShopperVO = new ShopperVO(0, [[101, 5], [102, 5], [103, 5]]);
			var shopper:Shopper = new Shopper(vo);
			shopper.setCrtTile( map.getTileByPosition( creatPosition ) );
			container.addChild( shopper );
		}
		
		private var container:Sprite;
		private var map:LogicalMap;
		public function setContainer(container:Sprite):void
		{
			this.container = container;
		}
	}
}