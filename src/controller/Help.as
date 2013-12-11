package controller
{
	import com.pamakids.utils.Singleton;

	import flash.utils.setTimeout;

	import mx.controls.ToolTip;
	import mx.core.IToolTip;
	import mx.managers.ToolTipManager;

	public class Help extends Singleton
	{
		public function Help()
		{
			super();
			ToolTip.maxWidth=500;
		}

		public static function get instance():Help
		{
			return Singleton.getInstance(Help);
		}

		private var showingTip:IToolTip;
		private var recordY:Number;
		private var recordX:Number;

		public function showHelp(text:String, x:Number=0, y:Number=0, hideTime:Number=0):IToolTip
		{

			if (showingTip)
				hideHelp(showingTip);

			var ti:IToolTip=ToolTipManager.createToolTip(text, x ? x : recordX, y ? y : recordY);

//			ti.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void
//			{
			ti.x=(ti.parent.width - ti.width) / 2;
//			}, false, 0, true);

			if (hideTime)
				setTimeout(function():void
				{
					hideHelp(ti);
				}, hideTime);
			showingTip=ti;

			if (x)
				recordX=x;
			if (y)
				recordY=y;

			return ti;
		}

		public function hideHelp(ti:IToolTip):void
		{
			if (ti && ti.parent)
			{
				ToolTipManager.destroyToolTip(ti);
			}
		}

		public function hideAll():void
		{
			hideHelp(showingTip);
			showingTip=null;
		}
	}
}
