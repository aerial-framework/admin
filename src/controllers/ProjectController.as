package controllers
{
	import flash.filesystem.File;
	import flash.xml.XMLNodeType;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
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
		public var updateProjects:Signal;
		
		private var bootstrapValues:Array = [];
		
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
				updateProjects = new Signal();
				
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
			if(!preferencesFile.exists)
				FileController.instance.write(preferencesFile, "");
		}
		
		private function savePathHandler(directory:File):void
		{
			initFiles();
			
			var descriptor:XML;
			descriptor = XML(FileUtil.read(preferencesFile));
			
			var empty:Boolean;
			
			if(descriptor.children().length() == 0)
				empty = true;
			
			var projects:Array = [];
			
			if(preferencesFile.exists && preferencesFile.size > 0 && !empty)
			{
				projects = XMLSerializer.deserialize(descriptor) as Array;
				
				if(projects.indexOf(directory.nativePath) == -1)
					projects.push(directory.nativePath);
			}
			else
				projects.push(directory.nativePath);
			
			descriptor = XMLSerializer.serialize(projects);
			FileUtil.write(preferencesFile, descriptor.toXMLString());
		}
		
		public function getConfiguration():Object
		{
			bootstrapValues = [];
			
			if(!ApplicationController.instance.configFile.exists)
			{
				Alert.show("Configuration path invalid. Please check the " + 
					ApplicationController.instance.configFile.parent.name + " directory and " +
					"validate the path in project.xml in the root of your project", "Error");
				return null;
			}
			
			var data:String = FileController.instance.read(ApplicationController.instance.configFile);
			var parsed:Object = xmlToObject(XML(data));
			
			return parsed;
		}
		
		private function xmlToObject(xml:XML, chain:Object=null):Object
		{
			if(!chain)
				chain = {};
			
			for each(var child:XML in xml.children())
			{
				if(child.nodeKind() == "comment")
					continue;
				
				if(child.attribute("include-in-bootstrap").toString() == "true")
				{
					(child.children().length() > 1 || (child.children().length() == 1 && child.hasComplexContent()))
					?	chain[child.name().toString()] = xmlToObject(child, chain[child.name().toString()])
					:	chain[child.name().toString()] = {"include":true, value:child.text().toString()};
					
					bootstrapValues.push({name:child.name().toString(), value:child.text().toString()});
				}
				else
				{
					(child.children().length() > 1 || (child.children().length() == 1 && child.hasComplexContent()))
					?	chain[child.name().toString()] = xmlToObject(child, chain[child.name().toString()])
					:	chain[child.name().toString()] = {value:child.text().toString()};
				}
			}
			
			return chain;
		}
		
		public function getBootstrapValues():Array
		{
			return bootstrapValues;
		}
		
		/*public function xmlToObjectFlat(xml:XML, chain:Object=null, string:String=null):Object
		{
			if(!chain)
				chain = {};
			
			if(!string)
				string = "";
			
			for each(var child:XML in xml.children())
			{
				if(child.nodeKind() == "comment")
					continue;
				
				
				(child.children().length() > 1 || (child.children().length() == 1 && child.hasComplexContent()))
				?	chain[string + "/" + child.name().toString()] = xmlToObjectFlat(child, chain[child.name().toString()], string + "/" + child.name().toString())
				:	chain[string + "/" + child.name().toString()] = child.text().toString();
			}
			
			return chain;
		}*/
		
		public function getProjects():Array
		{
			initFiles();
			
			var descriptor:XML = XML(FileUtil.read(preferencesFile));
			var empty:Boolean;
			
			if(descriptor.children().length() == 0)
				empty = true;
			
			if(empty)
				return [];
			else
			{
				var projects:ArrayCollection = new ArrayCollection(XMLSerializer.deserialize(XML(FileUtil.read(preferencesFile))) as Array);
				for each(var dir:String in projects)
				{
					var directory:File = new File(dir);
					if(!directory.exists)
						projects.removeItemAt(projects.getItemIndex(dir));
				}
				
				return projects.source;
			}
		}
	}
}