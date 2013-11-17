package global
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import view.component.LogicalMap;
	import view.unit.Cashier;
	import view.unit.Remover;

	/**
	 * 员工管理类
	 * @author Administrator
	 * 
	 */	
	public class WorkerManager
	{
		public function WorkerManager()
		{
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
		
		private static var _instance:WorkerManager;
		public static function getInstance():WorkerManager
		{
			if(!_instance)
				_instance = new WorkerManager();
			return _instance;
		}
	}
}