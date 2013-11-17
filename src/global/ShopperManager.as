package global
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
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
			this.addEventListener("creatShopper", creatShopper);
		}
		private var time:uint;
		private const Interval:uint = 1000;
		
		private function creatShopper(e:Event):void
		{
			var vo:ShopperVO = new ShopperVO(0, [[101, 5], [102, 5]]);
			var shopper:Shopper = new Shopper(vo);
			shopper.setCrtTile( map.getTileByPosition(new Point(3,4)) );
			container.addChild( shopper );
		}
		
		private var container:Sprite;
		private var map:LogicalMap;
		public function setContainer(container:Sprite):void
		{
			this.container = container;
			this.map = LogicalMap.getInstance();
		}
	}
}