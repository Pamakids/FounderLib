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
		}
		
		private var cashier:Cashier;
		private var remover:Remover;
		public function creatWorkes():void
		{
			var main:MainScreen = MC.instance().mainScreen;
			var map:LogicalMap = LogicalMap.getInstance();
			
			//↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
			//test
			var vo:StaffVO = new StaffVO();
			vo.ability = 2;
			//↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
			
			//var vo:StaffVO = getStaffVO(2);
			cashier = new Cashier(vo);
			cashier.setCrtTile(map.getTileByPosition(new Point(7,6)));
			main.addUnit( cashier );
			
			//vo = getStaffVO(3);
			remover = new Remover(vo);
			remover.setCrtTile(map.getTileByPosition(new Point(28,6)));
			main.addUnit( remover );
			
			StatusManager.getInstance().addFunc( onTimer );
		}
		
		public function getFreeRomover():Remover
		{
			return (remover.isFree)?remover:null;
		}
		
		public function getCashier():Cashier
		{
			return cashier;
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
		
		public function clear():void
		{
			StatusManager.getInstance().delFunc( onTimer );
			cashier = null;
			remover = null;
		}
	}
}