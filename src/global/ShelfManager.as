package global
{
	import flash.display.Sprite;
	
	import model.ShelfVO;
	
	import view.component.LogicalMap;
	import view.unit.Shelf;

	/**
	 * 货架管理器
	 * @author Administrator
	 */	
	public class ShelfManager
	{
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
			var xml:XMLList = DC.instance().mapXML.shelf;
			datas = new Vector.<ShelfVO>();
			for(var i:int = 1;i<int.MAX_VALUE;i++)
			{
				if(!xml.hasOwnProperty("s"+i))
					break;
				var vo:ShelfVO = new ShelfVO(i.toString());
				vo.parseByXmlContent(xml["s"+i].toString());
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
		}
		
		private static var _instance:ShelfManager;
		public static function getInstance():ShelfManager
		{
			if(!_instance)
				_instance = new ShelfManager();
			return _instance;
		}
	}
}