package global
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	import view.screen.MainScreen;

	public class MC
	{
		public static const MAIN_MAP:int = 100;
		
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
		
		private var main:Sprite;
		public function setMainContainer(container:DisplayObjectContainer):void
		{
			if(!main)
				main = new Sprite();
			container.addChild( main );
		}
		
		public function openWindow(index:int):void
		{
		}
		
		public function closeWindow(index:int):void
		{
		}
		
		public function openScreen(index:int):void
		{
			switch(index)
			{
				case MAIN_MAP:
					openMainMap();
					break;
			}
		}
		
		public function closeScreen(index:int):void
		{
		}
		
		private var screen:MainScreen;
		private function openMainMap():void
		{
			if(!screen)
				screen = new MainScreen();
			main.addChild( screen );
		}
		
		public function teseIsOpend(index:int):Boolean
		{
			return false;
		}
	}
}