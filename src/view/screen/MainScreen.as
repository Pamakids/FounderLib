package view.screen
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import global.AssetsManager;
	import global.ShelfManager;
	import global.ShopperManager;
	import global.StatusManager;
	import global.WorkerManager;
	
	import view.component.LogicalMap;
	import view.unit.BasicUnit;
	import view.unit.Shopper;
	import view.unit.Walker;

	/**
	 * 主场景
	 * @author Administrator
	 */	
	public class MainScreen extends Sprite
	{
		public function MainScreen()
		{
			init();
		}
		
		/**
		 * 地图逻辑格
		 */		
		private var tileMap:LogicalMap;
		
		private function init():void
		{
			initMap();
			initManager();
			
		}
		
		private var bg:Sprite;
		private function initMap():void
		{
			bg = AssetsManager.instance().getResByName("background") as Sprite;
			this.addChild( bg );
			
			tileMap = LogicalMap.getInstance();
			this.addChild( tileMap );
//			tileMap.visible = false;
			tileMap.mouseEnabled = tileMap.mouseChildren = false;
		}
		
		private var container:Sprite;
		private var role:Walker;
		private function initManager():void
		{
			//销售方案管理
			container = new Sprite();
			this.addChild( container );
			//货架管理器
			shelfManager = ShelfManager.getInstance();
			shelfManager.setMainStage( this );
			//雇员管理器
			workerManager = WorkerManager.getInstance();
			workerManager.setMainStage( this );
			//顾客管理器
			shopperManager = ShopperManager.getInstance();
			shopperManager.setMainStage( this );
			
			StatusManager.instance().addFunc( resetViewLevel, 0.5 );
			
			test();
		}
		
		private function test():void
		{
			this.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				shopperManager.creatShopper();
			});
		}
		
		private var shelfManager:ShelfManager;
		private var workerManager:WorkerManager;
		private var shopperManager:ShopperManager;
		
		private function resetViewLevel():void
		{
			arrUnit.sortOn("y");
			for(var i:int = 0;i<arrUnit.length;i++)
			{
				container.setChildIndex(arrUnit[i], i);
			}
		}
		
		private var arrUnit:Array = [];
		public function addUnit(uint:BasicUnit):void
		{
			container.addChild( uint );
			arrUnit.push( uint );
		}
		
		public function delUnit(shopper:Shopper):void
		{
			container.removeChild( shopper );
			arrUnit.splice( arrUnit.indexOf( shopper ), 1 );
			shopper.dispose();
		}
	}
}