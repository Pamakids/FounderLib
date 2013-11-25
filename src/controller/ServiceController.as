package controller
{
	import com.pamakids.components.PAlert;
	import com.pamakids.events.ODataEvent;
	import com.pamakids.manager.LoadManager;
	import com.pamakids.models.ResultVO;
	import com.pamakids.services.ServiceBase;
	import com.pamakids.utils.BrowserUtil;
	import com.pamakids.utils.CloneUtil;
	import com.pamakids.utils.Singleton;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	import mx.collections.ArrayCollection;

	import global.DC;

	import model.BoughtGoodsVO;
	import model.GameConfigVO;
	import model.GoodsVO;
	import model.PlayerVO;
	import model.SaleStrategyVO;
	import model.ShopVO;
	import model.StaffVO;
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
			pomelo.addEventListener('onReady', onReadyHandler);
			pomelo.addEventListener('onGame', onGameHandler);
			pomelo.addEventListener(Event.CLOSE, closeHandler);
			serviceDic=new Dictionary();
			callingDic=new Dictionary();
		}

		protected function onGameHandler(event:PomeloEvent):void
		{
			trace(event.message);
		}

		protected function onReadyHandler(event:PomeloEvent):void
		{
			trace('onReady');
			for each (var o:Object in users)
			{
				if (o.user == event.message.user)
				{
					var user:Object=event.message;
					users[users.getItemIndex(o)]=user;
					dispatchEvent(new ODataEvent(user, USER_READY));
					isBothReady(user);
					break;
				}
			}
		}

		public var showReadyBox:Function;

		private function isBothReady(user:Object):void
		{
			var b:Boolean=true;

			for each (var u:Object in users)
			{
				if (!u.ready)
					b=false;
			}

			if (b)
			{
				trace('both ready');
				SO.i.setKV('player', player1);
//				SO.i.setKV('p2', player2);
				navigateToURL(new URLRequest(http + '/FounderFighting.html'), '_self');
			}
			else if (user.user == me.company_name && user.ready)
			{
				showReadyBox();
			}
		}

		public var http:String;
		public var socket:String;

		public function init():void
		{
			LoadManager.instance.loadText('assets/config.json', loadedHandler);
			LoadManager.instance.loadText('goods/data.json', loadGoodsHandler);
			LoadManager.instance.loadSWF('goods/assets.swf');
		}

		private var timer:Timer=new Timer(3000);

		/**
		 * 开始游戏，自动计时，同步现金数
		 */
		public function startGame():void
		{
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, sendGameMessageHandler);
		}

		public static const GAME_PAUSE:String="GAME_PAUSE";

		/**
		 * 暂停游戏，进入筹备阶段
		 */
		public function pauseGame():void
		{
			timer.stop();
			dispatchEvent(new Event(GAME_PAUSE));
		}

		protected function sendGameMessageHandler(event:TimerEvent):void
		{
			pomelo.request(sendGameMessage, {target: other.company_name, data: player1.cash}, function(data:Object):void
			{
				trace('sent data:', data);
			});
		}

		private var queryEntry:String="gate.gateHandler.queryEntry";
		private var enter:String='connector.entryHandler.enter';
		private var readyRoute:String='connector.entryHandler.ready';
		private var cancelReadyRoute:String='connector.entryHandler.cancelReady';
		private var sendGameMessage:String='game.gameHandler.send';

		public static const USER_READY:String="USER_READY";
		public static const ENTERED:String="ENTERED";
		public static const USER_CANCEL_READY:String="USER_CANCEL_READY";

		public var users:ArrayCollection;

		/**
		 * 房间ID
		 */
		private var rid:String;

		public function connect(room:String):void
		{
			rid=room;
			trace('connect game server', room, socket);
			pomelo.init(socket, 3014, null, function(res:Object):void
			{
				if (res.code == 200)
				{
					trace('connected');
					pomelo.request(queryEntry, {uid: me._id}, function(response:Object):void
					{
						trace("response host:", response.host, " port:", response.port);
						if (response.code == '500')
						{
							trace('500 user signed in');
							PAlert.show(response.message, '提示', null, null, 'normal', '', '', true);
							return;
						}
						pomelo.init(socket, response.port, null, function(response:Object):void
						{
							trace(response);
							pomelo.request(enter, {username: me.company_name, rid: room}, function(data:Object):void
							{
								if (data.error)
								{
									PAlert.show(data.message, '提示', null, null, 'normal', '', '', true);
								}
								else
								{
									users=new ArrayCollection();
									for each (var o:String in data.users)
									{
										var uo:Object=JSON.parse(o);
										if (uo.user != me.company_name)
										{
											other=new UserVO();
											other.company_name=uo.user;
										}
										else if (uo.user == me.company_name)
										{

										}
										users.addItem(uo);
									}
									if (users.length == 2)
										startGame();
									dispatchEvent(new Event(ENTERED));
								}
							});
						});
					});
				}
				else
				{
					PAlert.show('游戏服务器连接失败');
				}
			});
		}

		public var goodsDic:Dictionary;

		private function loadGoodsHandler(s:String):void
		{

			var data:Object=JSON.parse(s);
			var goods:Array=CloneUtil.convertArrayObjects(data.goods, GoodsVO);

			DC.instance().mapObj=data.map;
			DC.instance().shelfObj=data.shelf;
			DC.instance().propObj=data.goods;

			goodsDic=new Dictionary();
			for (var i:int; i < goods.length; i++)
			{
				var vo:GoodsVO=goods[i] as GoodsVO;
				var arr:Array=goodsDic[vo.type];
				if (!arr)
				{
					arr=[];
					goodsDic[vo.type]=arr;
				}
				arr.push(vo);
			}
		}

		public function getGoods(id:String):Sprite
		{
			var c:Class=getDefinitionByName('sprite_' + id) as Class;
			return new c;
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
				ServiceBase.HOST=o.remote;
				socket=o.socket_remote;
				http=o.remoteHttp;
			}
			var query:Object=BrowserUtil.getQuery();
			var uo:Object=SO.i.getKV('user');
			if (uo)
			{
				me=CloneUtil.convertObject(uo, UserVO);
				getDefaultConfig();
				dispatchEvent(new Event(SINGED_IN));
				return;
			}
			if (!query || !query.u)
				query={u: 1, p: 1, t: 2};
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
						SO.i.setKV('user', me);
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

		public var saleStrategies:Array;

		public static const USER_SIGN_IN:String="user/signIn";
		public static const GET_DEFAULT_CONFIG:String="gc/default";

		/**
		 * 游戏配置
		 */
		public var config:GameConfigVO;
		/**
		 * 自己
		 */
		[Bindable]
		public var player1:PlayerVO;

//		/**
//		 * 对手
//		 */
//		public var player2:PlayerVO;

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
					var pvo:Object=SO.i.getKV('player');
					if (!pvo)
					{
						player1=new PlayerVO();
						player1.cash=config.startupMoney;
						player1.user=me;
					}
					else
					{
						pvo.goods=CloneUtil.convertArrayObjects(pvo.goods, BoughtGoodsVO);
						pvo.staffes=CloneUtil.convertArrayObjects(pvo.staffes, StaffVO);
						pvo.saleStrategies=CloneUtil.convertArrayObjects(pvo.saleStrategies, SaleStrategyVO);
						pvo.shop=CloneUtil.convertObject(pvo.shop, ShopVO);
						pvo.user=CloneUtil.convertObject(pvo.user, UserVO);
						player1=CloneUtil.convertObject(pvo, PlayerVO);
					}
					var fr:String=SO.i.getKV('fightRoom') as String;
					if (!fr)
						fr='FIGHT';
					connect(fr);
					dispatchEvent(new Event(GAME_CONFIG_GOT));
				}
				else
					alert('获取游戏配置失败');
				delete callingDic[s];
			}, {type: BrowserUtil.getQuery() && BrowserUtil.getQuery().t ? BrowserUtil.getQuery().t : 2});
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

		public var boughtGoods:Array;

		public function removeGoods(goods:GoodsVO):void
		{
			dispatchEvent(new ODataEvent(goods, 'removeGoods'));
		}

		public function remoteSaleStrategy(vo:SaleStrategyVO):void
		{
			dispatchEvent(new ODataEvent(vo, 'removeSS'));
		}

		public function addSaleStrategy(vo:SaleStrategyVO):void
		{

		}

		public function selectGoods(goods:GoodsVO):void
		{
			dispatchEvent(new ODataEvent(goods, 'selectedGoods'));
		}

		private var selectedShop:ShopVO;

		public function selectShop(shop:Object):void
		{
			dispatchEvent(new ODataEvent(shop, 'selectdShop'));
			selectedShop=CloneUtil.convertObject(shop, ShopVO);
		}

		private var staffs:Dictionary=new Dictionary();

		public function selectStaff(staff:StaffVO):void
		{
			staffs[staff.type]=staff;
			dispatchEvent(new ODataEvent(staff, 'selectedStaff'));
		}

		public function isSeletected(staff:StaffVO):Boolean
		{
			if (staffs[staff.type] && staffs[staff.type].level == staff.level)
				return true;
			return false;
		}

		protected function addUserHandler(event:PomeloEvent):void
		{
			trace('onAdded', event.message.user);
			other=new UserVO();
			other.company_name=event.message.user;
			startGame();
		}

		private var pomelo:Pomelo;

		public static function get instance():ServiceController
		{
			return Singleton.getInstance(ServiceController);
		}

		/**
		 * 定位到某个建筑，传参ID
		 */
		public var navigateTo:Function;

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
		private var goodsValue:int;

		public function selectShopComplete():void
		{
			player1.shop=selectedShop;
		}

		/**
		 * 总资产
		 */
		public function totalAssets():int
		{
			caculate();
			return player1.cash + goodsValue;
		}

		private function caculate():void
		{
			var total:int;
			for each (var vo:BoughtGoodsVO in boughtGoods)
			{
				total+=vo.inPrice * vo.quantity;
			}
			goodsValue=int(total / 2);
		}

		public var boughtGoodsDic:Dictionary;

		/**
		 * 购物车结算
		 * @param goods 购物车里的物品列表
		 * @param total 购物车总价格
		 */
		public function checkOut(goods:Array, total:Number):void
		{
			player1.cash-=total;
			if (!boughtGoods)
			{
				boughtGoods=goods;
			}
			else
			{
				for each (var bg:BoughtGoodsVO in goods)
				{
					var has:Boolean;
					for each (var bg2:BoughtGoodsVO in boughtGoods)
					{
						if (bg2.id == bg.id)
						{
							bg2.quantity+=bg.quantity;
							has=true;
							break;
						}
					}
					if (!has)
						boughtGoods.push(bg);
				}
			}
		}

		public function getBoughtGoodsDic():Dictionary
		{
			boughtGoodsDic=new Dictionary();
			for (var i:int; i < boughtGoods.length; i++)
			{
				var vo:GoodsVO=boughtGoods[i] as BoughtGoodsVO;
				var arr:Array=boughtGoodsDic[vo.type];
				if (!arr)
				{
					arr=[];
					boughtGoodsDic[vo.type]=arr;
				}
				arr.push(CloneUtil.convertObject(vo, BoughtGoodsVO));
			}
			return boughtGoodsDic;
		}

		public function readyToStart():ResultVO
		{
			var k:String;
			var v:Object;
			var err:String;
			var temp:Array=[];

			var arr:Array=[];
			for each (var vo:StaffVO in staffs)
			{
				temp.push(vo.type);
				arr.push(vo);
			}
			if (arr.length != 3)
			{
				if (temp.indexOf(1) == -1)
					err='您尚未签约采购员';
				else if (temp.indexOf(2) == -1)
					err='您尚未签约收银员';
				else
					err='您尚未签约理货员';
				return new ResultVO(false, err);
			}
			else
			{
				player1.staffes=arr;
			}

			if (!boughtGoods || boughtGoods.length == 0)
				return new ResultVO(false, '您尚未采购物品');
			else
				player1.goods=boughtGoods;

			if (saleStrategies)
				player1.saleStrategies=saleStrategies;

			pomelo.request(readyRoute, {user: me.company_name, rid: rid}, function(result:Boolean):void
			{
				trace('is ready', result);
			});

			return new ResultVO(true);
		}

		public function cancelReady(callback:Function):void
		{
			pomelo.request(cancelReadyRoute, {user: me.company_name, rid: rid}, callback);
		}
	}
}
