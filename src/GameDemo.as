package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import global.AssetsManager;
	import global.MC;

	[SWF(width="1024", height="768", frameRate="30", backgroundColor="0x333333")]
	public class GameDemo extends Sprite
	{
		private var assets:AssetsManager;
		
		public function GameDemo()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			init();
		}
		private function init():void
		{
			initData();
			loadAssets();
		}
		
		private function initData():void
		{
			
		}
		
		private function loadAssets():void
		{
			assets = AssetsManager.instance();
			assets.loadZip("assets/assets.zip", startGame);
		}
		
		private function startGame():void
		{
			AssetsManager.instance().parse();
			MC.instance().setMainContainer(this);
			MC.instance().openScreen(MC.MAIN_MAP);
		}
	}
}