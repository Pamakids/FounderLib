package com.astar.expand
{
	import com.astar.basic2d.BasicTile;
	
	import flash.geom.Point;
	
	import view.component.LogicalRect;
	
	public class ItemTile extends BasicTile
	{
		private var _rect:LogicalRect;
		public function ItemTile(cost:Number, position:Point, walkable:Boolean)
		{
			super(cost, position, walkable);
		}
		
		public function set rect(item:LogicalRect):void
		{
			if(_rect && _rect == item)
				return;
			_rect = item;
		}
		
		public function get rect():LogicalRect
		{
			return _rect;
		}
	}
}