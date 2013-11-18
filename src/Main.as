package
{
	import com.pamakids.components.base.UIComponent;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import controller.ServiceController;
	
	[SWF(width="1024", height="768", frameRate="30", backgroundColor="0x333333")]
	public class Main extends UIComponent
	{
		public function Main()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			super(1024, 768);
		}

		override protected function init():void
		{
			super.init();
			ServiceController.instance.init();
			this.addChild( new GameDemo() );
		}
	}
}
