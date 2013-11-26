package global
{
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class StatusManager
	{
		private static var _instance:StatusManager;
		public static function instance():StatusManager
		{
			if(!_instance)
				_instance = new StatusManager();
			return _instance;
		}
		
		public function StatusManager()
		{
			dicFunc = new Dictionary();
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
		
		private var dicFunc:Dictionary;
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
			if(dicFunc.hasOwnProperty( func ))
				delete dicFunc[func];
		}
	}
}