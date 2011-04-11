package controllers
{
    import flash.events.SecurityErrorEvent;
    import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.core.Application;
	import mx.utils.ObjectUtil;
	
	import org.osflash.signals.Signal;

	public class GenerationController
	{		
		private static var _instance:GenerationController;
		
		public var log:Signal;
		public var timerStart:Signal;
		public var timerEnd:Signal;
		
		private var beforeTime:int;
		private var fileCount:uint = 0;
		
		private static const AS3_MODELS:String = "as3Models";
		private static const AS3_SERVICES:String = "as3Services";
		private static const PHP_SERVICES:String = "phpServices";
		private static const BOOTSTRAP:String = "bootstrap";
		
		private var config:Object;
		
		private var voSuffix:String;
		private var serviceSuffix:String;
		
		private var as3VOFolder:String;
		private var as3ServiceFolder:String;
		
		private var phpVOFolder:String;
		private var phpServiceFolder:String;
		
		private var as3Base:File;
		private var phpBase:File;
		
		private var bootstrapBase:File;
		
		private var packageString:String;
		
		private var primitive:Array = ["int", "Number", "uint", "Boolean", "Object", "Array", "String", "Date", "ByteArray"];
		private var imports:Object = {};

        public var allDirectoriesCreated:Boolean;
		
		{
			_instance = new GenerationController();
		}
		
		public function GenerationController()
		{
			if(_instance)
			{
				throw new Error("Cannot instantiate Singleton object");
				return;
			}
			
			log = new Signal(String, String);
			timerStart = new Signal(String);
			timerEnd = new Signal(String);
			
			timerStart.add(timerStartHandler);
			timerEnd.add(timerEndHandler);
			
			initConfig();
		}
		
		private function initConfig():void
		{
			config = ProjectController.instance.getConfiguration();
			
			voSuffix = config["code-generation"].vo.value;
			serviceSuffix = config["code-generation"].service.value;
			
			packageString = config["code-generation"]["package"].value;
			var packageName:String = packageString.split(".").join("/") + "/";
			
			as3VOFolder = packageName + config["code-generation"]["as3-models-folder"].value;
			phpVOFolder = packageName + config["code-generation"]["php-models-folder"].value;
			
			as3ServiceFolder = packageName + config["code-generation"]["as3-services-folder"].value;
			phpServiceFolder = packageName + config["code-generation"]["php-services-folder"].value;
			
			as3Base = ApplicationController.instance.projectDirectory.resolvePath(config["code-generation"]["as3"].value);
			//if(!as3Base.exists)
			//	as3Base.createDirectory();
			
			phpBase = ApplicationController.instance.projectDirectory.resolvePath(config["code-generation"]["php"].value);
			//if(!phpBase.exists)
			//	phpBase.createDirectory();
			
			var bootstrapStructure:String = config["code-generation"]["bootstrap-package"].value.replace(/\./gi, "/");
			bootstrapBase = as3Base.resolvePath(bootstrapStructure);
			if(!bootstrapBase.exists)
				bootstrapBase.createDirectory();
			
			imports["ByteArray"] = "flash.utils.ByteArray";
			imports["ArrayCollection"] = "mx.collections.ArrayCollection";
		}
		
		public static function get instance():GenerationController
		{
			return _instance;
		}

        public function getAS3ModelsPath():File
        {
            var dir:File = as3Base.resolvePath(as3VOFolder);
            if(!dir.exists)
                tryCreateFolder(dir);

            return dir;
        }

        public function getPHPModelsPath():File
        {
            var dir:File = phpBase.resolvePath(phpVOFolder);
            if(!dir.exists)
                tryCreateFolder(dir);

            return dir;
        }

        public function getAS3ServicesPath():File
        {
            var dir:File = as3Base.resolvePath(as3ServiceFolder);
            if(!dir.exists)
                tryCreateFolder(dir);

            return dir;
        }

        public function getPHPServicesPath():File
        {
            var dir:File = phpBase.resolvePath(phpServiceFolder);
            if(!dir.exists)
                tryCreateFolder(dir);

            return dir;
        }

        private function tryCreateFolder(folder:File):void
        {
            try
            {
                folder.createDirectory();
            }
            catch(e:Error)
            {
                Alert.show("Could not create folder " + folder.nativePath + "\n" +
                        "Please check the directory permissions of the parent folder.");
                allDirectoriesCreated = false;
            }
        }

        private function permissionErrorHandler(event:SecurityErrorEvent):void
        {
            Alert.show(event.text + " > " + event.currentTarget);
        }
		
		public function generate(models:Array, phpServices:Boolean, as3Models:Boolean, as3Services:Boolean, bootstrap:Boolean):void
		{
			if(!phpServices && !as3Models && !as3Services && !bootstrap)
				return;
			
			// refresh config
			initConfig();
			
			log.dispatch("<b>Code Generation initialized</b><br/>", "process");
			
			log.dispatch("Preparing to generate <b>" + models.length + "</b> models", "info");
			log.dispatch(null, "separator");
			
			log.dispatch((phpServices ? "Creating" : "Not creating") + " PHP services", "info");
			log.dispatch((as3Models ? "Creating" : "Not creating") + " AS3 models", "info");
			log.dispatch((as3Services ? "Creating" : "Not creating") + " AS3 services", "info");
			
			timerStart.dispatch(null);
			fileCount = 0;
			
			for each(var model:Object in models)
			{
                if(phpServices || as3Services || as3Models)
				    log.dispatch(null, "separator");
				
				if(phpServices)		generatePHPService(model);
				if(as3Services)		generateAS3Service(model);
				if(as3Models)		generateAS3Model(model);
			}
			
			if(bootstrap)			generateBootstrapper();
			
			timerEnd.dispatch("Code generation of " + fileCount + " files completed");
		}
		
		private function generatePHPService(model:Object):void
		{
			log.dispatch("Initiating PHP service generation", "process");
			
			var template:String = getTemplate("php.service.tmpl");
			var replacementTokens:Object = {};
			replacementTokens["model"] = 				model.name;
			replacementTokens["class"] = 				model.name + serviceSuffix;
			//replacementTokens["object"] = 				model.name.charAt(0).toLowerCase() + model.name.substr(1);
			
			for(var property:String in replacementTokens)
				template = template.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);
			
			writeGenerated(template, model.name + serviceSuffix + ".php", PHP_SERVICES);
		}
		
		private function generateAS3Service(model:Object):void
		{
			log.dispatch("Initiating AS3 service generation", "process");
			
			var template:String = getTemplate("as3.service.tmpl");
			var replacementTokens:Object = {};
			
			replacementTokens["model"] = 				model.name + voSuffix;
			replacementTokens["class"] = 				model.name + serviceSuffix;
			replacementTokens["package"] = 				packageString + "." + config["code-generation"]["as3-services-folder"].value;
			replacementTokens["modelPackage"] = 		packageString + "." + config["code-generation"]["as3-models-folder"].value;
			replacementTokens["bootstrapPackage"] = 	config["code-generation"]["bootstrap-package"].value;
			replacementTokens["bootstrapClass"] = 		config["code-generation"]["bootstrap-filename"].value;
			
			for(var property:String in replacementTokens)
				template = template.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);
			
			writeGenerated(template, model.name + serviceSuffix + ".as", AS3_SERVICES);
		}
		
		private function generateAS3Model(model:Object):void
		{
			log.dispatch("Initiating AS3 service generation", "process");
			
			var template:String = getTemplate("as3.vo.tmpl");
			var replacementTokens:Object = {};
			
			replacementTokens["package"] = 				packageString + "." + config["code-generation"]["as3-models-folder"].value;
			replacementTokens["collectionImport"] = 	"";
			replacementTokens["class"] = 				model.name + voSuffix;
			replacementTokens["remoteClass"] = 			model.name;
			
			var properties:Array = [];
			var accessors:Array = [];
			
			var accessorStub:String = getPart("all.xml", "as3AccessorStub");
			
			var toImport:Array = [];
			for(var prop:String in model.definition)
			{
				var name:String = model.definition[prop].name;
				var many:Boolean = model.definition[prop].many && model.definition[prop].relation;
				
				var type:String;
				
				if(many)
					type = "ArrayCollection";
				else
				{
					type = model.definition[prop].type;
				
					// if the type is not primitive, add the VO suffix
					if(primitive.indexOf(type) == -1)
						type += voSuffix;

					// Convert int to Number.  This fixes a bug where Flash won't hit the setter if you're trying to 
					// set a zero value because * type retruns zero from the getter.  
					if(type == "int" || type == "uint")
						type = "Number";
				}
				
				if(imports[type])			// if this type has a specific import string
				{
					var str:String = "import " + imports[type] + ";";
					if(toImport.indexOf(str) == -1)
						toImport.push(str);
				}
				
				properties.push("\t\tprivate var _" + name + ":*\n");
				
				var accessor:String = accessorStub.replace(new RegExp("{{field}}", "gi"), name);
				accessor = accessor.replace(new RegExp("{{type}}", "gi"), type);
				
				accessors.push(accessor);
			}
			
			replacementTokens["collectionImport"] += toImport.join("\n\t");
			
			replacementTokens["privateVars"] = 			properties.join("");
			replacementTokens["accessors"] = 			accessors.join("\n");
			
			for(var property:String in replacementTokens)
				template = template.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);
			
			writeGenerated(template, model.name + voSuffix + ".as", AS3_MODELS);
		}

        public function writePHPModelsFromDoctrine(definitions:ArrayCollection):void
        {
            for each(var definition:Object in definitions.source)
            {
                var baseClass:File = new File(definition.baseClass.path);
                var topLevelClass:File = new File(definition.topLevelClass.path);

                // if the file data is null, skip it
                if(!definition.baseClass.file || definition.baseClass.file == "")
                    continue;
                else
                    FileController.instance.write(baseClass, definition.baseClass.file, String);

                if(!definition.topLevelClass.file || definition.topLevelClass.file == "")
                    continue;
                else
                    FileController.instance.write(topLevelClass, definition.topLevelClass.file, String);
            }
        }
		
		private function sanitizeConstName(name:String):String
		{
			return name.replace(/-/gi, "_").toUpperCase();
		}
		
		private function getConstType(value:String):String
		{
			var type:String = "String";
			if(value == "true" || value == "false")
				return "Boolean";
			
			return type;
		}
		
		private function generateBootstrapper():void
		{			
			log.dispatch("Initiating Bootstrapper generation", "process");
			
			var template:String = getTemplate("bootstrap.tmpl");
			var replacementTokens:Object = {};
			
			replacementTokens["package"] = 				config["code-generation"]["bootstrap-package"].value;
			replacementTokens["class"] = 				config["code-generation"]["bootstrap-filename"].value;

			var bootstrapConsts:Array = ProjectController.instance.getBootstrapValues();

			replacementTokens["configValues"] = [];
			for each(var item:Object in bootstrapConsts)
			{
				var type:String = getConstType(item.value);
				var value:String = item.value;
				
				if(type == "String")
					value = '"' + value + '"';
				
				replacementTokens["configValues"].push("\t\tpublic static const " + 
												sanitizeConstName(item.name) + ":" + type + " = " + value + ";");
			}
			
			replacementTokens["configValues"] = replacementTokens["configValues"].join("\n");
			
			for(var property:String in replacementTokens)
				template = template.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);
			
			writeGenerated(template, replacementTokens["class"] + ".as", BOOTSTRAP);
		}
		
		private function writeGenerated(data:String, name:String, type:String):void
		{
			var file:File;
			
			// determine path
			switch(type)
			{
				case AS3_MODELS:
					file = as3Base.resolvePath(as3VOFolder).resolvePath(name);
					break;
				case AS3_SERVICES:
					file = as3Base.resolvePath(as3ServiceFolder).resolvePath(name);
					break;
				case PHP_SERVICES:
					file = phpBase.resolvePath(phpServiceFolder).resolvePath(name);
					break;
				case BOOTSTRAP:
					file = bootstrapBase.resolvePath(name);
					break;
			}
			
			var size:String = Number(data.length / 1024).toFixed(3) + "Kb";
			
			log.dispatch("Writing " + name + " (" + size + ")", "process");
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			//trace(file.nativePath);
			stream.writeUTFBytes(data);
			stream.close();
			
			log.dispatch(name + " written successfully to disk", "info");
			fileCount++;
		}
		
		public function getTemplate(filename:String):String
		{
			var file:File = File.applicationDirectory.resolvePath("codegen/templates/" + filename);
			if(!file.exists)
				throw new Error("No template file found at " + file.nativePath);
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			
			var content:String = stream.readUTFBytes(stream.bytesAvailable);
			log.dispatch("Using " + file.name + " template", "info");
			stream.close();
			
			return content;
		}
		
		public function getPart(filename:String, name:String):String
		{
			var file:File = File.applicationDirectory.resolvePath("codegen/parts/" + filename);
			if(!file.exists)
				throw new Error("No part file found at " + file.nativePath);
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			
			var content:XML = XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			
			var part:XML = XML(content.part.(@name == name));
			if(part)
				return part.content.text();
			
			return null;
		}
		
		private function timerStartHandler(message:String):void
		{
			beforeTime = getTimer();
			
			if(!message)
				return;
			
			log.dispatch(message, "info");
		}
		
		private function timerEndHandler(message:String):void
		{
			var count:String = ((getTimer() - beforeTime) / 1000).toFixed(3);
			
			if(!message)
				return;
			
			log.dispatch(message + " (" + count + "s)", "info");
		}
	}
}