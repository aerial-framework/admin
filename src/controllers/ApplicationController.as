package controllers
{
	import components.config.DatabaseSelector;
	
	import flash.filesystem.File;
	
	import org.osflash.signals.Signal;

	public class ApplicationController
	{
		private static var _instance:ApplicationController;
		
		public var configModeChanged:Signal;
		public var configViewChanged:Signal;
		
		public var addDatabaseNode:Signal;
		public var showPage:Signal;
		
		public static const HOME:String = "home";
		public static const NEW_PROJECT:String = "newProject";
		public static const BROWSE_FOR_PROJECT:String = "browseForProject";
		public static const OPEN_PROJECT:String = "openProject";
		public static const CODE_GENERATION:String = "codeGeneration";
		public static const CONFIG_EDITOR:String = "configEditor";
		public static const BACKUP_AND_RESTORE:String = "backupAndRestore";
		
		private var _configMode:String;
		
		public var projectDirectory:File;
		
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
			
			showPage = new Signal(String);
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