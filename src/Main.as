package
{
	import com.pamakids.components.base.UIComponent;
	
	import flash.events.Event;
	
	import controller.ServiceController;
	
	public class Main extends UIComponent
	{
		public function Main()
		{
			super(1024, 768);
		}

		override protected function init():void
		{
			super.init();
			ServiceController.instance.init();
			ServiceController.instance.addEventListener(ServiceController.GAME_CONFIG_GOT, addGameDemo);
		}
		
		protected function addGameDemo(event:Event):void
		{
			this.addChild( new GameDemo() );
		}
	}
}
