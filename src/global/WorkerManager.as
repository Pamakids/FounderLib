package global
{
	import flash.geom.Point;
	
	import controller.ServiceController;
	
	import model.StaffVO;
	
	import view.component.LogicalMap;
	import view.screen.MainScreen;
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
		private static var _instance:WorkerManager;
		public static function getInstance():WorkerManager
		{
			if(!_instance)
				_instance = new WorkerManager();
			return _instance;
		}
		
		public function WorkerManager()
		{
			init();
		}
		
		private function init():void
		{
			StatusManager.instance().addFunc( onTimer );
		}
		
		private var map:LogicalMap;
		
		private var cashier:Cashier;
		private var remover:Remover;
		private var main:MainScreen;
		public function setMainStage(main:MainScreen):void
		{
			this.main = main;
			this.map = LogicalMap.getInstance();
			
			//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
			//test
			var vo:StaffVO = new StaffVO();
			vo.ability = 2;
			//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
			
			//var vo:StaffVO = getStaffVO(2);
			cashier = new Cashier(vo);
			cashier.setCrtTile(map.getTileByPosition(new Point(7,6)));
			this.main.addUnit( cashier );
			
			//vo = getStaffVO(3);
			remover = new Remover(vo);
			remover.setCrtTile(map.getTileByPosition(new Point(28,6)));
			this.main.addUnit( remover );
		}
		
		public function getFreeRomover():Remover
		{
			return (remover.isFree)?remover:null;
		}
		
		public function getCashier():Cashier
		{
			return cashier;
		}
		
		public function replenish(shelf:Shelf):void
		{
			remover.replenish( shelf );
		}
		
		private function onTimer():void
		{
			if(remover.isFree)
			{
				var shelf:Shelf = ShelfManager.getInstance().getWaitShelf();
				if(shelf)
					remover.replenish( shelf );
			}
		}
		
		public function getWaitTime():uint
		{
			return cashier.getAbility();
		}
		
		/**
		 * 1 采购员 2 收银员 3 理货员
		 */		
		private function getStaffVO(i:int):StaffVO
		{
			for each(var vo:StaffVO in ServiceController.instance.player1.staffes)
			{
				if(vo.type == i)
					return vo;
			}
			return null;
		}
	}
}