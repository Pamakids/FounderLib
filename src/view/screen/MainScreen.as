package view.screen
{
	import flash.display.Sprite;
	
	import global.AssetsManager;
	
	import view.unit.BasicUnit;
	import view.unit.Shopper;

	/**
	 * 主场景
	 * @author Administrator
	 */	
	public class MainScreen extends Sprite
	{
		public function MainScreen()
		{
			init();
		}
		
		private function init():void
		{
			bg = AssetsManager.instance().getResByName("background") as Sprite;
			this.addChild( bg );
			container = new Sprite();
			this.addChild( container );
		}
		private var bg:Sprite;
		private var container:Sprite;
		
		public function resetViewLevel():void
		{
			arrUnit.sortOn("y");
			for(var i:int = 0;i<arrUnit.length;i++)
			{
				container.setChildIndex(arrUnit[i], i);
			}
		}
		
		private var arrUnit:Array = [];
		public function addUnit(uint:BasicUnit):void
		{
			if(uint is Shopper)
				container.addChildAt( uint, 0 );
			else
				container.addChild( uint );
			arrUnit.push( uint );
		}
		
		public function delUnit(view:BasicUnit):void
		{
			if(view.parent)
				view.parent.removeChild( view );
			arrUnit.splice( arrUnit.indexOf( view ), 1 );
			view.dispose();
		}
		
		public function dispose():void
		{
			for(var i:int = arrUnit.length-1;i>=0;i--)
			{
				delUnit( arrUnit[i] );
			}
			this.removeChild( container );
			this.removeChild( bg );
			bg = null;
			container = null;
			arrUnit = null;
		}
	}
}