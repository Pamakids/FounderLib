package view.unit
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import global.AssetsManager;
	
	import model.ShopperVO;

	/**
	 * 顾客
	 * @author Administrator
	 */	
	public class Shopper extends Walker
	{
		/**
		 * 每采购到一种物品即派发
		 */		
		public static const SHOP_CATCHED:String = "shop_catched";
		/**
		 * 采购到清单中的所有物品即派发
		 */		
		public static const SHOP_FINISHED:String = "shop_finished";
		/**
		 * 采购失败派发
		 */		
		public static const SHOP_FAILED:String = "shop_failed";
		
		private var vo:ShopperVO;
		public function Shopper(vo:ShopperVO)
		{
			this.vo = vo;
			super();
		}
		
		override protected function init():void
		{
			initAction();
			initIcon();
			catchProp();
			this.mouseChildren = this.mouseEnabled = false;
		}
		
		private function catchProp():void
		{
		}
		
		private var vecIcon:Vector.<Sprite>;
		private function initIcon():void
		{
			const gap:uint = 10;
			const w:uint = 20;
			const padding:uint = 5;
			const num:uint = vo.shopperList.length;
			vecIcon = new Vector.<Sprite>(num);
			var arr:Array;
			var icon:Sprite;
			for(var i:int = 0;i<num;i++)
			{
				arr = vo.shopperList[i];
				icon = AssetsManager.instance().getResByName("sprite_"+arr[0]) as Sprite;
				title.addChild( icon );
				icon.x = padding + i*(w+gap) - title.width/2;
				icon.y = -30;
				trace(icon.width, icon.height);
				vecIcon[i] = icon;
			}
			title.bg.width = (num-1)*gap + w*num + padding*2;
		}
		
		private var title:MovieClip;
		
		private function initAction():void
		{
			action = AssetsManager.instance().getResByName("shopper_"+vo.type) as MovieClip;
			action.gotoAndStop(ACTION_STAY_RIGHT);
			this.addChild( action );
			
			title = AssetsManager.instance().getResByName("title") as MovieClip;
			title.y = -action.height;
			this.addChild( title );
		}
		
	}
}