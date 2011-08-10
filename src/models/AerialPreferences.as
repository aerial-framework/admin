package models
{
	import controllers.FileIOController;
	
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	import org.as3commons.lang.ClassUtils;

	[Bindable]
	public class AerialPreferences
	{
		// Aerial admin preferences
		public static var adminConfigFile:File;
		public static var adminConfig:XML;
		
		public static function getNode(hierarchy:String, returnType:Class):*
		{
			var hierarchySplit:Array = hierarchy.split("/");
			var file:XML = adminConfig;
			
			if(!file || file.children().length() == 0)
			{
				Alert.show("Could not find " + hierarchy + " in Aerial Admin configuration file", "Error");
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
				Alert.show("There is an error in your Aerial Admin configuration file.\n" +
							"Could not find the <" + element + "> node", "Error");
				return;
			}
			
			return ClassUtils.newInstance(returnType, [node.text()]);
		}
		
		public static function setNode(hierarchy:String, data:String):void
		{
			var hierarchySplit:Array = hierarchy.split("/");
			var configFile:File = adminConfigFile;
			var config:XML = adminConfig;
			
			if(!config || config.children().length() == 0)
			{
				Alert.show("Could not save " + hierarchy + " to Aerial Admin configuration file", "Error");
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
			FileIOController.write(configFile, content, false, String);
		}
		
		public static function setNodes(hierarchies:Array, data:Array):void
		{
			for(var i:uint = 0; i < hierarchies.length; i++)
			{
				var hierarchySplit:Array = hierarchies[i].split("/");
				var configFile:File = adminConfigFile;
				var config:XML = adminConfig;
				
				if(!config || config.children().length() == 0)
				{
					Alert.show("Could not save " + hierarchies[i] + " to Aerial Admin configuration file", "Error");
					return;
				}
				
				var node:XML = config;
				for each(var element:String in hierarchySplit)
				{
					if(!element || element.length == 0)
						continue;
					
					node = XML(node.child(element));
				}
				
				node = node.setChildren(data[i]);
			}
			
			var content:String = '<?xml version="1.0" encoding="UTF-8"?>\n' + config.toXMLString();
			FileIOController.write(configFile, content, false, String);
		}
	}
}