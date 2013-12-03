package global
{
	import model.ShelfVO;
	
	import view.component.LogicalMap;
	import view.screen.MainScreen;
	import view.unit.Shelf;

	/**
	 * 货架管理器
	 * @author Administrator
	 */	
	public class ShelfManager
	{
		
		private static var _instance:ShelfManager;
		public static function getInstance():ShelfManager
		{
			if(!_instance)
				_instance = new ShelfManager();
			return _instance;
		}
		
		public function ShelfManager()
		{
			init();
		}
		
		private function init():void
		{
			parseXML();
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
		
		private var vecShelf:Array = [];
		public function creatShelves():void
		{
			var map:LogicalMap = LogicalMap.getInstance();
			var shelf:Shelf;
			var vo:ShelfVO;
			for(var i:int = datas.length-1;i>=0;i--)
			{
				vo = datas[i];
				shelf = new Shelf(vo);
				shelf.setCrtTile( map.getTileByPosition( vo.position ) );
				vecShelf[i] = shelf;
			}
			
			vecShelf.sortOn("y");
			var main:MainScreen = MC.instance().mainScreen;
			for(i = 0;i<vecShelf.length;i++)
			{
				main.addUnit( vecShelf[i] );
			}
		}
		
		//将物品放入货架
		public function setGoods():void
		{
			var shelf:Shelf;
			var index:int = 0;
			var arr:Array = StoreManager.getInstance().getPropList();
			parent:
			for(var j:int = 0;j<vecShelf.length;j++)
			{
				shelf = vecShelf[j];
				shelf.clear();
				for (var k:int = 0; k < shelf.vo.count; k++) 
				{
					if(arr[index])
					{
						shelf.putInProp(k, arr[index][0], arr[index][1]);
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
		private var vecWait:Array = [];
		public function addToWait(shelf:Shelf):void
		{
			if(/*shelf.needResplenish() && */vecWait.indexOf( shelf ) == -1)
				vecWait.push( shelf );
		}
		public function delFromWait(shelf:Shelf):void
		{
			var i:int = vecWait.indexOf( shelf );
			if(i != -1)
				vecWait.splice( i, 1 );
		}
		//获取等待补货的shelf
		public function getWaitShelf():Shelf
		{
			if(vecWait.length > 0)
				return vecWait.shift();
			return null;
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
		
		public function clear():void
		{
			vecWait.splice(0, vecWait.length);
			vecShelf.splice( 0, vecShelf.length );
		}
	}
}