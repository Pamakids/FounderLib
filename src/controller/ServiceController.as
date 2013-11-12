package controller
{
	import com.pamakids.utils.Singleton;

	import flash.events.Event;

	import model.UserVO;

	import org.idream.pomelo.Pomelo;
	import org.idream.pomelo.PomeloEvent;

	public class ServiceController extends Singleton
	{
		public function ServiceController()
		{
			pomelo=Pomelo.getIns();
			pomelo.addEventListener('onAdd', addUserHandler);
			pomelo.addEventListener('onLeave', removeUserHandler);
			pomelo.addEventListener(Event.CLOSE, closeHandler);
		}

		protected function closeHandler(event:Event):void
		{

		}

		protected function removeUserHandler(event:Event):void
		{

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

		public var me:UserVO;
		public var other:UserVO;
	}
}
