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
		public var projectSelected:Signal;
		
		public static const HOME:String = "home";
		public static const NEW_PROJECT:String = "newProject";
		public static const BROWSE_FOR_PROJECT:String = "browseForProject";
		public static const OPEN_PROJECT:String = "openProject";
		public static const CODE_GENERATION:String = "codeGeneration";
		public static const CONFIG_EDITOR:String = "configEditor";
		public static const BACKUP_AND_RESTORE:String = "backupAndRestore";
		
		private var _configMode:String;
		
		private var _projectDirectory:File;
		
		public var projectMap:Object = {};
		
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
			
			projectMap = {};
			
			configModeChanged = new Signal(String);
			configViewChanged = new Signal(String, Boolean);
			addDatabaseNode = new Signal(DatabaseSelector);
			
			showPage = new Signal(String);
			projectSelected = new Signal(Array);
		}
		

		public function get projectDirectory():File
		{
			return _projectDirectory;
		}

		public function set projectDirectory(value:File):void
		{
			_projectDirectory = value;
			addProject(value);
		}

		private function addProject(directory:File):void
		{
			if(!directory)
				return;
			
			projectMap[directory.name] = directory;			
			projectSelected.dispatch(getProjects());
		}
		
		public function closeProject(directory:File):void
		{
			if(!directory)
				return;
			
			delete projectMap[directory.name];	
			projectDirectory = null;
			
			//projectSelected.dispatch(getProjects());
		}
		
		public function getProjects():Array
		{
			var projects:Array = [];
			for(var name:String in projectMap)
				projects.push({label:name, data:projectMap[name]});
			
			return projects;
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