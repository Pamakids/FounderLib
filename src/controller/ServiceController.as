package controller
{
	import com.pamakids.manager.LoadManager;
	import com.pamakids.models.ResultVO;
	import com.pamakids.services.ServiceBase;
	import com.pamakids.utils.BrowserUtil;
	import com.pamakids.utils.CloneUtil;
	import com.pamakids.utils.Singleton;

	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.utils.Dictionary;

	import events.ODataEvent;

	import model.GameConfigVO;
	import model.PlayerVO;
	import model.UserVO;

	import org.idream.pomelo.Pomelo;
	import org.idream.pomelo.PomeloEvent;

	public class ServiceController extends Singleton
	{
		public static const SINGED_IN:String="SINGED_IN";
		public static const GAME_CONFIG_GOT:String="GAME_CONFIG_GOT";

		public var isDebug:Boolean;

		public function ServiceController()
		{
			pomelo=Pomelo.getIns();
			pomelo.addEventListener('onAdd', addUserHandler);
			pomelo.addEventListener('onLeave', removeUserHandler);
			pomelo.addEventListener(Event.CLOSE, closeHandler);

			serviceDic=new Dictionary();
			callingDic=new Dictionary();

		}

		public var http:String;
		public var socket:String;

		public function init():void
		{
			LoadManager.instance.loadText('assets/config.json', loadedHandler);
		}

		private function loadedHandler(t:String):void
		{
			var o:Object=JSON.parse(t);
			isDebug=o.isDebug;
			if (isDebug)
			{
				ServiceBase.HOST=o.local;
				http=o.localHttp;
				socket=o.socket_local;
			}
			else
			{
				ServiceBase.HOST=o.local;
				socket=o.socket_remote;
				http=o.remoteHttp;
			}
			var query:Object=BrowserUtil.getQuery();
			if (!query || !query.u || !query.p)
			{
				alert('请先登录后再试');
			}
			else
			{
				userSignIn(query.u, query.p, function(result:ResultVO):void
				{
					if (result.status)
					{
						me=CloneUtil.convertObject(result.results, UserVO);
						getDefaultConfig();
						dispatchEvent(new Event(SINGED_IN));
					}
					else
					{
						alert('网络连接失败：' + result.errorResult);
					}
				});
			}
		}

		public static const USER_SIGN_IN:String="user/signIn";
		public static const GET_DEFAULT_CONFIG:String="gc/default";

		/**
		 * 游戏配置
		 */
		public var config:GameConfigVO;
		/**
		 * 自己
		 */
		public var player1:PlayerVO;
		/**
		 * 对手
		 */
		public var player2:PlayerVO;

		private function getDefaultConfig():void
		{
			var s:ServiceBase=getService(GET_DEFAULT_CONFIG, URLRequestMethod.GET);
			if (callingDic[s])
				return;
			callingDic[s]=true;
			s.call(function(result:ResultVO):void
			{
				if (result.status)
				{
					config=CloneUtil.convertObject(result.results, GameConfigVO);
					player1=new PlayerVO();
					player1.cash=config.startupMoney;
					dispatchEvent(new Event(GAME_CONFIG_GOT));
				}
				else
					alert('获取游戏配置失败');
				delete callingDic[s];
			}, {type: BrowserUtil.getQuery().t});
		}

		public function userSignIn(account:String, password:String, callback:Function):void
		{
			var s:ServiceBase=getService(USER_SIGN_IN, URLRequestMethod.POST);
			if (callingDic[s])
				return;
			callingDic[s]=true;
			s.call(function(result:ResultVO):void
			{
				if (result.status)
					ServiceBase.id=result.results._id;
				callback(result);
				delete callingDic[s];
			}, {account: account, password: password});
		}

		private function alert(text:String):void
		{
			dispatchEvent(new ODataEvent(text, 'alert'));
		}

		protected function closeHandler(event:Event):void
		{

		}

		protected function removeUserHandler(event:Event):void
		{

		}

		protected function addUserHandler(event:PomeloEvent):void
		{
			trace('onAdded', event.message.user);
			other=new UserVO();
			other.company_name=event.message.user.user;
		}

		private var pomelo:Pomelo;

		public static function get instance():ServiceController
		{
			return Singleton.getInstance(ServiceController);
		}

		public var me:UserVO;
		public var other:UserVO;

		public function call(href:String, callback:Function, data:Object, method:String='POST'):void
		{
			getService(href, method).call(callback, data);
		}


		private function getService(uri:String, method:String):ServiceBase
		{
			var s:ServiceBase=serviceDic[uri];
			if (!s)
				s=new ServiceBase(uri, method);
			return s;
		}

		private var serviceDic:Dictionary;
		private var callingDic:Dictionary;

	}
}
