package view.unit
{
	import com.astar.expand.ItemTile;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import global.AssetsManager;
	
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
		
		override protected function onArrived(e:Event):void
		{
			trace("arrived");
			replenishHandler();
		}
		
		private var targetShelf:Shelf;
		private function replenishHandler():void
		{
			trace("开始补货");
			probar.visible = true;
			action.gotoAndStop(ACTION_STAY_UP);
			probar.gotoAndPlay(1);
			probar.addFrameScript(probar.totalFrames-1, replenishComplete);
		}
		
		private function replenishComplete():void
		{
			probar.stop();
			probar.visible = false;
			action.gotoAndStop(ACTION_STAY_DOWN);
			targetShelf.resplenish();
			targetShelf = null;
			isFree = true;
		}
		
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
			super.dispose();
			this.removeChild( action );
			action = null;
			this.removeChild( probar );
			probar = null;
		}
		
		public function getAbility():Number
		{
			return vo.ability;
		}
	}
}