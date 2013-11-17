package view.unit
{
	import com.astar.expand.ItemTile;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;

	/**
	 * 地图单位基类
	 * @author Administrator
	 */	
	public class BasicUnit extends Sprite
	{
		/**交互事件*/		
		public static const INTERACTIVED:String = "interactived";
		
		protected var action:MovieClip;
		
		public function BasicUnit()
		{
			this.buttonMode = true;
			this.useHandCursor = true;
			init();
		}
		
		protected function init():void
		{
		}
		
		protected var crtTile:ItemTile;
		public function setCrtTile(tile:ItemTile):void
		{
			if(crtTile && crtTile == tile)
				return;
			this.crtTile = tile;
			this.x = tile.rect.x;
			this.y = tile.rect.y;
		}
	}
}