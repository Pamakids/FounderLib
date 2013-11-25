package global
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import view.component.LogicalMap;
	import view.unit.Cashier;
	import view.unit.Remover;
	import view.unit.Shelf;

	/**
	 * 员工管理类
	 * @author Administrator
	 * 
	 */	
	public class WorkerManager
	{
		public function WorkerManager()
		{
			initTimer();
		}
		
		private var timer:Timer;
		private function initTimer():void
		{
			timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		private var container:Sprite;
		private var map:LogicalMap;
		
		private var cashier:Cashier;
		private var remover:Remover;
		public function creatWorker(container:Sprite):void
		{
			this.container = container;
			this.map = LogicalMap.getInstance();
			
			cashier = new Cashier();
			cashier.setCrtTile(map.getTileByPosition(new Point(7,6)));
			container.addChildAt(cashier, 0);
			
			remover = new Remover();
			remover.setCrtTile(map.getTileByPosition(new Point(28,6)));
			container.addChild( remover );
			
		}
		
		public function getFreeRomover():Remover
		{
			return (remover.isFree)?remover:null;
		}
		
		private static var _instance:WorkerManager;
		public static function getInstance():WorkerManager
		{
			if(!_instance)
				_instance = new WorkerManager();
			return _instance;
		}
		
		public function getCashier():Cashier
		{
			return cashier;
		}
		
		public function replenish(shelf:Shelf):void
		{
			remover.replenish( shelf );
		}
		
		public function onTimer(e:TimerEvent):void
		{
			if(remover.isFree)
			{
				var shelf:Shelf = ShelfManager.getInstance().getWaitShelf();
				if(shelf)
					remover.replenish( shelf );
			}
		}
	}
}