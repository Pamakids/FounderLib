package view.unit
{
	import com.pamakids.manager.SoundManager;
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.utils.getTimer;
	
	import controller.ServiceController;
	
	import global.AssetsManager;
	import global.ShopperManager;
	import global.StatusManager;
	import global.StoreManager;
	
	import model.StaffVO;
	
	import view.component.Pop;

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
			popPoint = new Point(0, -action.height-5);
			popPoint = this.localToGlobal( popPoint );
			initProbar();
			sound = AssetsManager.instance().getSounds("sound_cashier");
		}
		
		private var sound:Sound;
		private var popPoint:Point;
		
		
		private var probar:MovieClip;
		private function initProbar():void
		{
			probar = AssetsManager.instance().getResByName("probar") as MovieClip;
			this.addChild( probar );
			probar.visible = false;
			probar.x = 113;
			probar.y = -191;
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
			probar.gotoAndStop(1);
			action.play();
			start = getTimer();
			StatusManager.getInstance().addFunc( onTimer, 0.05 );
		}
		private var start:uint;
		private var crtShopper:Shopper;
		private function onTimer():void
		{
			var time:uint = getTimer();
			var i:int = Math.floor( Math.min( (time-start)/(vo.ability*1000) , 1)*100 );
			probar.gotoAndStop( i );
			if(time - start >= vo.ability*1000)
			{
				StatusManager.getInstance().delFunc( onTimer );
				probar.gotoAndStop(1);
				probar.visible = false;
				action.play();
				var list:Array = crtShopper.getShoppingList();
				var value:Number = liquidation(list);
				ServiceController.instance.player1.cash += value;		//现金结算
																			//记录该回合盈利
				StoreManager.getInstance().delGoodsFromSource( crtShopper.getShoppingList() );
				ShopperManager.getInstance().outShop( crtShopper );
				crtShopper = null;
				
				Pop.show(Pop.POPID_MONEY, value, stage, popPoint);
				SoundManager.instance.play(sound);
			}
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
		/**
		 * 用户所购物品总成本
		 * @param list
		 * @return 
		 */		
		private function allCost(list:Array):Number
		{
			var num:Number = 0;
			for each(var arr:Array in list)
			{
				num += StoreManager.getInPriceByID(arr[0]) * arr[1];
			}
			return num;
		}
		
		public function getAbility():uint
		{
			return vo.ability;
		}
		
		override public function dispose():void
		{
			StatusManager.getInstance().delFunc( onTimer );
			this.removeChild( probar );
			probar = null;
			this.removeChild( action );
			action = null;
			vo = null;
			super.dispose();
		}
	}
}