package
{
	import flash.display.Sprite;
	
	import global.AssetsManager;
	import global.MC;
	import global.ShelfManager;
	import global.ShopperManager;
	import global.StatusManager;
	import global.StoreManager;
	import global.WorkerManager;

	public class GameDemo extends Sprite
	{
		private var assets:AssetsManager;
		
		public function GameDemo()
		{
			init();
		}
		private function init():void
		{
			MC.instance().setMainContainer(this);
			MC.instance().openScreen();
			ShelfManager.getInstance().creatShelves();
			WorkerManager.getInstance().creatWorkes();
			ShopperManager.getInstance().initialize();
			StatusManager.getInstance().initlize();
			StatusManager.getInstance().startGame();
		}
		
		public function dispose():void
		{
			MC.instance().closeScreen();
			clearManagers();
		}
		
		private function clearManagers():void
		{
			ShelfManager.getInstance().clear();
			StoreManager.getInstance().clear();
			ShopperManager.getInstance().clear();
			WorkerManager.getInstance().clear();
			StatusManager.getInstance().clear();
		}
	}
}