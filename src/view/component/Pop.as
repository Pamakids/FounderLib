package view.component
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	
	import flash.display.DisplayObjectContainer;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import global.DC;

	public class Pop
	{
		public static const POPID_MONEY:String="money";
		public static const POPID_ALERT:String = "alert";
		private static const vecTF:Vector.<TextField>=new Vector.<TextField>();

		/**
		 * @param id
		 * @param value
		 * @param container
		 * @param position		
		 */		
		public static function show(id:String, value:String, container:DisplayObjectContainer, position:Point):void
		{
			trace("show");
			trace(vecTF.length);
			var tf:TextField=(vecTF.length > 0) ? vecTF.shift() : textFieleFactory();
			var txt:String;
			if (id == POPID_MONEY)		//钱
			{
				txt=(Number(value) > 0) ? "获得： " + value + " ￥" : txt="减少： " + (-Number(value)).toString() + " ￥";
			}
			else if(id == POPID_ALERT)		//提示
			{
				txt = value;
			}
			else
			{
				var name:String=DC.instance().getPropNameByID(id);
				txt=(Number(value) > 0) ? "获得：" + name + " x " + value : "减少： " + name + " x " + (-Number(value)).toString();
			}
			tf.text=txt;
			tf.x=position.x - tf.width / 2;
			tf.y=position.y;
			tf.alpha=0;
			container.addChild(tf);
			var tarY:Number=position.y - 60;
			var tarA:Number=1;
			TweenLite.to(tf, 1, {alpha: tarA, y: tarY, ease: Cubic.easeOut, onComplete: function():void
			{
				if (tf.parent)
					tf.parent.removeChild(tf);
				vecTF.push(tf);
				TweenLite.killTweensOf(tf);
			}});

		}

		private static function textFieleFactory():TextField
		{
			var tf:TextField=new TextField();
			tf.width=200;
			tf.multiline=false;
			tf.mouseEnabled=false;
			tf.defaultTextFormat=new TextFormat(null, 14, 0xffff00, null, null, null, null, null, "center");
			tf.filters=Filters;
			return tf;
		}

		private static const Filters:Array=[new GlowFilter(0x0, .8, 2, 2, 100, 1)];

	}
}
