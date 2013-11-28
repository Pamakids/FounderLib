package view.unit.w
{
	import com.astar.core.IAstarTile;
	import com.astar.expand.ItemTile;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import global.StatusManager;
	import view.unit.BasicUnit;

	/**
	 * 可移动的
	 * @author Administrator
	 */	
	public class Walker extends BasicUnit
	{
		/**
		 * 抵达目标时派发
		 */		
		public static const ARRIVED:String = "arrived";
		
		/**
		 * 动作状态：0静止，1行走
		 */		
		private var state:int = 0;
		/**动作帧索引*/		
		public static const ACTION_STAY_UP:int = 1;
		public static const ACTION_STAY_DOWN:int = 2;
		public static const ACTION_STAY_LEFT:int = 3;
		public static const ACTION_STAY_RIGHT:int = 4;
		public static const ACTION_MOVE_UP:int = 5;
		public static const ACTION_MOVE_DOWN:int = 6;
		public static const ACTION_MOVE_LEFT:int = 7;
		public static const ACTION_MOVE_RIGHT:int = 8;
		
		public function Walker()
		{
			this.addEventListener(Walker.ARRIVED, onArrived);
		}
		
		protected function onArrived(e:Event):void
		{
		}
		
		private var vx:int;
		private var vy:int;
		public function get SPEED():uint
		{
			return 4;
		}
		/**
		 * 沿指定路线移动
		 * @param path
		 */		
		public function startMove(_path:Vector.<IAstarTile>):void
		{
			if(!this.path)
				this.path = new Vector.<IAstarTile>();
			_path.splice(0,1);
			this.path = this.path.concat(_path);
			StatusManager.getInstance().addFunc( onTimer , 0.05);
		}
		
		protected var path:Vector.<IAstarTile>;
		
		/**
		 * 朝向:
		 * 1:	 上
		 * 2:	下
		 * 3:	左
		 * 4:	右
		 */		
		protected var direction:int = 0;
		
		private function onTimer():void
		{
			var tile:ItemTile = path[0] as ItemTile;
			//确定方向
			var tp:Point = tile.getPosition();
			var cp:Point = crtTile.getPosition();
			if(tp.x == cp.x)
			{
				if(tp.y > cp.y)
					direction = 2;
				else
					direction = 1;
			}else if(tp.y == cp.y)
			{
				if(tp.x > cp.x)
					direction = 4;
				else
					direction = 3;
			}
			if(action.currentFrame != direction+4)
				action.gotoAndStop( 4+direction );
			
			const X:int = tile.place.x;
			const Y:int = tile.place.y;
			vx = X-crtTile.place.x==0 ? 0 : ( X - crtTile.place.x>0?SPEED:-SPEED );
			vy = Y-crtTile.place.y==0 ? 0 : ( Y - crtTile.place.y>0?SPEED:-SPEED );
			this.x += vx;
			this.y += vy;
			if(this.x == X && this.y == Y)
			{
				this.crtTile = path.shift() as ItemTile;
				if(path.length == 0)
				{
					StatusManager.getInstance().delFunc( onTimer );
					action.gotoAndStop(direction);
					dispatchEvent(new Event(ARRIVED));
				}
			}
		}
		
		public function pause():void
		{
			if(this.path)
			{
				StatusManager.getInstance().delFunc( onTimer );
				if(crtTile.place.x == x &&　crtTile.place.y == y)
					path.splice(0, path.length);
				else
					path.splice(1, path.length-1);
			}
		}
		
		/**
		 * @return 
		 */		
		public function isCrtPathEnd(tile:IAstarTile):Boolean
		{
			if(path && path.length>0 && tile == path[path.length-1])
				return true;
			return false;
		}
		
		public function getCrtPathEnd():IAstarTile
		{
			if(path && path.length > 0)
				return path[path.length-1];
			return crtTile;
		}
		
		override public function dispose():void
		{
			StatusManager.getInstance().delFunc( onTimer );
			this.removeEventListener(Walker.ARRIVED, onArrived);
			if(path)	path = null;
			super.dispose();
		}
	}
}