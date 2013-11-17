package view.unit
{
	import flash.display.MovieClip;
	
	import global.AssetsManager;

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
			action = AssetsManager.instance().getResByName("cashier") as MovieClip;
			this.addChild( action );
			this.mouseEnabled = this.mouseChildren = false;
		}
	}
}