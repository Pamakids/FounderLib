package view.component
{
	import com.astar.expand.ItemTile;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import global.AssetsManager;
	
	public class LogicalRect extends Sprite
	{
		public static const ITEM_WIDTH:uint = 32;
		public static const ITEM_HEIGHT:uint = 32;
		
		private var mc:MovieClip;
		public function LogicalRect(tile:ItemTile)
		{
			this.tile = tile;
			this.tile.rect = this;
			this.mc = AssetsManager.instance().getResByName("item") as MovieClip;
			this.addChild( mc );
			mc.alpha = .4;
			
			if(tile.getWalkable())
				mc.gotoAndStop(1);
			else
				mc.gotoAndStop(2);
			
			this.graphics.beginFill(0xffffff);
			this.graphics.drawCircle(0,0,2);
			this.graphics.endFill();
			
			textfield = new TextField();
			textfield.width = 64;
			textfield.height = 32;
			this.addChild( textfield );
			
			textfield.x = -32;
			textfield.y = -16;
			textfield.mouseEnabled = false;
			textfield.multiline = false;
			textfield.defaultTextFormat = new TextFormat(null, null, 0x0000ff, null, null, null, null, null, "center");
			
			this.mouseEnabled = this.mouseChildren = false;
		}
		
		public function setPositionText(x:int, y:int):void
		{
			textfield.text = x + "," + y;
		}
		
		private var textfield:TextField;
		private var tile:ItemTile;
		
		public function getTile():ItemTile
		{
			return tile;
		}
	}
}