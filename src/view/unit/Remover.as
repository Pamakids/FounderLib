package view.unit
{
	import com.astar.expand.ItemTile;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import global.AssetsManager;
	import global.StatusManager;
	
	import model.StaffVO;
	
	import view.component.LogicalMap;

	/**
	 * 理货员
	 * @author Administrator
	 */	
	public class Remover extends Walker
	{
		/**
		 * 是否空闲
		 */		
		public var isFree:Boolean = true;
		private var vo:StaffVO;
		public function Remover(vo:StaffVO)
		{
			super();
			this.vo = vo;
			init();
		}
		
		private function init():void
		{
			initAction();
			initProbar();
		}
		
		private var probar:MovieClip;
		private function initProbar():void
		{
			probar = AssetsManager.instance().getResByName("probar") as MovieClip;
			this.addChild( probar );
			probar.y = - action.height - 10;
			probar.gotoAndStop(1);
			probar.visible = false;
		}
		
		override protected function get SPEED():uint
		{
			return 8;
		}
		override protected function onArrived(e:Event):void
		{
			replenishHandler();
		}
		
		private var targetShelf:Shelf;
		private function replenishHandler():void
		{
			probar.visible = true;
			probar.gotoAndStop(1);
			action.gotoAndStop(ACTION_STAY_UP);
			
			start = getTimer();
			StatusManager.getInstance().addFunc( onTimer, 0.05 );
		}
		
		private function onTimer():void
		{
			var time:uint = getTimer();
			var i:int = Math.floor( Math.min( (time-start)/(vo.ability*1000) , 1)*100 );
			probar.gotoAndStop( i );
			if(time - start >= vo.ability*1000)
			{
				StatusManager.getInstance().delFunc( onTimer );
				probar.gotoAndStop( 1 );
				probar.visible = false;
				action.gotoAndStop(ACTION_STAY_DOWN);
				targetShelf.resplenish();
				targetShelf = null;
				isFree = true;
			}
		}
		private var start:uint;
		
		private function initAction():void
		{
			action = AssetsManager.instance().getResByName("remover") as MovieClip;
			this.addChild( action );
			action.gotoAndStop(ACTION_STAY_LEFT);
			action.mouseEnabled = action.mouseChildren = false;
			action.scaleX = action.scaleY = .5;
		}
		
		/**
		 * 补货
		 * @param param0
		 */		
		public function replenish(shelf:Shelf):void
		{
			isFree = false;
			targetShelf = shelf;
			var tile:ItemTile = targetShelf.getTargetTile();
			if(tile == crtTile)
				replenishHandler();
			else
				LogicalMap.getInstance().moveBody(this, tile);
		}
		
		override public function dispose():void
		{
			StatusManager.getInstance().delFunc( onTimer );
			vo = null;
			this.removeChild( probar );
			probar = null;
			this.removeChild( action );
			action = null;
			super.dispose();
		}
		
		public function getAbility():Number
		{
			return vo.ability;
		}
	}
}