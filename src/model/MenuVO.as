package model
{

	public class MenuVO
	{
		public function MenuVO(label:String, key:String='', view:String='', command:String='')
		{
			this.label=label;
			this.key=key;
			this.view=view;
			this.command=command;
		}

		public var label:String;
		public var key:String;
		public var view:String;
		public var command:String;

		public function get data():String
		{
			return view ? view : command;
		}
	}
}
