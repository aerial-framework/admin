package controllers
{
    import components.popup.ConfigFileSelector;

    import flash.events.Event;

    import flash.filesystem.File;

    import models.Project;

    import mx.controls.Alert;
    import mx.utils.ObjectUtil;

    import org.osflash.signals.Signal;

    public class ProjectController
	{
		private static var _instance:ProjectController;

        public var selectedProject:Project;

        public var projectSelected:Signal;
        public var projectOpened:Signal;

        private var bootstrapValues:Array = [];
		
		{
			_instance = new ProjectController();
		}
		
		public function ProjectController()
		{
            projectSelected = new Signal(File);
            projectOpened = new Signal(XML);

            projectSelected.add(projectSelectHandler);
		}

        private function projectSelectHandler(file:File):void
        {
            if(!file || !file.exists)
            {
                Alert.show("An error occurred while attempting to open your project.", "Error");
                return;
            }

            selectedProject = new Project();
            selectedProject.location = file;
            selectedProject.lastAccessed = new Date();

            parseProjectFile(file);
        }

        private function parseProjectFile(file:File):void
        {
            if(!selectedProject)
                return;

            try
            {
                var contents:XML = FileIOController.read(file, false, XML);
                var configPath:String = contents.project["config-path"].text().toString();
                var configFile:File = new File();

                if(!configPath || !configFile.resolvePath(configPath) || !configFile.resolvePath(configPath).exists)
                {
                    // config file path is invalid or null, show config selection window
                    var configFileSelector:ConfigFileSelector = new ConfigFileSelector();
                    configFileSelector.open();

                    configFileSelector.addEventListener(Event.CLOSING, configFileSelectionHandler);
                }
                else
                {
                    // config file successfully found... open the project
                    configFile = configFile.resolvePath(configPath);

                    projectOpened.dispatch(FileIOController.read(configFile, false, XML));
                }
            }
            catch(e:Error)
            {
                Alert.show("There was an error parsing the project file\n" + file.nativePath, "Error");
                selectedProject = null;
                return;
            }
        }

        private function configFileSelectionHandler(event:Event):void
        {
            if(!selectedProject)
                return;

            // write the config path and try again
            var configSelector:ConfigFileSelector = event.currentTarget as ConfigFileSelector;
            if(configSelector.cancelled)
            {
                selectedProject = null;
                return;
            }

            var configFile:File = configSelector.selectedFile;

            if(!configFile || !configFile.exists)
            {
                parseProjectFile(selectedProject.location);
                return;
            }

            try
            {
                var contents:XML = FileIOController.read(selectedProject.location, false, XML);
                contents.project["config-path"] = configFile.nativePath;

                if(FileIOController.write(selectedProject.location, contents.toXMLString(), false))
                {
                    // config path now successfully configured, carry on
                    parseProjectFile(selectedProject.location);
                }
            }
            catch(e:Error)
            {
                Alert.show("The project file could not be updated:\n\n" + e.message, "Error");
            }
        }
		
		public static function get instance():ProjectController
		{
			return _instance;
		}

        public function getNumOpenedProjects():int
        {
            return 1;
        }

		public function getConfiguration():Object
		{
			bootstrapValues = [];

			if(!selectedProject.configFile.exists)
			{
				Alert.show("Configuration path invalid. Please check the " +
					selectedProject.configFile.parent.name + " directory and " +
					"validate the path in project.xml in the root of your project", "Error");
				return null;
			}

			var data:String = FileIOController.read(selectedProject.configFile);
			var altData:String = FileIOController.read(selectedProject.configAltFile);

			var parsed:Object = xmlToObject(XML(data));
			var parsedAlt:Object = xmlToObject(XML(altData));

			for(var key:String in parsed)
				compareAndOverwrite(parsed, [key], parsedAlt);

			return parsed;
		}

		/**
		 * Compare one object to another recursively and replace properties of the parent object with values of
		 * the comparison object where the values exist & differ from the parent object
		 */
		private function compareAndOverwrite(obj:Object, chain:Array=null, comparison:Object=null):void
		{
			var newObj:Object = ObjectUtil.copy(obj);

			for each(var link:String in chain)
				newObj = newObj[link];

			if(newObj.hasOwnProperty("value"))			// is child
			{
				var introspectedComparison:Object = ObjectUtil.copy(comparison);
				for each(var link:String in chain)
				{
					if(introspectedComparison.hasOwnProperty(link))
						introspectedComparison = introspectedComparison[link];
					else
					{
						// do nothing to the object
						return;
					}

					if(introspectedComparison.hasOwnProperty("value"))
					{
						if(introspectedComparison.value && introspectedComparison.value != "")
						{
							var introspected:Object = obj;
							for each(var link:String in chain)
								introspected = introspected[link];

							// override the value with the comparison's value
							introspected.value = introspectedComparison.value;
							return;
						}
						else
						{
							// do nothing to the object
							return;
						}
					}
				}

				//trace(chain.join(".") + " > " + newObj.value);
			}
			else									// is parent
			{
				for(var key:String in newObj)
				{
					var newChain:Array = [];
					newChain = newChain.concat(chain);

					newChain.push(key);
					compareAndOverwrite(obj, newChain, comparison);
				}
			}
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
    }
}