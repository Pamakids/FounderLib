package view.unit
{
	import flash.display.MovieClip;
	
	import controller.ServiceController;
	
	import global.AssetsManager;
	import global.ShopperManager;

	/**
	 * 收银员
	 * @author Administrator
	 */	
	public class Cashier extends BasicUnit
	{
		public function Cashier()
		{
			super();
		}
		
		override protected function init():void
		{
			initAction();
			initProbar();
		}
		
		private var probar:MovieClip;
		private function initProbar():void
		{
			probar = AssetsManager.instance().getResByName("probar") as MovieClip;
			action.addChild( probar );
			probar.visible = false;
			probar.x = 108;
			probar.y = -145;
			probar.mouseEnabled = probar.mouseChildren = false;
			probar.gotoAndStop(1);
		}
		
		private function initAction():void
		{
			action = AssetsManager.instance().getResByName("cashier") as MovieClip;
			this.addChild( action );
			this.mouseEnabled = this.mouseChildren = false;
		}
		
		/**
		 * 清算
		 * @param onComplete
		 */		
		public function serviceFor(shopper:Shopper):void
		{
			crtShopper = shopper;
			probar.visible = true;
			probar.gotoAndPlay(1);
			trace(probar.totalFrames);
			probar.addFrameScript(probar.totalFrames-1, onComplete);
		}
		
		private var crtShopper:Shopper;
		private function onComplete():void
		{
			probar.gotoAndStop( 1 );
			probar.visible = false;
			
			var list:Array = crtShopper.getShoppingList();
			ServiceController.instance.player1.cash += liquidation(list);		//现金结算
			ShopperManager.getInstance().outShop( crtShopper );
			crtShopper = null;
		}
		
		/**
		 * 用户所购物品总花销
		 * @return 
		 */		
		private function liquidation(list:Array):Number
		{
			var num:Number = 0;
			for each(var arr:Array in list)
			{
				num += arr[1]*arr[2];
			}
			return num;
		}
	}
}