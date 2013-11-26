package view.unit
{
	import com.astar.expand.ItemTile;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import view.component.LogicalMap;

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
		}
		
		protected var crtTile:ItemTile;
		public function setCrtTile(tile:ItemTile):void
		{
			if(crtTile && crtTile == tile)
				return;
			this.crtTile = tile;
			var p:Point = LogicalMap.turnPointToPosition( crtTile.getPosition() );
			this.x = p.x;
			this.y = p.y;
		}
		
		public function getCrtTile():ItemTile
		{
			return crtTile;
		}
		
		public function dispose():void
		{
			crtTile = null;
		}
	}
}