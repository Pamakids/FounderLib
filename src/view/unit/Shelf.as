package view.unit
{
	import com.astar.expand.ItemTile;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import global.AssetsManager;
	import global.DC;
	import global.ShelfManager;
	import global.StoreManager;
	
	import model.ShelfVO;
	
	import view.component.LogicalMap;
	import view.component.Pop;

	public class Shelf extends BasicUnit
	{
		/**
		 * 货架
		 */
		public function Shelf(vo:ShelfVO)
		{
			this.vo=vo;
			super();
			init();
		}

		public var vo:ShelfVO;
		private var type:int;

		private function init():void
		{
			type=int(vo.icon);
			action=AssetsManager.instance().getResByName("shelf_" + vo.icon) as MovieClip;
			this.addChild(action);

			this.addEventListener(MouseEvent.CLICK, onMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseEvent);
			
			popPoint = new Point( action.sprite_0.x +　action.sprite_0.width/2, action.sprite_0.y-10 );
			popPoint = action.localToGlobal(popPoint);
			
			initTf();
		}
		
		private var popPoint:Point;
		
		private var vecTf:Vector.<TextField>;
		private function initTf():void
		{
			var max:int = vo.count;
			vecTf = new Vector.<TextField>(max);
			var sprite:Sprite;
			var tf:TextField;
			for(var i:int = 0;i<max;i++)
			{
				sprite = action["sprite_"+i];
				
				tf = new TextField();
				tf.width = sprite.width;
				tf.multiline = false;
				tf.mouseEnabled = false;
				action.addChild( tf );
				tf.x = sprite.x;
				tf.y = sprite.y + 10;
				tf.defaultTextFormat = new TextFormat(null, 14, 0xffffff, null, null, null, null, null, "center");
				tf.filters = [new GlowFilter(0x0, .8, 2, 2, 100, 1)];
				tf.visible = false;
				vecTf[i] = tf;
			}
		}
		
		protected function onMouseEvent(e:MouseEvent):void
		{
			var i:int = 0;
			var tf:TextField;
			switch(e.type)
			{
				case MouseEvent.MOUSE_OVER:
					for(i = 0;i<props.length;i++)
					{
						tf = vecTf[i];
						tf.visible = true;
						tf.text =DC.instance().getPropNameByID(props[i][0]) + " " + props[i][1];
					}
					break;
				case MouseEvent.MOUSE_OUT:
					for(i=0;i<vo.count;i++)
					{
						tf = vecTf[i];
						tf.visible = false;
					}
					break;
				case MouseEvent.CLICK:
					ShelfManager.getInstance().addToWait(this);
					break;
			}
		}
		

		/**
		 * 摆放物品
		 * @param place		货架层次，从上至下依次为0,1,2
		 * @param propId	物品id
		 * @param num		物品数量
		 */
		public function putInProp(place:int, propId:String, num:uint):void
		{
			var arr:Array;
			arr=props[place];
			var count:uint;
			if (!arr) //货架为空
			{
				count = Math.min( vo.volume, num );
				props[place]=[propId, count];
				StoreManager.getInstance().delPropByID(propId, count);
			}
			else
			{
				if (arr[0] != propId) //更换货物种类
				{
					//将货架原有物品退回仓库
					StoreManager.getInstance().addPropByID(arr[0], arr[1]);
					count = Math.min( vo.volume, num );
					props[place]=[propId, count];
					StoreManager.getInstance().delPropByID(propId, count);
				}
				else //货物补全
				{
					var n:uint=arr[1];
					count = Math.min( n + num, vo.volume );
					arr[1]=count;
					StoreManager.getInstance().delPropByID(propId, count - n);
				}

			}

			updatePropIcon(place);
		}


		public function delProp(propId:String, num:uint):void
		{
			var arr:Array;
			for (var i:int=props.length - 1; i >= 0; i--)
			{
				arr=props[i];
				if (arr[0] == propId)
				{
					if (arr[1] >= num)
					{
//						trace("货品充足");
						arr[1]-=num;
						updatePropIcon(i);
						//提示
						Pop.show(propId, num.toString(), stage, popPoint);
						break;
					}
					else
					{
						trace("货架物品不足！");
					}
				}
			}
//			ShelfManager.getInstance().addToWait(this);
		}

		private function updatePropIcon(place:int):void
		{
			var num:int;
			var id:String;
			var icon:Sprite;

			var sprite:Sprite=action["sprite_" + place];
			sprite.removeChildren(1);
			sprite.mouseEnabled=sprite.mouseChildren=false;

			if (!props[place] || props[place][1] == 0)
				return;
			id=props[place][0];

			icon=AssetsManager.instance().getResByName("sprite_" + id) as Sprite;
			const w:Number=icon.width;
			const h:Number=icon.height;

			var d:Number=(sprite.width * 3 % w) / (Math.floor(sprite.width * 3 / w) - 1);
			num=Math.floor(props[place][1] / vo.volume * (Math.floor(sprite.width * 3 / w) - 1));
			if (!(num % 2))
				num+=1;
			for (var i:int=0; i < num; i++)
			{
				icon=AssetsManager.instance().getResByName("sprite_" + id) as Sprite;
				icon.x=w / 3 + i * (w + d) / 3;
				icon.y=-(i % 2) * h / 3;
				if (i % 2 == 1)
					sprite.addChildAt(icon, sprite.numChildren - 1);
				else
					sprite.addChild(icon);
			}
		}

		/**
		 * [
		 * 		[id, num],
		 * 		[id, num],
		 * 		[id, num]
		 * ]
		 */
		public var props:Array=[];

		public function getPropNumByID(propID:String):uint
		{
			for each (var arr:Array in props)
			{
				if (arr[0] == propID)
					return arr[1];
			}
			return 0;
		}

		/**
		 * 货物补充
		 */
		public function resplenish():void
		{
			var id:String;
			for (var i:int=0; i < props.length; i++)
			{
				id=props[i][0];
				this.putInProp(i, id, StoreManager.getInstance().getPropNumByID(id));
			}

			ShelfManager.getInstance().delFromWait(this);
		}

		public function ifPropIn(propID:String):Boolean
		{
			for each (var arr:Array in props)
			{
				if (arr[0] == propID)
					return true;
			}
			return false;
		}

		public function getTargetTile():ItemTile
		{
			var points:Vector.<Point>=vo.target;
			var point:Point=points[Math.floor(Math.random() * points.length)];
			return LogicalMap.getInstance().getTileByPosition(point);
		}

		override public function dispose():void
		{
			vo=null;
			this.removeEventListener(MouseEvent.CLICK, onMouseEvent);
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseEvent);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseEvent);
			this.removeChild(action);
			action=null;
			props=null;
			super.dispose();
		}

		public function clear():void
		{
			this.visible=true;
			props=[];
			for (var i:int=0; i < vo.count; i++)
			{
				updatePropIcon(i);
			}
		}

		/**
		 * @return 
		 * {
		 * 		state:	
		 * 			-1	货架未启用
		 * 			0	货架已满 /
		 * 			1	库存不足，无法补货
		 * 			2	需要补货
		 * 		pop:[				//当reason == 2时，补货完成后提示
		 * 			缺少库存物品的id，
		 * 			缺少库存物品的id
		 * 		]
		 * }
		 */		
		public function needResplenish():Object
		{
			var obj:Object = {};
			
			var id:String;
			var crtNum:uint;
			if (props.length == 0)
			{
				obj.state = -1;
				return obj;
			}
			
			var arr:Array = [];			//库存不足的物品id集合
			var count:uint = 0;			//已满货架数量
			
			for (var i:int=props.length - 1; i >= 0; i--)
			{
				id=props[i][0];
				crtNum=props[i][1];
				
				if( crtNum < vo.volume )
				{
					if( StoreManager.getInstance().getPropNumByID(id) > 0 )
						obj.state = 2;
					else		//库存不足
						arr.push( id );
				}else
				{
					count ++;
				}
				//缺少货品且仓库内尚有存货，此时满足补货条件
//				if (crtNum < vo.volume && StoreManager.getInstance().getPropNumByID(id) > 0)
//					return true;
			}
			obj.pop = arr;
			if(count >= props.length)		//货架已满，无需补货
				obj.state = 0;
			else if( arr.length + count >= props.length )		//库存不足，无需补货
				obj.state = 1;
			return obj;
		}
	}
}