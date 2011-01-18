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
			var altData:String = FileController.instance.read(ApplicationController.instance.configAltFile);
			
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
            var data:XML = XML(FileController.instance.read(ApplicationController.instance.configFile));
			var altData:XML = XML(FileController.instance.read(ApplicationController.instance.configAltFile));

			var merged:Array = [];

            var configBootstrapValues:Object = this.findBoostrapValues(data);
            var configAltBootstrapValues:Object = this.findBoostrapValues(altData);

            // overwrite regular config's bootstrap values if it exists in the config-alt
            for(var item:String in configAltBootstrapValues)
                configBootstrapValues[item] = configAltBootstrapValues[item];

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

				if(child.attribute("include-in-bootstrap").toString() == "true")
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
		
		public function clearProjects():void
		{
			FileUtil.write(preferencesFile, XMLSerializer.serialize([]).toXMLString());
		}
	}
}