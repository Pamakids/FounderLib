package view.screen
{
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import global.AssetsManager;
	import global.PlansManager;
	import global.ShelfManager;
	import global.ShopperManager;
	import global.StoreManager;
	import global.WorkerManager;
	
	import view.component.LogicalMap;
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
			//初始化仓库
			store = StoreManager.getInstance();
			//销售方案管理
			plansManager = PlansManager.getInstance();
			
			container = new Sprite();
			this.addChild( container );
			//货架管理器
			shelfManager = ShelfManager.getInstance();
			shelfManager.creatShelf(container);
			//雇员管理器
			workerManager = WorkerManager.getInstance();
			workerManager.creatWorker(container);
			
			//顾客管理器
			shopperManager = ShopperManager.getInstance();
			shopperManager.setContainer(container);
			
			test();
		}
		
		private function test():void
		{
			shopperManager.creatShopper();
//			shopperManager.creatShopper();
//			shopperManager.creatShopper();
//			
//			TweenLite.delayedCall(5, shopperManager.creatShopper);
//			TweenLite.delayedCall(6, shopperManager.creatShopper);
//			TweenLite.delayedCall(7, shopperManager.creatShopper);
			
//			tileMap.moveBody( workerManager.getFreeRomover(), tileMap.getTileByPosition(new Point( 5,19 )));
		}
		
		private var store:StoreManager;
		private var plansManager:PlansManager;
		private var shelfManager:ShelfManager;
		private var workerManager:WorkerManager;
		private var shopperManager:ShopperManager;
		
	}
}