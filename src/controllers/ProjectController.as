package controllers
{
	import flash.filesystem.File;
	
	import mx.utils.ObjectUtil;
	
	import org.libspark.serialization.XMLSerializer;
	import org.osflash.signals.Signal;
	
	import utils.FileUtil;

	public class ProjectController
	{
		private static var _instance:ProjectController;
		private var preferencesDirectory:File;
		private var preferencesFile:File;
		
		public var initializeView:Signal;
		public var savePath:Signal; 
		
		// static initializer
		{
			// create instance
			_instance = new ProjectController();
		}
		
		public function ProjectController()
		{
			if(_instance)
				throw new Error("Cannot instantiate new instance of Singleton " + this);
			else
			{
				// signals
				initializeView = new Signal(File);
				savePath = new Signal(File);
				
				// listeners
				savePath.add(savePathHandler);
				
				// other
				preferencesDirectory = File.applicationStorageDirectory.resolvePath("preferences");
			}
		}
		
		public static function get instance():ProjectController
		{			
			return _instance;
		}
		
		private function initFiles():void
		{
			if(!preferencesDirectory.exists)
				preferencesDirectory.createDirectory();
			
			preferencesFile = preferencesDirectory.resolvePath("preferences.xml");
		}
		
		private function savePathHandler(directory:File):void
		{
			initFiles();
			
			var descriptor:XML;
			
			var projects:Array = [];
			
			if(preferencesFile.exists && preferencesFile.size > 0)
			{
				descriptor = XML(FileUtil.read(preferencesFile));
				projects = XMLSerializer.deserialize(descriptor) as Array;
				
				if(projects.indexOf(directory.nativePath) == -1)
					projects.push(directory.nativePath);
			}
			else
				projects.push(directory.nativePath);
			
			descriptor = XMLSerializer.serialize(projects);
			FileUtil.write(preferencesFile, descriptor.toXMLString());
		}
		
		public function getProjects():Array
		{
			initFiles();
			return preferencesFile ? XMLSerializer.deserialize(XML(FileUtil.read(preferencesFile))) as Array : [];
		}
	}
}