package view.unit
{
	import com.astar.core.IAstarTile;
	import com.astar.expand.ItemTile;
	
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import global.AssetsManager;

	/**
	 * 可移动的
	 * @author Administrator
	 */	
	public class Walker extends BasicUnit
	{
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
			init();
		}
		
		override protected function init():void
		{
			action = AssetsManager.instance().getResByName("role") as MovieClip;
			action.gotoAndStop(ACTION_STAY_RIGHT);
			this.addChild( action );
			this.mouseChildren = this.mouseEnabled = false;
		}
		
		private var vx:int;
		private var vy:int;
		/**
		 * 沿指定路线移动
		 * @param path
		 */		
		public function startMove(path:Vector.<IAstarTile>):void
		{
			if(!this.path)	this.path = new Vector.<IAstarTile>();
			path.splice(0,1);
			this.path = this.path.concat(path);
			if(!timer)
				creatTimer();
			timer.start();
		}
		
		protected var path:Vector.<IAstarTile>;
		private var timer:Timer;
		private function creatTimer():void
		{
			timer = new Timer(50);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		/**
		 * 朝向:
		 * 1:	左上
		 * 2:	左下
		 * 3:	右上
		 * 4:	右下
		 */		
		private var direction:int = 0;
		
		protected function onTimer(event:TimerEvent):void
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
			
			
			const X:int = tile.rect.x;
			const Y:int = tile.rect.y;
			vx = X - crtTile.rect.x >> 1;
			vy = Y - crtTile.rect.y >> 1;
			this.x += vx;
			this.y += vy;
			if(this.x == X && this.y == Y)
			{
				this.crtTile = path.shift() as ItemTile;
				if(path.length == 0)
				{
					timer.stop();
					action.gotoAndStop(direction);
				}
			}
		}
		
		public function getCrtTile():ItemTile
		{
			return crtTile;
		}
		
		public function pause():void
		{
			if(this.path)
			{
//				timer.stop();
				if(path.length > 2)
				{
					path.splice(2, -1);
				}
//				if(crtTile.rect.x == x &&　crtTile.rect.y == y)
//				{
//					path.splice(0, path.length);
//				}
//				else
//				{
//					path.splice(1, path.length-1);
//				}
			}
		}
		
		/**
		 * @return 
		 */		
		public function isCrtPathEnd(tile:IAstarTile):Boolean
		{
			if(path && path.length>0 && tile == path[path.length-1])
				return true
			return false;
		}
		
		public function getCrtPathEnd():IAstarTile
		{
			if(path && path.length > 0)
				return path[path.length-1];
			return crtTile;
		}
	}
}