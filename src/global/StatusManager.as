package global
{
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class StatusManager
	{
		private static var _instance:StatusManager;
		public static function getInstance():StatusManager
		{
			if(!_instance)
				_instance = new StatusManager();
			return _instance;
		}
		
		public function StatusManager()
		{
		}
		
		public function initlize():void
		{
			initTimer();
		}
		
		private var timer:Timer;
		private function initTimer():void
		{
			timer = new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		private function onTimer(event:TimerEvent):void
		{
			var obj:Object;
			var time:uint = getTimer();
			for(var func:Function in dicFunc)
			{
				obj = dicFunc[func];
				if(time - obj.last > obj.rate*1000)
				{
					func();
					obj.last = time - (time-obj.last) % (obj.rate*1000);
				}
			}
		}
		
		private var dicFunc:Dictionary = new Dictionary();
		/**
		 * @param func	方法
		 * @param rate	调用频率，单位：秒
		 */		
		public function addFunc(func:Function, rate:Number=1):void
		{
			if( dicFunc.hasOwnProperty(func) )
				return;
			dicFunc[func] = {rate: rate, last: getTimer()};
		}
		
		public function delFunc(func:Function):void
		{
			for(var f:Function in dicFunc)
			{
				if(f == func)
				{
					delete dicFunc[func];
					return;
				}
			}
		}
		
		private var isStart:Boolean = false;
		public function get ifStarted():Boolean
		{
			return isStart;
		}
		public function startGame():void
		{
			if(isStart)	return;
			trace("GameStart");
			isStart = true;
			StoreManager.getInstance().reCatchGoods();		//重新获取仓库内物品列表
			ShelfManager.getInstance().setGoods();		//清理货架，重新添置物品
			addFunc( MC.instance().mainScreen.resetViewLevel , 0.25 );	//显示层级
			test();
		}
		
		private function test():void
		{
			MC.instance().mainScreen.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				ShopperManager.getInstance().creatShopper();
			});
//			addFunc( ShopperManager.getInstance().creatShopper , 3);
		}
		
		public function quitGame():void
		{
			//验证店内是否依然有顾客，等待顾客全部移除后结束游戏
			addFunc( checkIfQuit, 1 );
		}
		
		private function checkIfQuit():void
		{
			if(ShopperManager.getInstance().getShopperNum() == 0)
			{
				delFunc( checkIfQuit );
				quitHandler();
			}
		}
		
		private function quitHandler():void
		{
			isStart = false;
			delFunc( MC.instance().mainScreen.resetViewLevel );
			trace("GameOver");
		}
		
		public function clear():void
		{
			for(var obj:Object in dicFunc)
			{
				delete dicFunc[obj];
			}
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer = null;
		}
		
		public function pause():void
		{
			timer.stop();
		}
		public function restart():void
		{
			timer.start();
		}
	}
}