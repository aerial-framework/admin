package controllers
{
	import org.osflash.signals.Signal;

	public class NavigationController
	{
		private static var _instance:NavigationController;
		
		public static const PROJECTS:String = "projects";
		public static const CODE_GEN:String = "codeGeneration";
		
		public var navigationChange:Signal;
		
		{
			_instance = new NavigationController();
		}
		
		public function NavigationController()
		{
			navigationChange = new Signal(String);
		}
		
		public static function get instance():NavigationController
		{
			return _instance;
		}
	}
}