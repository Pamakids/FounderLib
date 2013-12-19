package controller
{
	import com.pamakids.events.ODataEvent;
	import com.pamakids.manager.LoadManager;
	import com.pamakids.manager.SoundManager;
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
	import model.EventsVO;
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
		public static const ENTERED:String="ENTERED";
		public static const GAME_CONFIG_GOT:String="GAME_CONFIG_GOT";

		public static const GAME_PAUSE:String="GAME_PAUSE";
		public static const GAME_START:String="GAME_START";
		public static const GET_DEFAULT_CONFIG:String="gc/default";
		public static const SINGED_IN:String="SINGED_IN";
		public static const USER_CANCEL_READY:String="USER_CANCEL_READY";

		public static const USER_READY:String="USER_READY";

		public static const USER_SIGN_IN:String="user/signIn";

		/**
		 * 当前回合盈利
		 */
		public function get earned():int
		{
			return _earned;
		}

		/**
		 * @private
		 */
		public function set earned(value:int):void
		{
			_earned=value;
			trace('Earned: ' + value);
			if (value)
				dispatchEvent(new Event('moneyChanged'));
		}

		public static function get instance():ServiceController
		{
			return Singleton.getInstance(ServiceController);
		}

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
			type=int(SO.i.getKV('t'));
			isSingle=type == 1;
		}

		/**
		 * ShpperVO
		 */
		public var addShopper:Function;

		public var boughtGoods:Array;

		public var boughtGoodsDic:Dictionary;

		/**
		 * 游戏配置
		 */
		public var config:GameConfigVO;

		public var currentSaleStrategy:SaleStrategyVO;

		public var fighting:Boolean;

		public var gameResult:String;

		[Bindable]
		public var gameTime:String;

		public var goods:Array;

		public var goodsDic:Dictionary;

		public var http:String;

		public var isDebug:Boolean;

		public var isReading:Boolean;

		public var isSingle:Boolean

		public var me:UserVO;

		/**
		 * 定位到某个建筑，传参ID
		 */
		public var navigateTo:Function;
		public var other:UserVO;

		[Bindable]
		public var otherCash:Number=0;
		/**
		 * 自己
		 */
		[Bindable]
		public var player1:PlayerVO;

		/**
		 * 对手
		 */
		public var player2:PlayerVO;

		public var purchaseNumEachRound:int;

		public var roundNum:int=1;

		public var saleStrategies:Array;

		public var showReadyBox:Function;
		public var socket:String;

		public var users:Array=[];
		private var callingDic:Dictionary;
		private var cancelReadyRoute:String='connector.entryHandler.cancelReady';
		private var enter:String='connector.entryHandler.enter';

		private var gameTimer:Timer;
		private var goodsValue:int;
		private var messageTimer:Timer;
		private var otherSO:SaleStrategyVO;

		private var pomelo:Pomelo;

		private var queryEntry:String="gate.gateHandler.queryEntry";
		private var readyRoute:String='connector.entryHandler.ready';

		/**
		 * 房间ID
		 */
		private var rid:String;

		private var selectedShop:ShopVO;
		private var sendGameMessage:String='chat.chatHandler.sendGameInfo';

		private var serviceDic:Dictionary;

		private var shopperTimer:Timer;

		private var staffs:Dictionary=new Dictionary();

		private var type:int;

		public function addSaleStrategy(vo:SaleStrategyVO):void
		{

		}

		public function call(href:String, callback:Function, data:Object, method:String='POST'):void
		{
			getService(href, method).call(callback, data);
		}

		public function cancelReady(callback:Function):void
		{
			pomelo.request(cancelReadyRoute, {user: me.company_name, rid: rid}, callback);
		}

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
				boughtGoods=CloneUtil.cloneArray(goods);
			}
			else
			{
				for each (var bg:BoughtGoodsVO in goods)
				{
					var has:Boolean=false;
					for each (var bg2:BoughtGoodsVO in boughtGoods)
					{
						if (bg2.id == bg.id && bg.quantity)
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

			dispatchEvent(new Event('moneyChanged'));
			if (fighting)
				return;

			showHelp('采购完成后您可以去设置销售方案了\n您也可以继续采购或者去银行贷款再去采购更多的物品\n或者直接点击“准备好了”开始游戏');
		}

		public var showHelp:Function;

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
											trace('User:' + o);
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

		public function getGoods(id:String):Sprite
		{
			var c:Class=getDefinitionByName('sprite_' + id) as Class;
			return new c;
		}

		public function gotoFighting():void
		{
			SO.i.setKV('player' + me.company_name, player1);
			if (!isSingle)
				SO.i.setKV('fightRoom', users[0].user + 'vs' + users[1].user);
			navigateToURL(new URLRequest(http + 'FounderFighting.html'), '_self');
		}

		public function init():void
		{
			LoadManager.instance.loadSWF('goods/assets.swf', loadedSWFHandler);
		}

		public function isSeletected(staff:StaffVO):Boolean
		{
			if (staffs[staff.type] && staffs[staff.type].level == staff.level)
				return true;
			return false;
		}

		private var recordCash:int;

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
			if (messageTimer)
				messageTimer.stop();
			gameTimer.stop();
			shopperTimer.stop();

			StatusManager.getInstance().quitGame(function():void
			{
				sm.stopAll();

				clearEmptyProduct();

				recordCash=player1.cash;
				if (!isSingle)
					gameTime='第' + roundNum + '月';
				else
					gameTime='第' + roundNum + '关';

				var confirmInfo:String='';
				var infoArr:Array=player1.payRentAndSalary();
				var payForLoan:int=int(player1.loan * config.loanRate / 100);
				if (payForLoan)
				{
					confirmInfo='扣除支付所贷 ' + player1.loan + ' 款项利息 ' + payForLoan;
					infoArr.push(confirmInfo);
					player1.cash-=payForLoan;
				}

				dispatchEvent(new Event('moneyChanged'));
				infoArr.push('销售物品共赚得： ' + earned);
				infoArr.push('');
				var allEarned:int=earned - Math.abs((recordCash - player1.cash));
				infoArr.push('净盈利： ' + allEarned);
				infoArr.push('');
				confirmedCallback=function():void
				{
					if (!isSingle)
					{
						roundNum++;
						earned=0;
						if (other)
						{
							var sendData:Object={target: other.company_name, data: player1.money};
							pomelo.request(sendGameMessage, sendData);
						}
						readyToRandom=true;
						judgeGameStatus();
					}
					else
					{
						var s:ServiceBase=new ServiceBase('user/update', URLRequestMethod.POST);
						var sl:int=singleModeTarget > allEarned ? roundNum : roundNum + 1;
						var data:Object={_id: me._id, single_level: sl, single_cash: player1.cash, single_loan: player1.loan};
						var bga:Array=[];
						for each (var bgo:Object in boughtGoods)
						{
							var o:Object={};
							CloneUtil.copyValue(bgo, o, true);
							bga.push(o);
						}
						data.boughtGoods=JSON.stringify(bga);
						if (player1.getProperty() < config.startupMoney)
						{
							data.single_cash=config.startupMoney;
							data.single_loan=0;
							data.boughtGoods='';
							player1.cash=config.startupMoney;
							player1.loan=0;
							player1.goods=null;
						}
						s.call(function(vo:ResultVO):void
						{
							earned=0;
							if (vo.status)
							{
								me=CloneUtil.convertObject(vo.results, UserVO);
								SO.i.setKV('user', me);
								SO.i.setKV('player' + me.company_name, player1);
								if (isDebug && roundNum < 4)
								{
									showRandomEvent();
									return;
								}
								if (singleModeTarget > allEarned)
									dispatchEvent(new Event('singleFailed'));
								else
									showRandomEvent();
							}
							else
							{
								alert('抱歉，单机闯关记录保存失败，请稍后再试，5秒后自动返回首页');
								setTimeout(function():void
								{
									backToHome();
								}, 5000);
							}
						}, data);
					}
					recordCash=player1.cash;
					dispatchEvent(new Event(GAME_PAUSE));
				};
				confirm(infoArr.join('\n'));
			});
		}

		private function clearEmptyProduct():void
		{
			for each (var bvo:BoughtGoodsVO in boughtGoods)
			{
				if (!bvo.quantity)
					boughtGoods.splice(boughtGoods.indexOf(bvo, 1));
			}
		}

		public function backToHome():void
		{
			var so:SO=SO.i;
			var uinfo:String='u=' + so.getKV('u') + '&p=' + so.getKV('p');
			navigateToURL(new URLRequest(http + 'FounderTraining.html?' + encodeURI(uinfo)), '_self');
		}

		public function clearProduct(id:String):void
		{
			if (!boughtGoods)
				return;
			var n:int;
			for each (var vo:BoughtGoodsVO in boughtGoods)
			{
				if (vo.id == id)
				{
					player1.cash+=vo.quantity * vo.inPrice;
					boughtGoods.splice(boughtGoods.indexOf(vo), 1);
					dispatchEvent(new Event(CLEAR_PRODUCT));
					dispatchEvent(new Event('moneyChanged'));
					break;
				}
			}
		}

		public static const CLEAR_PRODUCT:String="CLEAR_PRODUCT";

		public function getBoughtGoodsNum(id:String):int
		{
			if (!boughtGoods)
				return 0;
			var n:int;
			for each (var vo:BoughtGoodsVO in boughtGoods)
			{
				if (vo.id == id)
					return vo.quantity;
			}
			return 0;
		}

		private var readyToRandom:Boolean;

		private function judgeGameStatus():void
		{
			if (player1.money < 0 || player2.money < 0)
			{
				if (player2.money < 0)
				{
					if (player1.money > player2.money)
						gameOver(new GameResult(true, '恭喜您，获得了胜利， ' + other.company_name + ' 剩余资金：' + player2.money + ' 已经破产啦\n5秒后将自动返回游戏大厅'));
					else
						gameOver(new GameResult(false, '很遗憾，您已破产，' + other.company_name + ' 获得了胜利\n5秒后将自动返回游戏大厅'));
				}
				else
				{
					gameOver(new GameResult(false, '很遗憾，您已破产，' + other.company_name + ' 获得了胜利\n5秒后将自动返回游戏大厅'));
				}
			}
			else if (readyToRandom)
			{
				showRandomEvent();
			}
			else if (readyToCompareCash && roundNum > config.getMaxRound())
			{
				var vc:int=player1.cash - player2.cash;
				if (vc > 0)
					gameOver(new GameResult(true, '受系统设置的最大对战回合限制，游戏结束\n恭喜您，以超出 ' + other.company_name + ' 现金 ' + vc + ' 的优势获得最终胜利\n5秒后将自动返回游戏大厅'));
				else
					gameOver(new GameResult(false, '受系统设置的最大对战回合限制，游戏结束\n很遗憾，您因现金比' + other.company_name + ' 少 ' + Math.abs(vc) + ' 而惜败，请再接再厉\n5秒后将自动返回游戏大厅'));
			}
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

			if (!isSingle)
				pomelo.request(readyRoute, {user: me.company_name, rid: rid}, function(result:Boolean):void
				{
					trace('is ready', result);
				});
			else if (fighting)
				startGame();

			return new ResultVO(true);
		}

		public function remoteSaleStrategy(vo:SaleStrategyVO):void
		{
			dispatchEvent(new ODataEvent(vo, 'removeSS'));
		}

		public function removeGoods(goods:GoodsVO):void
		{
			dispatchEvent(new ODataEvent(goods, 'removeGoods'));
		}

		public function selectGoods(goods:GoodsVO):void
		{
			dispatchEvent(new ODataEvent(goods, 'selectedGoods'));
		}

		public function selectShop(shop:Object):void
		{
			dispatchEvent(new ODataEvent(shop, 'selectdShop'));
			selectedShop=CloneUtil.convertObject(shop, ShopVO);
		}

		public function selectShopComplete():void
		{
			player1.shop=selectedShop;
		}

		/**
		 * 已选择采购员
		 */
		public var selectedPurchaser:Boolean;

		public var selectedPurchaserStaff:StaffVO;

		public var hintToPurchase:Boolean;

		public function selectStaff(staff:StaffVO):void
		{
			if (staff.type == 1)
			{
				selectedPurchaser=true;
				selectedPurchaserStaff=staff;
			}

			staffs[staff.type]=staff;
			var arr:Array=[];

			dispatchEvent(new ODataEvent(staff, 'selectedStaff'));

			if (fighting)
				return;
			for each (var vo:StaffVO in staffs)
			{
				arr.push(vo);
			}

			if (arr.length == 3 && !hintToPurchase)
			{
				hintToPurchase=true;
				showHelp('人员招聘完毕，快去批发市场采购东西吧');
				confirmedCallback=function():void
				{
					dispatchEvent(new Event('toPurchase'));
				};
				confirm('人员招聘完毕，快去批发市场采购东西吧');
			}
		}

		private var _earned:int;

		/**
		 * 开始游戏，自动计时，同步现金数
		 */
		public function startGame():void
		{
			readyToRandom=false;
			if (fighting)
			{
				if (!isSingle)
				{
					messageTimer.reset();
					messageTimer.start();
				}

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
				sm.play('bg1');
			}
			else
			{
				var infos:Array=[];
				if (isSingle)
				{
					if (roundNum != 1)
					{
						var s:ServiceBase=getService('user/ranking', 'get');
						s.call(function(vo:ResultVO):void
						{
							infos.push('恭喜您，已经闯到第 ' + me.single_level + ' 关');
							infos.push('当前排名第 ' + vo.results + ' 请再接再厉');
							infos.push('');
							infos.push('本关过关条件需盈利：' + singleModeTarget + ' 祝您好运！');
							infos.push('');
							confirm(infos.join('\n'));
						});
					}
					else
					{
						infos.push('欢迎单枪匹马挑战创业实战单机模式\n本关过关条件需盈利：' + singleModeTarget + ' 祝您好运！');
						confirm(infos.join('\n'));
					}
				}
				dispatchEvent(new Event(ENTERED));
				sm.play('bg0');
			}
			if (isSingle && fighting)
			{
				var payForLoan:int=int(player1.loan * config.loanRate / 100);
				otherCash=singleModeTarget + player1.getAllNeedPay() + payForLoan;
			}
		}

		/**
		 * 总资产
		 */
		public function totalAssets():int
		{
			caculate();
			return player1.cash + goodsValue - player1.loan;
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

		private var shopperTypes:Array=[];

		private function getShopperType():int
		{
			if (!shopperTypes.length)
				shopperTypes=[0, 1, 2];
			var ti:int=Math.floor(Math.random() * shopperTypes.length);
			var type:uint=shopperTypes[ti];
			shopperTypes.splice(ti, 1)
			return type;
		}

		protected function addShopperHandler(event:TimerEvent):void
		{
			trace('st', shopperTypes.length);
			var type:int=getShopperType();
			var r:Number=Math.random();
			var num:int=toBuyGoodsNum;
			var buyTwo:Boolean=r > 0.5;
			var toBuy:Array;
			var index:int=Math.floor(MathUtil.getRandomBetween(0, goods.length));
			var gvo:GoodsVO=goods[index];
			var ids:Array=[];
			var currentPrice:int;
			var defaultPrice:int;
			currentPrice=getCurrentPrice(gvo.id, currentSaleStrategy);
			defaultPrice=getDefaultPrice(gvo.id);
			toBuy=[[gvo.id, num, getCurrentPrice(gvo.id, currentSaleStrategy), false]];
			if (buyTwo)
			{
				var index2:int;
				do
				{
					index2=Math.floor(MathUtil.getRandomBetween(0, goods.length));
				} while (index2 == index);
				num=toBuyGoodsNum;
				gvo=goods[index2];
				currentPrice=getCurrentPrice(gvo.id, currentSaleStrategy);
				defaultPrice=getDefaultPrice(gvo.id);
				toBuy.push([gvo.id, num, currentPrice, false]);
			}

			var player1Have:Boolean=allHave(toBuy, player1.goods);

			if (isSingle)
			{
				if (player1Have)
				{
					var p2:Number=currentPrice / defaultPrice; //售价超出的倍数，倍数越高就会降低用户进入的几率
					var max:int=config.goodsSaleMax / 100;

					var p3:Number=(p2 - 1) / max;

//					trace('SinglePrice Ratio:', p3, p2, currentPrice, defaultPrice);
//
//					for each (var oo:Array in toBuy)
//					{
//						trace('to buy:', oo[1], oo[0]);
//					}
					trace('Add Ratio: ', (player1.shop.visit / 100) * (1 - p3));
					r=Math.random();
					if (r < (player1.shop.visit / 100) * (1 - p3))
					{
						addShopper(new ShopperVO(type, toBuy));
					}
				}
			}
			else
			{

				if (player1Have && player2)
				{
					if (allHave(toBuy, player2.goods))
					{
						var a1:Number=player1.shop.visit / (player1.shop.visit + player2.shop.visit);
						var ap1:int=getAllPrice(toBuy, currentSaleStrategy);
						var ap2:int=getAllPrice(toBuy, otherSO);
						var a2:Number=ap2 / (ap1 + ap2);
						var aa:Number=(a1 + a2) / 2;
						r=Math.random();
						if (r < aa)
						{
							addShopper(new ShopperVO(type, toBuy));
						}
						else
						{
							trace('add other shopper');
							var sendData:Object={target: other.company_name, data: player1.cash, toBuy: JSON.stringify(toBuy)};
							pomelo.request(sendGameMessage, sendData);
						}
					}
					else
					{
						addShopper(new ShopperVO(type, toBuy));
					}
				}
			}
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

		protected function onGameHandler(event:PomeloEvent):void
		{
			trace('On Game');
			var msg:Object=event.message;
			if (msg.player)
				player2=getPlayer(msg.player);
			if (msg.svo)
				otherSO=CloneUtil.convertObject(msg.svo, SaleStrategyVO);
			otherCash=Number(msg.data);

			if (msg.target == me.company_name && msg.toBuy)
			{
				var arr:Array=JSON.parse(msg.toBuy) as Array;
				var player1Have:Boolean=allHave(arr, player1.goods);
				if (player1Have)
				{
					addShopper(new ShopperVO(getShopperType(), arr));
					trace('Shopper from other one');
				}
			}

			dispatchEvent(new Event('moneyChanged'));

			judgeGameStatus();
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

		protected function removeUserHandler(event:PomeloEvent):void
		{
//			if (isReading)
//				return;
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

		protected function roundComplete(event:TimerEvent):void
		{
			pauseGame();
		}

		protected function sendGameMessageHandler(event:TimerEvent):void
		{
			if (!other)
				return;
			var sendData:Object={target: other.company_name, data: player1.money, player: player1, svo: currentSaleStrategy};
			pomelo.request(sendGameMessage, sendData);
		}

		private function alert(text:String):void
		{
			dispatchEvent(new ODataEvent(text, 'alert'));
		}

		public var confirmedCallback:Function;
		private var sm:SoundManager;

		private function confirm(text:String):void
		{
			dispatchEvent(new ODataEvent(text, 'confirm'));
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

		private function caculate():void
		{
			var total:int;
			for each (var vo:BoughtGoodsVO in boughtGoods)
			{
				total+=vo.inPrice * vo.quantity;
			}
			goodsValue=int(total / 2);
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

		private function getAllPrice(toBuy:Array, svo:SaleStrategyVO):int
		{
			var p:int=0;
			for each (var arr:Array in toBuy)
			{
				p+=getCurrentPrice(arr[0], svo);
			}
			return p;
		}

		public function getDefaultPrice(id:String):int
		{
			var p:int;
			for each (var gvo:GoodsVO in goods)
			{
				if (gvo.id == id)
				{
					p=gvo.outPrice;
					break;
				}
			}
			return p;
		}

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
			if (!p)
			{
				for each (var o:Object in goods)
				{
					if (o.id == id)
					{
						p=o.outPrice;
						break;
					}
				}
			}
			return p;
		}

		private function getDefaultConfig():void
		{
			ServiceBase.id=me._id;
			var s:ServiceBase=getService(GET_DEFAULT_CONFIG, URLRequestMethod.GET);
			if (callingDic[s])
				return;
			callingDic[s]=true;
			s.call(function(result:ResultVO):void
			{
				if (result.status)
				{
					config=CloneUtil.convertObject(result.results, GameConfigVO);
					if (isDebug)
						config.roundTime=30;

					if (isSingle)
						roundNum=me.single_level ? me.single_level : 1;

					var pvo:Object=SO.i.getKV('player' + me.company_name);
					if (!pvo)
					{
						initPlayer1();
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
					initTimers();
					if (isSingle)
					{
						if (!fighting)
						{
							if (me.boughtGoods)
							{
								boughtGoods=CloneUtil.convertArrayObjects(JSON.parse(me.boughtGoods) as Array, BoughtGoodsVO);
								player1.goods=boughtGoods;
							}
							if (player1.getProperty() < config.startupMoney)
							{
								player1.cash=config.startupMoney;
								player1.goods=null;
								player1.loan=0;
							}
						}
						startGame();
					}
					else
					{
						var fr:String=SO.i.getKV('fightRoom') as String;
						if (!fr || isDebug)
							fr='FIGHT';
						connect(fr);
					}
					dispatchEvent(new Event(GAME_CONFIG_GOT));
				}
				else
					alert('获取游戏配置失败');
				delete callingDic[s];
			}, {type: type ? type : 2});
		}

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


		private function getService(uri:String, method:String):ServiceBase
		{
			var s:ServiceBase=serviceDic[uri];
			if (!s)
				s=new ServiceBase(uri, method);
			return s;
		}

		private function gotoRoom():void
		{
			navigateToURL(new URLRequest(http + '/FounderRoom.html'), '_self');
		}

		private function hasGoods(id:String, num:int, arr:Array):Boolean
		{
			for each (var vo:BoughtGoodsVO in arr)
			{
				if (vo.id == id)
				{
					return true;
				}
			}
			return false;
		}

		private function initPlayer1():void
		{
			player1=new PlayerVO();
			if (!isSingle || roundNum == 1)
			{
				player1.cash=config.startupMoney;
			}
			else
			{
				player1.cash=me.single_cash;
				player1.loan=me.single_loan;
			}
			player1.user=me;
		}

		private function initTimers():void
		{
			shopperTimer=new Timer(config.getClientInTime() * 1000);
			shopperTimer.addEventListener(TimerEvent.TIMER, addShopperHandler);

			if (!isSingle)
			{
				messageTimer=new Timer(5000)
				messageTimer.addEventListener(TimerEvent.TIMER, sendGameMessageHandler);
			}

			gameTimer=new Timer(1000, config.roundTime);
			gameTimer.addEventListener(TimerEvent.TIMER, playGameing);
			gameTimer.addEventListener(TimerEvent.TIMER_COMPLETE, roundComplete);
		}

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
				if (!fighting)
				{
					if (users.length != 2)
					{
//						alert('另一玩家尚未进入，请等待或返回游戏大厅');
//						isReading=false;
						showReadyBox();
						return;
					}
					gotoFighting();
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
			else
			{
				isReading=false;
			}
		}

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

			sm=SoundManager.instance;
			sm.addSound('bg0', getDefinitionByName('sound_bg_0'), 9999);
			sm.addSound('bg1', getDefinitionByName('sound_bg_1'), 9999);
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
//				if (!isDebug)
//				{
				var uo:Object=SO.i.getKV('user');
				if (uo)
				{
					me=CloneUtil.convertObject(uo, UserVO);
					getDefaultConfig();
					dispatchEvent(new Event(SINGED_IN));
					return;
				}
//				}
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

		private function loadedSWFHandler():void
		{
			LoadManager.instance.loadText('assets/config.json', loadedHandler);
			LoadManager.instance.loadText('goods/data.json', loadGoodsHandler);
		}

		private var readyToCompareCash:Boolean;

		private function showRandomEvent():void
		{
			readyToRandom=false;
			var s:ServiceBase=new ServiceBase('event');
			s.call(function(vo:ResultVO):void
			{
				if (vo.status)
				{
					var evo:EventsVO=CloneUtil.convertObject(vo.results, EventsVO);
					alert(evo.content);
					player1.cash+=evo.money;
					dispatchEvent(new Event('moneyChanged'));
				}
				if (isSingle)
				{
					roundNum++;
				}
				else
				{
					readyToCompareCash=true;
					judgeGameStatus();
					var sendData:Object={target: other.company_name, data: player1.money, player: player1, svo: currentSaleStrategy};
					pomelo.request(sendGameMessage, sendData);
				}
			});
		}

		public function currentRoundPurchaseAbilityRatio():int
		{
			var n:int=1;
			if (isSingle)
				n=n * (1 + roundNum * config.getSingleRatio() / 100);
			return n;
		}

		public function currentRoundMaxGoodsNum():int
		{
			var n:int=config.getClientMaxGoodsNum();
			if (isSingle)
				n=n * (1 + roundNum * config.getSingleRatio() / 100)
//				n=n * Math.pow((1 + config.getSingleRatio() / 100), roundNum - 1);
			return n;
		}

		public function get toBuyGoodsNum():int
		{
			var m:Number=Math.random();
			if (m < 0.2)
				m=0.2;
			return Math.ceil(m * currentRoundMaxGoodsNum());
		}

		public function get singleModeTarget():int
		{
			var n:int=config.getSingleMinRequirement();
			return n * (1 + (roundNum - 1) * config.getSingleRatio() / 100);
		}
	}
}
