package controller
{
	import com.pamakids.manager.LoadManager;
	import com.pamakids.models.ResultVO;
	import com.pamakids.services.ServiceBase;
	import com.pamakids.utils.BrowserUtil;
	import com.pamakids.utils.CloneUtil;
	import com.pamakids.utils.Singleton;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	import events.ODataEvent;

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
			pomelo.addEventListener(Event.CLOSE, closeHandler);

			serviceDic=new Dictionary();
			callingDic=new Dictionary();
		}

		public var http:String;
		public var socket:String;

		public function init():void
		{
			LoadManager.instance.loadText('assets/config.json', loadedHandler);
			LoadManager.instance.loadText('goods/data.json', loadGoodsHandler);
			LoadManager.instance.loadSWF('goods/assets.swf');
		}

		public var goodsDic:Dictionary;

		private function loadGoodsHandler(s:String):void
		{
			var data:Object=JSON.parse(s);
			var goods:Array=CloneUtil.convertArrayObjects(data.goods, GoodsVO);
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
			other.company_name=event.message.user.user;
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
	}
}
