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
		}
		
		private var vecIcon:Vector.<Sprite>;
		private function initIcon():void
		{
			vecIcon = new Vector.<Sprite>(vo.shopperList.length);
			var arr:Array;
			for(var i:int = 0;i<vo.shopperList;i++)
			{
				arr = vo.shopperList[i];
				var icon:Sprite = AssetsManager.instance().getResByName("sprite_"+arr[0]) as Sprite;
				trace(icon.width, icon.height);
				vecIcon[i] = icon;
			}
		}
		
		private var title:Sprite;
		
		private function initAction():void
		{
			action = AssetsManager.instance().getResByName("shopper_0") as MovieClip;
			action.gotoAndStop(ACTION_STAY_RIGHT);
			this.addChild( action );
			
			title = AssetsManager.instance().getResByName("title") as Sprite;
			title.y = -action.height;
			this.addChild( title );
		}
		
	}
}