package models
{
	import controllers.FileIOController;
	
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	import org.as3commons.lang.ClassUtils;

	[Bindable]
	public class AerialPreferences
	{
		public static const SERVER:String = "server";
		public static const ADMIN:String = "admin";
		
		// configuration of Aerial server
		public static var serverConfigFile:File;
		public static var serverConfig:XML;
		
		// Aerial admin preferences
		public static var adminConfigFile:File;
		public static var adminConfig:XML;
		
		public static function getNode(hierarchy:String, returnType:Class, type:String=SERVER):*
		{
			var hierarchySplit:Array = hierarchy.split("/");
			var file:XML = type == SERVER ? serverConfig : adminConfig;
			
			if(!file || file.children().length() == 0)
			{
				Alert.show("Could not find " + hierarchy + " in " + (SERVER ? "Aerial" : "Aerial Admin") + " configuration file", "Error");
				return null;
			}
			
			try
			{
				var node:XML = file;
				for each(var element:String in hierarchySplit)
				{
					if(!element || element.length == 0)
						continue;
					
					node = XML(node.child(element));
				}
			}
			catch(e:Error)
			{
				Alert.show("There is an error in your " + (type == SERVER ? "Aerial" : "Aerial Admin") + " configuration file.\n" +
							"Could not find the <" + element + "> node", "Error");
				return;
			}
			
			return ClassUtils.newInstance(returnType, [node.text()]);
		}
		
		public static function setNode(hierarchy:String, data:String, file:String=SERVER):void
		{
			var hierarchySplit:Array = hierarchy.split("/");
			var configFile:File = file == SERVER ? serverConfigFile : adminConfigFile;
			var config:XML = file == SERVER ? serverConfig : adminConfig;
			
			if(!config || config.children().length() == 0)
			{
				Alert.show("Could not save " + hierarchy + " to " + (SERVER ? "Aerial" : "Aerial Admin") + " configuration file", "Error");
				return;
			}
			
			var node:XML = config;
			for each(var element:String in hierarchySplit)
			{
				if(!element || element.length == 0)
					continue;
				
				node = XML(node.child(element));
			}
			
			node = node.setChildren(data);
			
			var content:String = '<?xml version="1.0" encoding="UTF-8"?>\n' + config.toXMLString();
			trace(">>>" + configFile.nativePath);
			trace(content);
			FileIOController.write(configFile, content, false, String);
		}
	}
}