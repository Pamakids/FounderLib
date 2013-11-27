package com.astar.expand
{
	import com.astar.basic2d.BasicTile;
	
	import flash.geom.Point;
	
	import view.component.LogicalMap;
	
	public class ItemTile extends BasicTile
	{
		public function ItemTile(cost:Number, position:Point, walkable:Boolean)
		{
			super(cost, position, walkable);
		}
		
		private var _place:Point;
		public function get place():Point
		{
			if(!_place)
				_place = LogicalMap.turnPointToPosition( this.getPosition() );
			return _place;
		}
		
		override public function setPosition(p:Point):void
		{
			super.setPosition(p);
			this._place = LogicalMap.turnPointToPosition( p );
		}
	}
}