package controller
{
	import com.pamakids.components.PAlert;
	import com.pamakids.models.Errors;
	import com.pamakids.models.PageQuery;
	import com.pamakids.models.ResultVO;
	import com.pamakids.services.ServiceBase;
	import com.pamakids.utils.CloneUtil;
	import com.pamakids.utils.Singleton;

	import flash.net.URLRequestMethod;
	import flash.utils.Dictionary;

	import model.AccountVO;
	import model.KeyValueVO;
	import model.TopicVO;
	import model.UserVO;

	public class ASC extends Singleton
	{
		public static const UPLOAD:String="upload";
		public static const USER_UPDATE:String="user/update";
		public static const USER_SIGN_IN:String="user/signIn";
		public static const USER_SIGN_UP:String="user/signUp";
		public static const UPLOADED:String='uploaded';
		public static const ADMIN_SIGN_IN:String="admin/signIn";
		public static const ADMIN_SIGN_UP:String="admin/signUp";
		public static const GET_ADMIN_USERS:String="admin/users";
		public static const GET_USERS:String="user/users";
		public static const ADMIN_UPDATE:String="admin/user/update";
		public static const DELETE_ADMIN:String="admin/user/delete";
		public static const KV_LIST:String="kv/list";
		public static const KV_ADD:String="kv/add";
		public static const KV_UPDATE:String="kv/update";
		public static const ACCOUNT_LIST:String="account/list";
		public static const ACCOUNT_ADD:String="account/add";
		public static const ACCOUNT_UPDATE:String="account/update";
		public static const TOPICS:String="topics";
		public static const TOPIC_ADD:String="topicAdd";
		public static const TOPIC_LIST:String="topicList";
		public static const TOPIC_UPDATE:String="topicUpdate";
		public static const GAME_OVER:String="game/over";
		public static const TOP_USERS:String="/user/top";

		public static function get i():ASC
		{
			return Singleton.getInstance(ASC);
		}

		public function ASC()
		{
			serviceDic=new Dictionary();
			callingDic=new Dictionary();
		}

		public function getTopUsers(callback:Function):void
		{
			var s:ServiceBase=getService(TOP_USERS, URLRequestMethod.GET);
			s.call(function(result:ResultVO):void
			{
				if (result.status)
				{
					callback(CloneUtil.convertArrayObjects(result.results as Array, UserVO));
				}
				else
				{
					alert('获取龙虎榜单失败', result.errorResult);
				}
			});
		}

		public function getTopics(callback:Function, title:String=''):void
		{
			var s:ServiceBase=getService(TOPICS, URLRequestMethod.GET);
			var query:Object;
			if (title)
				query.title=title;
			s.call(function(result:ResultVO):void
			{
				if (result.status)
				{
					var arr:Array=[];
					for each (var o:Object in result.results)
					{
						arr.push(CloneUtil.convertObject(o, TopicVO));
					}
					callback(arr);
				}
				else
				{
					alert('获取题目列表失败', result.errorResult);
				}
			}, new PageQuery(999, 1, query));
		}

		public function getAccounts(callback:Function, type:String=''):void
		{
			var s:ServiceBase=getService(ACCOUNT_LIST, URLRequestMethod.GET);
			var query:Object=type ? {type: type} : null;
			s.call(function(result:ResultVO):void
			{
				if (result.status)
				{
					var arr:Array=[];
					for each (var o:Object in result.results)
					{
						arr.push(CloneUtil.convertObject(o, AccountVO));
					}
					callback(arr);
				}
				else
				{
					alert('获取记账列表失败', result.errCode);
				}

			}, new PageQuery(999, 1, query));
		}

		public function getKV(callback:Function, key:String='', pageNum:int=999):void
		{
			var s:ServiceBase=getService(KV_LIST, URLRequestMethod.GET);
			var query:Object=key ? {key: key} : null;
			s.call(function(result:ResultVO):void
			{
				if (result.status)
				{
					var arr:Array=[];
					for each (var o:Object in result.results)
					{
						arr.push(CloneUtil.convertObject(o, KeyValueVO));
					}
					callback(arr);
				}
				else
				{
					alert('获取键值列表失败', result.errCode);
				}

			}, new PageQuery(pageNum, 1, query));
		}

		private function alert(info:String, code:String=''):void
		{
			if (code)
				info+='\n' + Errors.getMessage(code);
			PAlert.show(info);
		}

		public function userSignUp(account:String, password:String, cname:String, callback:Function):void
		{
			var s:ServiceBase=getService(USER_SIGN_UP, URLRequestMethod.POST);
			if (callingDic[s])
				return;
			var p:Object=SO.i.getKV('pic');
			var o:Object={username: account, password: password, company_name: cname};
			if (p)
				o.portrait=p;
//			if (account.indexOf('@') != -1)
//			{
//				o.email=account;
//			}
//			else if (int(account) && (account.length == 11 || account.length == 8))
//			{
//				o.mobile_phone_num=account;
//			}
//			else
//			{
//				return;
//			}
//			if(!account || !password)
//			{
////				callback(new ResultVO(false, '请输入正确的邮箱或手机号'));
//				alert('您尚未登陆，请登陆后再试');
//				return;
//			}
			var r1:int=account.length * Math.random() | 0;
			var r2:int=password.length * Math.random() | 0;
			o.k=r1 + '' + r2 + account.charAt(r1) + password.charAt(r2);
			callingDic[s]=true;
			s.call(function(result:ResultVO):void
			{
				if (result.status)
					ServiceBase.id=result.results._id;
				callback(result);
				delete callingDic[s];
			}, o);
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
