package controllers
{
	import components.config.DatabaseSelector;
	
	import org.osflash.signals.Signal;

	public class ApplicationController
	{
		private static var _instance:ApplicationController;
		
		public var configModeChanged:Signal;
		public var configViewChanged:Signal;
		
		public var addDatabaseNode:Signal;
		
		private var _configMode:String;
		
		{
			_instance = new ApplicationController();
		}
		
		public function ApplicationController()
		{
			if(_instance)
			{
				throw new Error("Singleton class cannot be instantiated.");
				return;
			}
			
			configModeChanged = new Signal(String);
			configViewChanged = new Signal(String, Boolean);
			addDatabaseNode = new Signal(DatabaseSelector);
		}		

		public function get configMode():String
		{
			return _configMode;
		}

		public function set configMode(value:String):void
		{
			_configMode = value;
			configModeChanged.dispatch(value);
		}

		public static function get instance():ApplicationController
		{
			return _instance;
		}
	}
}