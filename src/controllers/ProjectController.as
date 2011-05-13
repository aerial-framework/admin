package controllers
{
	import flash.filesystem.File;
	
	import models.Project;
	
	import mx.utils.ObjectUtil;
	
	import org.osflash.signals.Signal;

	public class ProjectController
	{
		private static var _instance:ProjectController;
		
		private var preferencesFile:File;
		private var preferencesXML:XML;
		
		public var projectSelect:Signal = new Signal(Project);
		
		{
			_instance = new ProjectController();
		}
		
		public function ProjectController()
		{
		}
		
		public static function get instance():ProjectController
		{
			return _instance;
		}
		
		/**
		 * Load up projects and preferences
		 */
		public function initialize():void
		{
			preferencesFile = File.applicationStorageDirectory.resolvePath("preferences.xml");
			
			if(!preferencesFile)
				preferencesFile = FileIOController.createIfNotExists(preferencesFile.url);
			
			if(!preferencesFile || !preferencesFile.exists)
				throw new Error("Cannot create or open application preferences file");
			
			preferencesXML = FileIOController.read(preferencesFile, false, XML) as XML;
		}
		
		public function getProjects():Array
		{
			if(!preferencesXML)
				return [];
			
			var projects:Array = [];
			for each(var projectXML:XML in preferencesXML.projects..project)
			{
				var project:Project = new Project();
				project.name = projectXML.@name.toString();
				project.location = new File(projectXML.@location.toString());
				project.lastAccessed = new Date();
				project.lastAccessed.setTime(projectXML.@lastAccessed.toString());
				
				projects.push(project);
			}
			
			return projects;
		}
	}
}