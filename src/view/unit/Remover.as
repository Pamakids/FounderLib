package view.unit
{
	import flash.display.MovieClip;
	
	import global.AssetsManager;

	/**
	 * 理货员
	 * @author Administrator
	 */	
	public class Remover extends Walker
	{
		public function Remover()
		{
			super();
		}
		
		override protected function init():void
		{
			initAction();
		}
		
		private function initAction():void
		{
			action = AssetsManager.instance().getResByName("remover") as MovieClip;
			this.addChild( action );
			action.gotoAndStop(ACTION_STAY_LEFT);
			action.mouseEnabled = action.mouseChildren = false;
			
		}
	}
}