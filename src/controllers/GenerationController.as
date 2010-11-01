package controllers
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import org.osflash.signals.Signal;

	public class GenerationController
	{		
		private static var _instance:GenerationController;
		public var log:Signal;
		
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
			}
		}
		
		public static function get instance():GenerationController
		{
			return _instance;
		}
		
		public function generate(models:Array, phpServices:Boolean, as3Models:Boolean, as3Services:Boolean):void
		{
			log.dispatch("<b>Code Generation initialized</b>", "title");
			log.dispatch((phpServices ? "Creating" : "Not creating") + " PHP services", "info");
			log.dispatch((as3Models ? "Creating" : "Not creating") + " AS3 models", "info");
			log.dispatch((as3Services ? "Creating" : "Not creating") + " AS3 services", "info");
			
			log.dispatch("Preparing to generate <b>" + models.length + "</b> models", "info");
			
			
		}
		
		public function getTemplate(filename:String):String
		{
			var file:File = File.applicationDirectory.resolvePath("codegen/templates/" + filename);
			if(!file.exists)
				throw new Error("No template file found at " + file.nativePath);
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			
			var content:String = stream.readUTFBytes(stream.bytesAvailable);
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
	}
}