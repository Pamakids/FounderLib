package global
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import model.ShelfVO;
	
	import view.component.LogicalMap;
	import view.unit.Remover;
	import view.unit.Shelf;

	/**
	 * 货架管理器
	 * @author Administrator
	 */	
	public class ShelfManager extends EventDispatcher
	{
		public function ShelfManager()
		{
			init();
		}
		
		private function init():void
		{
			parseXML();
			initTimer();
		}
		
		private var timer:Timer;
		private function initTimer():void
		{
			timer = new Timer(50);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		protected function onTimer(event:TimerEvent):void
		{
			if(vecWait.length > 0)
			{
				var remover:Remover = WorkerManager.getInstance().getFreeRomover();
				if(remover)
					remover.replenish(vecWait[0]);
			}
			else
			{
				timer.stop();
			}
		}
		
		private var datas:Vector.<ShelfVO>;
		private function parseXML():void
		{
			var obj:Array = DC.instance().shelfObj as Array;
			datas = new Vector.<ShelfVO>();
			for(var i:int = 0;i<obj.length;i++)
			{
				var vo:ShelfVO = new ShelfVO(i.toString());
				vo.parseByXmlContent(obj[i]);
				datas.push( vo );
			}
		}
		
		private var container:Sprite;
		private var map:LogicalMap;
		private var vecShelf:Array;
		public function creatShelf(container:Sprite):void
		{
			vecShelf = [];
			this.container = container;
			this.map = LogicalMap.getInstance();
			var shelf:Shelf;
			var vo:ShelfVO;
			for(var i:int = datas.length-1;i>=0;i--)
			{
				vo = datas[i];
				shelf = new Shelf(vo);
				shelf.setCrtTile( map.getTileByPosition( vo.position ) );
				vecShelf[i] = shelf;
			}
			
			vecShelf.sortOn("y");		//按y坐标大小排序
			for(i = 0;i<vecShelf.length;i++)
			{
				container.addChild( vecShelf[i] );
			}
			
			setGoods();
		}
		
		//将物品放入货架
		private function setGoods():void
		{
			var arr:Array = [
				{id: 101, num: 20},
				{id: 102, num: 500},
				{id: 103, num: 500},
				{id: 104, num: 500},
				{id: 105, num: 500},
				{id: 201, num: 500},
				{id: 202, num: 500},
				{id: 203, num: 500},
				{id: 204, num: 500},
				{id: 301, num: 500},
				{id: 302, num: 500},
				{id: 303, num: 500},
				{id: 304, num: 500},
				{id: 305, num: 500}
			];
			var shelf:Shelf;
			var index:int = 0;
			parent:
			for(var j:int = 0;j<vecShelf.length;j++)
			{
				shelf = vecShelf[j];
				for (var k:int = 0; k < shelf.vo.count; k++) 
				{
					if(arr[index])
					{
						shelf.putInProp(k, arr[index].id, arr[index].num);
						index ++;
					}else
					{
						if(k == 0)
							shelf.visible = false;
						continue parent;
					}
				}
			}
		}
		
		/**
		 * 需要补货的货架队列
		 */		
		private var vecWait:Vector.<Shelf> = new Vector.<Shelf>();
		public function addToWait(shelf:Shelf):void
		{
			if(vecWait.indexOf( shelf ) == -1)
				vecWait.push( shelf );
			if(!timer.running)
				timer.start();
		}
		
		
		
		private static var _instance:ShelfManager;
		public static function getInstance():ShelfManager
		{
			if(!_instance)
				_instance = new ShelfManager();
			return _instance;
		}
		
		public function getShelfByPropID(propID:String):Shelf
		{
			for each(var shelf:Shelf in vecShelf)
			{
				if(shelf.ifPropIn(propID))
					return shelf;
			}
			return null;
		}
	}
}