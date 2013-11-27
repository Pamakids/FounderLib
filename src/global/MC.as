package global
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	import view.screen.MainScreen;

	public class MC
	{
		private static var _instance:MC;
		public static function instance():MC
		{
			if(!_instance)
				_instance = new MC();
			return _instance;
		}
		
		public function MC()
		{
		}
		
		private var container:Sprite;
		public function setMainContainer(container:DisplayObjectContainer):void
		{
			if(!this.container)
				this.container = new Sprite();
			container.addChild( this.container );
		}
		
		public function openScreen():void
		{
			if(!mainScreen)
				mainScreen = new MainScreen();
			container.addChild( mainScreen );
		}
		
		public function closeScreen():void
		{
			if(StatusManager.getInstance().ifStarted)
				StatusManager.getInstance().quitGame();
			if(mainScreen)
			{
				container.removeChild( mainScreen );
				mainScreen.dispose();
				mainScreen = null;
			}
			container = null;
		}
		public var mainScreen:MainScreen;
	}
}