package controllers
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;

	public class GenerationController
	{		
		private static var _instance:GenerationController;
		
		public var log:Signal;
		public var timerStart:Signal;
		public var timerEnd:Signal;
		
		private var beforeTime:int;
		private var fileCount:uint = 0;
		
		private static const BASE:File = File.desktopDirectory.resolvePath("aerial-codegen");
		
		{
			_instance = new GenerationController();
		}
		
		public function GenerationController()
		{
			if(_instance)
				throw new Error("Cannot instantiate Singleton object");
			else
			{
				log = new Signal(String, String);
				timerStart = new Signal(String);
				timerEnd = new Signal(String);
				
				timerStart.add(timerStartHandler);
				timerEnd.add(timerEndHandler);
			}
		}
		
		public static function get instance():GenerationController
		{
			return _instance;
		}
		
		public function generate(models:Array, phpServices:Boolean, as3Models:Boolean, as3Services:Boolean):void
		{
			if(!phpServices && !as3Models && !as3Services)
				return;
			
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
				log.dispatch(null, "separator");
				
				if(phpServices)		generatePHPService(model);
				if(as3Services)		generateAS3Service(model);
				if(as3Models)		generateAS3Model(model);
			}
			
			timerEnd.dispatch("Code generation of " + fileCount + " files completed");
		}
		
		private function generatePHPService(model:Object):void
		{
			log.dispatch("Initiating PHP service generation", "process");
			
			var template:String = getTemplate("php.service.tmpl");
			var replacementTokens:Object = {};
			replacementTokens["model"] = 				model.name;
			replacementTokens["class"] = 				model.name + "Service";
			replacementTokens["object"] = 				model.name.charAt(0).toLowerCase() + model.name.substr(1);
			
			for(var property:String in replacementTokens)
				template = template.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);
			
			writeGenerated(template, "services/" + model.name + "Service.php");
		}
		
		private function generateAS3Service(model:Object):void
		{
			log.dispatch("Initiating AS3 service generation", "process");
			
			var template:String = getTemplate("as3.service.tmpl");
			var replacementTokens:Object = {};
			
			replacementTokens["model"] = 				model.name + "VO";
			replacementTokens["class"] = 				model.name + "Service";
			replacementTokens["package"] = 				"org.aerialproject.service";
			replacementTokens["modelPackage"] = 		"org.aerialproject.vo";
			replacementTokens["configPackage"] = 		"org.aerial.config";
			replacementTokens["configClass"] = 			"Config";
			
			for(var property:String in replacementTokens)
				template = template.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);
			
			writeGenerated(template, "services/" + model.name + "Service.as");
		}
		
		private function generateAS3Model(model:Object):void
		{
			log.dispatch("Initiating AS3 service generation", "process");
			
			var template:String = getTemplate("as3.vo.tmpl");
			var replacementTokens:Object = {};
			
			replacementTokens["package"] = 				"org.aerialproject.vo";
			replacementTokens["collectionImport"] = 	"import mx.collections.ArrayCollection";
			replacementTokens["class"] = 				model.name + "VO";
			replacementTokens["remoteClass"] = 			model.name;
			
			var properties:Array = [];
			var accessors:Array = [];
			
			var accessorStub:String = getPart("all.xml", "as3AccessorStub");
			
			for(var prop:String in model.definition)
			{
				var name:String = model.definition[prop].name;
				var type:String = model.definition[prop].type;
				
				properties.push("\t\tprivate var " + name + ":*\n");
				
				var accessor:String = accessorStub.replace(new RegExp("{{field}}", "gi"), name);
				accessor = accessor.replace(new RegExp("{{type}}", "gi"), type);
				
				accessors.push(accessor);
			}
			
			replacementTokens["privateVars"] = 			properties.join("");
			replacementTokens["accessors"] = 			accessors.join("\n");
			
			for(var property:String in replacementTokens)
				template = template.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);
			
			writeGenerated(template, "vo/" + model.name + "VO.as");
		}
		
		private function writeGenerated(data:String, name:String):void
		{
			var file:File = BASE.resolvePath(name);
			var size:String = Number(data.length / 1024).toFixed(3) + "Kb";
			
			log.dispatch("Writing " + name + " (" + size + ")", "process");
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
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