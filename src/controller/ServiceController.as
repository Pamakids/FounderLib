package controller
{
	import com.pamakids.events.ODataEvent;
	import com.pamakids.manager.LoadManager;
	import com.pamakids.managers.PopupBoxManager;
	import com.pamakids.models.ResultVO;
	import com.pamakids.services.ServiceBase;
	import com.pamakids.utils.BrowserUtil;
	import com.pamakids.utils.CloneUtil;
	import com.pamakids.utils.MathUtil;
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
	import flash.utils.setTimeout;

	import global.DC;
	import global.StatusManager;

	import model.BoughtGoodsVO;
	import model.GameConfigVO;
	import model.GameResult;
	import model.GoodsVO;
	import model.PlayerVO;
	import model.SaleStrategyVO;
	import model.ShopVO;
	import model.ShopperVO;
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

		[Bindable]
		public var otherCash:Number=0;
		private var otherSO:SaleStrategyVO;

		protected function onGameHandler(event:PomeloEvent):void
		{
			var msg:Object=event.message;
			if (msg.player)
				player2=getPlayer(msg.player);
			if (msg.svo)
				otherSO=CloneUtil.convertObject(msg.svo, SaleStrategyVO);
			otherCash=Number(msg.data);

			dispatchEvent(new Event('moneyChanged'));
		}

		protected function onReadyHandler(event:PomeloEvent):void
		{
			trace('onReady');
			for each (var o:Object in users)
			{
				if (o.user == event.message.user)
				{
					var user:Object=event.message;
					users[users.indexOf(o)]=user;
					dispatchEvent(new ODataEvent(user, USER_READY));
					isBothReady(user);
					break;
				}
			}
		}

		/**
		 * ShpperVO
		 */
		public var addShopper:Function;

		public var showReadyBox:Function;

		private function isBothReady(user:Object):void
		{
			var b:Boolean=true;

			for each (var u:Object in users)
			{
				if (!u.ready)
					b=false;
				else
					isReading=true;
			}

			if (b)
			{
				trace('both ready');
				if (!fighting)
				{
					if (users.length != 2)
					{
//						alert('另一玩家尚未进入，请等待或返回游戏大厅');
//						isReading=false;
						showReadyBox();
						isReading=false;
						return;
					}
					SO.i.setKV('player' + me.company_name, player1);
					SO.i.setKV('fightRoom', users[0].user + 'vs' + users[1].user);
					navigateToURL(new URLRequest(http + '/FounderFighting.html'), '_self');
				}
				else
				{
					startGame();
				}
			}
			else if (user.user == me.company_name && user.ready)
			{
				showReadyBox();
			}
			isReading=false;
		}

		public var http:String;
		public var socket:String;

		public function init():void
		{
			LoadManager.instance.loadSWF('goods/assets.swf', loadedSWFHandler);
		}

		private function loadedSWFHandler():void
		{
			LoadManager.instance.loadText('assets/config.json', loadedHandler);
			LoadManager.instance.loadText('goods/data.json', loadGoodsHandler);
		}

		private var gameTimer:Timer;
		private var messageTimer:Timer;

		public var fighting:Boolean;

		/**
		 * 开始游戏，自动计时，同步现金数
		 */
		public function startGame():void
		{
			if (fighting)
			{
				messageTimer.reset();
				messageTimer.start();

				if (!gameTimer.running)
				{
					gameTimer.reset();
					gameTimer.start();
				}
				if (!shopperTimer.running)
				{
					shopperTimer.reset();
					shopperTimer.start();
				}
				dispatchEvent(new Event(GAME_START));
			}
		}

		[Bindable]
		public var gameTime:String;

		protected function roundComplete(event:TimerEvent):void
		{
			pauseGame();
		}

		protected function playGameing(event:TimerEvent):void
		{
			var s:int=config.roundTime - gameTimer.currentCount;
			var oneDay:int=Math.floor(config.roundTime / 30);
			gameTime='第' + Math.ceil(gameTimer.currentCount * 30 / gameTimer.repeatCount) + '天';
//			var m:int=Math.floor(s / 60);
//			var ms:String;
//			var ss:String;
//			ms=m < 10 ? '0' + m : '' + m;
//			s=s % 60;
//			ss=s < 10 ? '0' + s : '' + s;
//			gameTime=ms + ':' + ss;
		}

		public static const GAME_PAUSE:String="GAME_PAUSE";
		public static const GAME_START:String="GAME_START";

		public var roundNum:int=1;

		/**
		 * 暂停游戏，进入筹备阶段
		 */
		public function pauseGame():void
		{
			for each (var user:Object in users)
			{
				user.ready=false;
			}

			purchaseNumEachRound=0;
			messageTimer.stop();
			gameTimer.stop();
			shopperTimer.stop();
			roundNum++;
			gameTime='第月' + roundNum + '月';

			player1.cash-=player1.loan * config.loanRate / 100;
//			player1.cash-=50000;
			player1.payRentAndSalary();

			if (other)
			{
				var sendData:Object={target: other.company_name, data: player1.money};
				pomelo.request(sendGameMessage, sendData);
			}

			dispatchEvent(new Event('moneyChanged'));

			if (player1.money < 0)
			{
				if (player2.money < 0)
				{
					if (player1.money > player2.money)
					{
						gameOver(new GameResult(true, '您获得了胜利，5秒后将自动返回游戏大厅'));
					}
					else
					{
						gameOver(new GameResult(false, '您失败了，5秒后将自动返回游戏大厅'));
					}
				}
				else
				{
					gameOver(new GameResult(false, '您已经没有现金了，游戏失败，5秒后将自动返回游戏大厅'));
				}
			}

			StatusManager.getInstance().quitGame(function():void
			{
				dispatchEvent(new Event(GAME_PAUSE));
			});
		}

		protected function sendGameMessageHandler(event:TimerEvent):void
		{
			if (!other)
				return;
			var sendData:Object={target: other.company_name, data: player1.money, player: player1, svo: currentSaleStrategy};
			pomelo.request(sendGameMessage, sendData);
		}

		private var queryEntry:String="gate.gateHandler.queryEntry";
		private var enter:String='connector.entryHandler.enter';
		private var readyRoute:String='connector.entryHandler.ready';
		private var cancelReadyRoute:String='connector.entryHandler.cancelReady';
		private var sendGameMessage:String='chat.chatHandler.sendGameInfo';

		public static const USER_READY:String="USER_READY";
		public static const ENTERED:String="ENTERED";
		public static const USER_CANCEL_READY:String="USER_CANCEL_READY";

		public var users:Array=[];

		/**
		 * 房间ID
		 */
		private var rid:String;

		public function connect(room:String):void
		{
			rid=room;
			trace('connect game server', room, socket);
//			alert(room + ' ' + socket + ' ' + me.company_name);
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
							alert(response.message);
							return;
						}
						pomelo.init(socket, response.port, null, function(response:Object):void
						{
							trace(response);
							pomelo.request(enter, {username: me.company_name, rid: room}, function(data:Object):void
							{
								if (data.error)
								{
									alert(data.message);
								}
								else
								{
									users=[];
									for each (var o:String in data.users)
									{
										try
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
											users.push(uo);
										}
										catch (error:Error)
										{
											trace('users error：' + error.message);
										}
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
					alert('游戏服务器连接失败');
				}
			});
		}

		public var goodsDic:Dictionary;

		public var goods:Array;

		private function loadGoodsHandler(s:String):void
		{
			var data:Object=JSON.parse(s);
			goods=CloneUtil.convertArrayObjects(data.goods, GoodsVO);

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
			if (!query || !query.u)
				query={u: 1, p: 1, t: 2};
			if (!query || !query.u || !query.p)
			{
				alert('请先登录后再试');
			}
			else
			{
				if (!isDebug)
				{
					var uo:Object=SO.i.getKV('user');
					if (uo)
					{
						me=CloneUtil.convertObject(uo, UserVO);
						getDefaultConfig();
						dispatchEvent(new Event(SINGED_IN));
						return;
					}
				}
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

		public var purchaseNumEachRound:int;

		/**
		 * 游戏配置
		 */
		public var config:GameConfigVO;
		/**
		 * 自己
		 */
		[Bindable]
		public var player1:PlayerVO;

		/**
		 * 对手
		 */
		public var player2:PlayerVO;

		private function getPlayer(pvo:Object):PlayerVO
		{
			pvo.goods=CloneUtil.convertArrayObjects(pvo.goods, BoughtGoodsVO);
			pvo.staffes=CloneUtil.convertArrayObjects(pvo.staffes, StaffVO);
			for each (var svo:Object in pvo.saleStrategies)
			{
				svo.goods=CloneUtil.convertArrayObjects(svo.goods, BoughtGoodsVO);
			}
			pvo.saleStrategies=CloneUtil.convertArrayObjects(pvo.saleStrategies, SaleStrategyVO);
			pvo.shop=CloneUtil.convertObject(pvo.shop, ShopVO);
			pvo.user=CloneUtil.convertObject(pvo.user, UserVO);
			return CloneUtil.convertObject(pvo, PlayerVO);
		}

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
//					config.roundTime=20;
					var pvo:Object=SO.i.getKV('player' + me.company_name);
					if (!pvo)
					{
						player1=new PlayerVO();
						player1.cash=config.startupMoney;
						player1.user=me;
					}
					else
					{
						player1=getPlayer(pvo);
						boughtGoods=player1.goods;
						for each (var s:StaffVO in player1.staffes)
						{
							staffs[s.type]=s;
						}
						saleStrategies=player1.saleStrategies;
						currentSaleStrategy=saleStrategies[0];
					}
					var fr:String=SO.i.getKV('fightRoom') as String;

					if (!fr || isDebug)
						fr='FIGHT';

					initTimers();
					connect(fr);
					dispatchEvent(new Event(GAME_CONFIG_GOT));
				}
				else
					alert('获取游戏配置失败');
				delete callingDic[s];
			}, {type: BrowserUtil.getQuery() && BrowserUtil.getQuery().t ? BrowserUtil.getQuery().t : 2});
		}

		private function initTimers():void
		{
			messageTimer=new Timer(5000)
			messageTimer.addEventListener(TimerEvent.TIMER, sendGameMessageHandler);

			gameTimer=new Timer(1000, config.roundTime);
			gameTimer.addEventListener(TimerEvent.TIMER, playGameing);
			gameTimer.addEventListener(TimerEvent.TIMER_COMPLETE, roundComplete);

			shopperTimer=new Timer(config.getShopperInTime() * 1000);
			shopperTimer.addEventListener(TimerEvent.TIMER, addShopperHandler);
		}

		public var currentSaleStrategy:SaleStrategyVO;

		private function getCurrentPrice(id:String, svo:SaleStrategyVO):int
		{
			if (!svo)
				return 0;
			var p:int;
			for each (var gvo:Object in svo.goods)
			{
				if (gvo.id == id)
				{
					p=gvo.outPrice;
					break;
				}
			}
			return p;
		}

		private function hasGoods(id:String, num:int, arr:Array):Boolean
		{
			for each (var vo:BoughtGoodsVO in arr)
			{
				if (vo.id == id && vo.quantity > num)
				{
					return true;
				}
			}
			return false;
		}

		protected function addShopperHandler(event:TimerEvent):void
		{
			var r:Number=Math.random();
			var num:int=Math.ceil(Math.random() * 10);
			var buyTwo:Boolean=r > 0.5;
			var toBuy:Array;
			var index:int=Math.floor(MathUtil.getRandomBetween(0, goods.length));
			var gvo:GoodsVO=goods[index];
			var ids:Array=[];
			toBuy=[[gvo.id, num, getCurrentPrice(gvo.id, currentSaleStrategy), false]];
			trace('to buy 1:', gvo.id, gvo.name);
			if (buyTwo)
			{
				var index2:int;
				do
				{
					index2=Math.floor(MathUtil.getRandomBetween(0, goods.length));
				} while (index2 == index);
				num=Math.ceil(Math.random() * 10);
				gvo=goods[index2];
				toBuy.push([gvo.id, num, getCurrentPrice(gvo.id, currentSaleStrategy), false]);
				trace('to buy 2:', gvo.id, gvo.name);
			}

			var player1Have:Boolean=allHave(toBuy, player1.goods);

			trace('user 1 have', player1Have);

			if (player1Have && player2)
			{
				if (allHave(toBuy, player2.goods))
				{
					var a1:Number=player1.shop.visit / (player1.shop.visit + player2.shop.visit);
					var ap1:int=getAllPrice(toBuy, currentSaleStrategy);
					var ap2:int=getAllPrice(toBuy, otherSO);
					var a2:Number=ap1 / (ap1 + ap2);
					var aa:Number=(a1 + a2) / 2;
					r=Math.random();
					trace('all have random', r);
					if (r < aa)
						addShopper(new ShopperVO(0, toBuy));
				}
				else
				{
					addShopper(new ShopperVO(0, toBuy));
				}
			}
		}

		private function getAllPrice(toBuy:Array, svo:SaleStrategyVO):int
		{
			var p:int=0;
			for each (var arr:Array in toBuy)
			{
				p+=getCurrentPrice(arr[0], svo);
			}
			return p;
		}

		private function allHave(toBuy:Array, goods:Array):Boolean
		{
			var hasAll:Boolean=true;
			for each (var arr:Array in toBuy)
			{
				if (!hasGoods(arr[0], arr[1], goods))
				{
					hasAll=false;
					break;
				}
			}
			return hasAll;
		}

		private var shopperTimer:Timer;

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

		public var gameResult:String;

		protected function closeHandler(event:Event):void
		{
			if (isReading)
				return;
			if (fighting)
			{
				gameOver(new GameResult(false, '于服务器的连接已断开，5秒后将自动返回游戏大厅'));
			}
			else
			{
				alert('对方掉线了，5秒后返回游戏大厅');
				setTimeout(gotoRoom, 5000);
			}
		}

		protected function removeUserHandler(event:PomeloEvent):void
		{
			if (isReading)
				return;
			if (fighting)
			{
				gameOver(new GameResult(true, '您赢得了游戏，5秒后将自动返回游戏大厅'));
			}
			else
			{
				alert('对方掉线了，5秒后返回游戏大厅');
				setTimeout(gotoRoom, 5000);
			}
		}

		private function gameOver(vo:GameResult):void
		{
			if (vo.win)
			{
				var s:ServiceBase=new ServiceBase("game/over", 'POST');
				s.call(function(vo:ResultVO):void
				{
					if (!vo.status)
						alert(vo.errorResult);
					setTimeout(gotoRoom, 5000);
				}, {win: me.company_name, lose: other.company_name});
			}
			else
			{
				setTimeout(gotoRoom, 5000);
			}
			alert(vo.info);
			if (messageTimer)
				messageTimer.stop();
		}

		private function gotoRoom():void
		{
			navigateToURL(new URLRequest(http + '/FounderRoom.html'), '_self');
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
			var arr:Array=[];

			dispatchEvent(new ODataEvent(staff, 'selectedStaff'));

			if (fighting)
				return;
			for each (var vo:StaffVO in staffs)
			{
				arr.push(vo);
			}

			if (arr.length == 3)
				Help.instance.showHelp('人员招聘完毕，快去批发市场采购东西吧');
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
			users.push(event.message);
			startGame();
			if (fighting)
			{

			}
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
			return player1.cash + goodsValue - player1.loan;
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

			if (fighting)
				return;

			Help.instance.showHelp('采购完成后您可以去设置销售方案了\n您也可以继续采购或者去银行贷款再去采购更多的物品\n或者直接点击“准备好了”开始游戏');
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
			{
				player1.saleStrategies=saleStrategies;
			}
			else
			{
				var so:SaleStrategyVO=new SaleStrategyVO();
				so.name='默认方案';
				so.goods=boughtGoods;
				player1.saleStrategies=[so];
			}

			isReading=true;

			pomelo.request(readyRoute, {user: me.company_name, rid: rid}, function(result:Boolean):void
			{
				trace('is ready', result);
			});

			return new ResultVO(true);
		}

		public var isReading:Boolean;

		public function cancelReady(callback:Function):void
		{
			pomelo.request(cancelReadyRoute, {user: me.company_name, rid: rid}, callback);
		}
	}
}
