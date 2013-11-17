package view.wins
{
	import flash.display.MovieClip;
	import flash.display.Sprite;

	/**
	 * 窗口基类
	 */	
	public class WinBase extends Sprite
	{
		/**
		 * 窗口id
		 */		
		public var id:int;
		/**
		 * 窗口主元件
		 */		
		public var mc:MovieClip;
		
		public function WinBase()
		{
		}
		
		public function dispose():void
		{
		}
	}
}