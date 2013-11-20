package view.unit
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import global.AssetsManager;
	
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
		public function Remover()
		{
			super();
		}
		
		override protected function init():void
		{
			initAction();
			initProbar();
			this.addEventListener(Walker.ARRIVED, onArrived);
		}
		
		private var probar:MovieClip;
		private function initProbar():void
		{
			probar = AssetsManager.instance().getResByName("probar") as MovieClip;
			this.addChild( probar );
			probar.y = - action.height - 10;
//			probar.gotoAndStop(1);
//			probar.visible = false;
		}
		
		protected function onArrived(event:Event):void
		{
			replenishHandler();
		}
		
		private var targetShelf:Shelf;
		private function replenishHandler():void
		{
			trace("开始补货");
		}
		
		private function initAction():void
		{
			action = AssetsManager.instance().getResByName("shopper_0") as MovieClip;
			this.addChild( action );
			action.gotoAndStop(ACTION_STAY_LEFT);
			action.mouseEnabled = action.mouseChildren = false;
		}
		
		/**
		 * 补货
		 * @param param0
		 */		
		public function replenish(shelf:Shelf):void
		{
			isFree = false;
			targetShelf = shelf;
			LogicalMap.getInstance().moveBody(this, shelf.getCrtTile());
		}
	}
}