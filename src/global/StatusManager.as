package global
{
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import controller.ServiceController;

	import model.ShopperVO;

	public class StatusManager
	{
		private static var _instance:StatusManager;

		public static function getInstance():StatusManager
		{
			if (!_instance)
				_instance=new StatusManager();
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
			timer=new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}

		private function onTimer(event:TimerEvent):void
		{
			var obj:Object;
			var time:uint=getTimer();
			for (var func:Object in dicFunc)
			{
				obj=dicFunc[func];
				if (time - obj.last > obj.rate * 1000)
				{
					func();
					obj.last=time - (time - obj.last) % (obj.rate * 1000);
				}
			}
		}

		private var dicFunc:Dictionary=new Dictionary();

		/**
		 * @param func	方法
		 * @param rate	调用频率，单位：秒
		 */
		public function addFunc(func:Function, rate:Number=1):void
		{
			if (dicFunc.hasOwnProperty(func))
				return;
			dicFunc[func]={rate: rate, last: getTimer()};
		}

		public function delFunc(func:Function):void
		{
			for (var f:Object in dicFunc)
			{
				if (f == func)
				{
					delete dicFunc[func];
					return;
				}
			}
		}

		private var isStart:Boolean=false;

		public function get ifStarted():Boolean
		{
			return isStart;
		}

		public function startGame():void
		{
			if (isStart)
				return;
			trace("GameStart");
			isStart=true;
			StoreManager.getInstance().reCatchGoods(); //重新获取仓库内物品列表
			ShelfManager.getInstance().setGoods(); //清理货架，重新添置物品
			ServiceController.instance.addShopper=ShopperManager.getInstance().creatShopper;
			addFunc(MC.instance().mainScreen.resetViewLevel, 0.25); //显示层级
			test();
		}

		private function test():void
		{
			MC.instance().mainScreen.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				var arr:Array=[[101, 10], [102, 10], [103, 10], [104, 10], [105, 10], [201, 10], [202, 10], [203, 10], [204, 10], [301, 10], [302, 10], [303, 10], [304, 10], [305, 10]];
				var price:Number=3;
				var a:Array=[];
				var temp:Array;
				var n:uint=Math.floor(Math.random() * 2) + 1;
				for (var i:int=0; i < n; i++)
				{
					temp=arr[Math.floor(Math.random() * arr.length)]; //id, num
					temp.push(price); //price
					temp.push(false); //catched
					a.push(temp);
				}

				var vo:ShopperVO=new ShopperVO(0, a);
				ShopperManager.getInstance().creatShopper(vo);
			});
		}

		private var callback:Function;

		public function quitGame(_callback:Function=null):void
		{
			callback=_callback;
			//验证店内是否依然有顾客，等待顾客全部移除后结束游戏
			addFunc(checkIfQuit, 1);
		}

		private function checkIfQuit():void
		{
			if (ShopperManager.getInstance().getShopperNum() == 0)
			{
				delFunc(checkIfQuit);
				quitHandler();
			}
		}

		private function quitHandler():void
		{
			isStart=false;
			delFunc(MC.instance().mainScreen.resetViewLevel);
			trace("GameOver");
			//doSomething
			if (callback)
				callback();
		}

		public function clear():void
		{
			for (var obj:Object in dicFunc)
			{
				delete dicFunc[obj];
			}
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer=null;
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
