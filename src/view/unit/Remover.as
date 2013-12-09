package view.unit
{
	import com.astar.expand.ItemTile;
	import com.pamakids.manager.SoundManager;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.utils.getTimer;

	import global.AssetsManager;
	import global.DC;
	import global.ShelfManager;
	import global.StatusManager;
	import global.StoreManager;

	import model.StaffVO;

	import view.component.LogicalMap;
	import view.component.Pop;
	import view.unit.w.Walker;

	/**
	 * 理货员
	 * @author Administrator
	 */
	public class Remover extends Walker
	{
		/**
		 * 是否空闲
		 */
		public var isFree:Boolean=true;
		private var vo:StaffVO;

		public function Remover(vo:StaffVO)
		{
			super();
			this.vo=vo;
			init();
		}

		private function init():void
		{
			initAction();
			initProbar();

			begin=AssetsManager.instance().getSounds("sound_removerStart");
			end=AssetsManager.instance().getSounds("sound_removerEnd");
			failed=AssetsManager.instance().getSounds("sound_shelfIsFull");
		}

		private var probar:MovieClip;

		private function initProbar():void
		{
			probar=AssetsManager.instance().getResByName("probar") as MovieClip;
			this.addChild(probar);
			probar.y=-action.height - 10;
			probar.gotoAndStop(1);
			probar.visible=false;
		}

		override public function get SPEED():uint
		{
			return 8;
		}

		private var pops:Array;
		private var popPoint:Point;

		override protected function onArrived(e:Event):void
		{
			popPoint=new Point(0, -action.height - 10);
			popPoint=this.localToGlobal(popPoint);
			var txt:String;
			var obj:Object=targetShelf.needResplenish();
			pops=obj.pop;
			switch (obj.reason)
			{
				case -1: //货架未启用
					SoundManager.instance.play(failed);
					ShelfManager.getInstance().delFromWait(targetShelf);
					isFree=true;
					break;
				case 0: //货架已满
					txt="货架是满的";
					Pop.show(Pop.POPID_ALERT, txt, stage, popPoint);
					SoundManager.instance.play(failed);
					ShelfManager.getInstance().delFromWait(targetShelf);
					isFree=true;
					break;
				case 1: //库存不足，提示不足信息
					txt="";
					for (var i:int=0; i < pops.length; i++)
					{
						txt+=DC.instance().getPropNameByID(pops[i]);
						if (i < pops.length - 1)
							txt+=",";
					}
					txt+="  库存不足！";
					Pop.show(Pop.POPID_ALERT, txt, stage, popPoint);
					SoundManager.instance.play(failed);
					ShelfManager.getInstance().delFromWait(targetShelf);
					isFree=true;
					pops=null;
					break;
				case 2: //需要补货，补货完成后提示不足信息
					SoundManager.instance.play(begin);
					replenishHandler();
					break;
			}
		}

		private var targetShelf:Shelf;

		private var begin:Sound;
		private var end:Sound;
		private var failed:Sound;

		private function replenishHandler():void
		{
			probar.visible=true;
			probar.gotoAndStop(1);
			action.gotoAndStop(ACTION_STAY_UP);

			start=getTimer();
			StatusManager.getInstance().addFunc(onTimer, 0.05);
		}

		private function onTimer():void
		{
			var time:uint=getTimer();
			var i:int=Math.floor(Math.min((time - start) / (vo.ability * 1000), 1) * 100);
			probar.gotoAndStop(i);
			if (time - start >= vo.ability * 1000)
			{
				StatusManager.getInstance().delFunc(onTimer);
				probar.gotoAndStop(1);
				probar.visible=false;
				action.gotoAndStop(ACTION_STAY_DOWN);
				targetShelf.resplenish();
				targetShelf=null;
				isFree=true;

				SoundManager.instance.play(end);

				var txt:String="补货完成！";
				if (pops && pops.length > 0)
				{
					txt+="其中： ";
					for (var j:int=0; j < pops.length; j++)
					{
						txt+=DC.instance().getPropNameByID(pops[j]);
						if (j < pops.length - 1)
							txt+=",";
					}
					txt+=" 库存不足！";
				}
				Pop.show(Pop.POPID_ALERT, txt, stage, popPoint);
			}
		}
		private var start:uint;

		private function initAction():void
		{
			action=AssetsManager.instance().getResByName("remover") as MovieClip;
			this.addChild(action);
			action.gotoAndStop(ACTION_STAY_LEFT);
			action.mouseEnabled=action.mouseChildren=false;
			action.scaleX=action.scaleY=.5;
		}

		/**
		 * 补货
		 * @param param0
		 */
		public function replenish(shelf:Shelf):void
		{
			isFree=false;
			targetShelf=shelf;
			var tile:ItemTile=targetShelf.getTargetTile();
			if (tile == crtTile)
				replenishHandler();
			else
				LogicalMap.getInstance().moveBody(this, tile);
		}

		override public function dispose():void
		{
			StatusManager.getInstance().delFunc(onTimer);
			vo=null;
			this.removeChild(probar);
			probar=null;
			this.removeChild(action);
			action=null;
			super.dispose();
		}

		public function getAbility():Number
		{
			return vo.ability;
		}
	}
}
