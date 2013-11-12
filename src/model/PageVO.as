package model
{

	public class PageVO
	{
		public function PageVO(perPage:int, page:int)
		{
			this.page=page;
			this.perPage=perPage;
		}

		public var perPage:int;
		public var page:int;
	}
}
