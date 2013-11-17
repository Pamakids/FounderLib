package global
{
	import flash.utils.Dictionary;
	
	
	/**
	 * 销售计划管理器
	 * @author Administrator
	 */	
	public class PlansManager
	{
		private static var _instance:PlansManager;
		public static function getInstance():PlansManager
		{
			if(!_instance)
				_instance = new PlansManager();
			return _instance;
		}
		
		public function PlansManager()
		{
			initDefaultPlan();
		}
		
		/**
		 * 销售计划列表
		 */		
		private var plans:Vector.<Dictionary>;
		private function initDefaultPlan():void
		{
			plans = new Vector.<Dictionary>();
			
			var xml:XML;
			var id:String;
			var dic:Dictionary = new Dictionary();
			var xl:XMLList = DC.instance().propXML.children();
			for(var i:int = xl.length()-1;i>=0;i--)
			{
				xml = xl[i];
				id = xml.name().toString().split("_")[1];
				dic[id] = uint(xml.toString().split("●")[1]);
			}
			plans.push( dic );
		}
		
		private var crtPlan:uint = 0;
		public function setCrtPlanIndex(i:uint):void
		{
			crtPlan = i;
		}
		
		public function creatNewPlan():void
		{
			var dic:Dictionary = new Dictionary();
			var def:Dictionary = plans[0];
			for(var obj:Object in def)
			{
				dic[obj] = def[obj];
			}
			plans.push( dic );
		}
		
		public function getPriceByID(propID:String):Number
		{
			return plans[crtPlan][propID];
		}
		
		public function setPriceByID(planIndex:uint, propID:String, price:Number):void
		{
			if(planIndex == 0)	return;
			plans[planIndex][propID] = price;
		}
		
		public function setPriceBatch(planIndex:uint, dic:Dictionary):void
		{
			if(planIndex == 0)	return;
			var plan:Dictionary = plans[planIndex];
			for(var obj:Object in dic)
			{
				if(plan[obj])
					plan[obj] = dic[obj];
			}
		}
		
		public function delPlan(planIndex:uint):void
		{
			if(planIndex == 0)	return;
			if(crtPlan == planIndex)	crtPlan = 0;
			plans.splice(planIndex, 1);
		}
	}
}