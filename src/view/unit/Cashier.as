package view.unit
{
	import flash.display.MovieClip;
	import flash.utils.getTimer;
	
	import controller.ServiceController;
	
	import global.AssetsManager;
	import global.ShopperManager;
	import global.StatusManager;
	
	import model.StaffVO;

	/**
	 * 收银员
	 * @author Administrator
	 */	
	public class Cashier extends BasicUnit
	{
		private var vo:StaffVO;
		public function Cashier(vo:StaffVO)
		{
			super();
			this.vo = vo;
			init();
		}
		
		private function init():void
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
			action.gotoAndStop(1);
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
			start = getTimer();
			StatusManager.instance().addFunc( onTimer, 0.05 );
		}
		private var start:uint;
		private var crtShopper:Shopper;
		private function onTimer():void
		{
			var time:uint = getTimer();
			trace(time - start);
			trace(crtShopper);
			var i:int = Math.floor( Math.min( (time-start)/(vo.ability*1000) , 1)*100 );
			probar.gotoAndStop( i );
			if(time - start >= vo.ability*1000)
			{
				StatusManager.instance().delFunc( onTimer );
				probar.gotoAndStop( 1 );
				probar.visible = false;
				
				var list:Array = crtShopper.getShoppingList();
				ServiceController.instance.player1.cash += liquidation(list);		//现金结算
				ShopperManager.getInstance().outShop( crtShopper );
//				crtShopper = null;
			}
		}
		private function onComplete():void
		{
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
		
		public function getAbility():uint
		{
			return vo.ability;
		}
	}
}