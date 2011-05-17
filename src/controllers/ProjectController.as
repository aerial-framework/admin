package controllers
{
	import flash.filesystem.File;
	
	import models.AerialPreferences;
	import models.Project;

	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	import org.osflash.signals.Signal;

	public class ProjectController
	{
		private static var _instance:ProjectController;
		
		private var preferencesFile:File;
		private var preferencesXML:XML;
		
		private var projectPreferencesFile:File;
		private var projectPreferencesXML:XML;

		private var configFile:File;
		private var configXML:XML;
		
		public var projectSelect:Signal;		
		public var preferencesLoad:Signal;
		
		public var projectBasePath:File;
		
		{
			_instance = new ProjectController();
		}
		
		public function ProjectController()
		{
			preferencesLoad = new Signal();
			
			projectSelect = new Signal(Project);
			projectSelect.add(projectSelectHandler);
		}
		
		private function projectSelectHandler(project:Project):void
		{
			// load admin preferences file
			
			projectPreferencesFile = project.location.resolvePath(".aerial");
			if(!projectPreferencesFile.exists)
			{
				NavigationController.instance.navigationChange.dispatch(NavigationController.PROJECTS);
				Alert.show("Cannot load project preferences:\nCannot find \".aerial\" file in project root", "Error opening project");
				return;
			}
			
			projectBasePath = project.location;
			
			projectPreferencesXML = FileIOController.read(projectPreferencesFile, false, XML) as XML;			
			AerialPreferences.adminConfig = projectPreferencesXML;
			AerialPreferences.adminConfigFile = projectPreferencesFile;
			
			// load Aerial project config file
			configFile = project.location.resolvePath("config/config.xml");
			if(!configFile.exists)
			{
				NavigationController.instance.navigationChange.dispatch(NavigationController.PROJECTS);
				Alert.show("Cannot load Aerial config file:\nPlease ensure that you have a \"config\" folder in your project root with a \"config.xml\" file in it.", "Error opening project configuration");
				return;
			}
			
			configXML = FileIOController.read(configFile, false, XML) as XML;			
			AerialPreferences.serverConfig = configXML;
			AerialPreferences.serverConfigFile = configFile;
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
			trace(preferencesFile.nativePath);
			
			if(!preferencesFile)
				preferencesFile = FileIOController.createIfNotExists(preferencesFile.url);
			
			if(!preferencesFile || !preferencesFile.exists)
				throw new Error("Cannot create or open application preferences file");
			
			preferencesXML = FileIOController.read(preferencesFile, false, XML) as XML;
			preferencesLoad.dispatch();
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
		
		public function getProjectPreferences():XML
		{
			if(!projectPreferencesFile || !projectPreferencesFile.exists || !projectPreferencesXML)
				return null;
			
			return projectPreferencesXML;	
		}

        public function getBootstrapValues():Array
		{
            if(!configXML || configXML.children().length() <= 0)
                return [];

            var data:XML = configXML;
//			var altData:XML = XML(FileController.instance.read(ApplicationController.instance.configAltFile));

			var merged:Array = [];

            var configBootstrapValues:Object = this.findBoostrapValues(data);
//            var configAltBootstrapValues:Object = this.findBoostrapValues(altData);

            // overwrite regular config's bootstrap values if it exists in the config-alt
//            for(var item:String in configAltBootstrapValues)
//                configBootstrapValues[item] = configAltBootstrapValues[item];

            // now, loop through all the config's bootstrap values and add them to the array
            for(var item:String in configBootstrapValues)
                merged.push({name:item, value:configBootstrapValues[item]});

            return merged;
		}

        private function findBoostrapValues(xml:XML, values:Object=null):Object
        {
            if(!values)
				values = {};

			for each(var child:XML in xml.children())
			{
				if(child.nodeKind() == "comment")
					continue;

				if(child.attribute("expose").toString() == "true")
				{
					if(child.children().length() > 1 || (child.children().length() == 1 && child.hasComplexContent()))
						findBoostrapValues(child, values);

					values[child.name().toString()] = child.text().toString();
				}
				else
				{
					if(child.children().length() > 1 || (child.children().length() == 1 && child.hasComplexContent()))
						findBoostrapValues(child, values);
				}
			}

			return values;
        }
    }
}