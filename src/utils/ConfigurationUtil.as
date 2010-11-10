package utils
{
	public class ConfigurationUtil
	{
		private static var _instance:ConfigurationUtil;
		
		public var configXML:XML;
		public var altConfigXML:XML;
		public var descriptorXML:XML;
		
		public var warnings:Array = [];
		public var errors:Array = [];
		
		public static const SIMPLE:String = "simple";
		public static const ADVANCED:String = "advanced";
		
		public static const HYBRID:String = "hybrid";
		public static const REGULAR:String = "regular";
		public static const ALTERNATIVE:String = "alternative";
		
		{
			_instance = new ConfigurationUtil();
		}
		
		public function ConfigurationUtil()
		{
			if(_instance)
				throw new Error("Singleton cannot be instantiated");
		}
		
		public static function get instance():ConfigurationUtil
		{
			return _instance;
		}
		
		public function getRegularNode(parentNodeName:String, parentNodeLabel:String):Object
		{
			var cNode:XML = XML(configXML[parentNodeName][0]);
			var dNode:XML = XML(descriptorXML[parentNodeName][0]);
			
			if(!cNode.name() || !dNode.name())
			{
				errors.push(parentNodeLabel + " node is missing in " + (!cNode.name() ? "configuration file " : "configuration descriptor"));
				return null;
			}
			
			var parentNode:ConfigurationNode = new ConfigurationNode();
			parentNode.name = dNode.name().toString();
			parentNode.absolute = dNode.@absolute.toString() == "true";
			parentNode.type = dNode.@type.toString();
			parentNode.label = dNode.@label.toString();
			parentNode.category = dNode.@category.toString();
			parentNode.defaultValue = dNode.@['default'].toString();
			parentNode.value = cNode.text().toString();
			parentNode.description = dNode.text().toString();
			parentNode.raw = cNode;
			parentNode.parentRaw = configXML;
			
			// find the children node names that should ideally be in the configuration file
			var idealChildren:Array = [];
			for each(var child:XML in dNode.children())
			{
				// if the child is CDATA, ignore it
				if(child.nodeKind() == "text")
					continue;
				
				idealChildren.push(child.name().toString());
			}
			
			var children:Array = [];
			
			// now check what's actually in the config file
			for each(var nodeName:String in idealChildren)
			{
				var testNode:XML = XML(cNode.child(nodeName)[0]);
				var descriptorNode:XML = XML(dNode.child(nodeName)[0]);
				
				if(testNode.name() == null)
				{
					children[nodeName] = null;
					errors.push("'" + nodeName + "' node is missing in configuration file");
					continue;
				}
				
				var node:ConfigurationNode = new ConfigurationNode();
				node.absolute = descriptorNode.@absolute.toString() == "true";
				node.name = descriptorNode.name().toString();
				node.type = descriptorNode.@type.toString();
				node.label = descriptorNode.@label.toString();
				node.category = descriptorNode.@category.toString();
				node.defaultValue = descriptorNode.@['default'].toString();
				node.value = testNode.text().toString();
				node.raw = testNode;
				node.parentRaw = cNode;

				if(node.type == "boolean")
					node.value = node.value == "true";
				
				if(node.type == "array")
				{
					
				}
				
				node.description = descriptorNode.text().toString();
				
				children.push(node);
			}
			
			parentNode.children = children;
			return parentNode;
		}
		
		public function getDatabaseNodes():Object
		{
			var cNode:XML = XML(configXML["database"][0]);
			var dNode:XML = XML(descriptorXML["database"][0]);
			
			if(!cNode.name() || !dNode.name())
			{
				errors.push("Database node is missing in " + (!cNode.name() ? "configuration file " : "configuration descriptor"));
				return null;
			}
			
			var parentNode:ConfigurationNode = new ConfigurationNode();
			parentNode.type = dNode.name().toString();
			parentNode.type = dNode.@type.toString();
			parentNode.label = dNode.@label.toString();
			parentNode.category = dNode.@category.toString();
			parentNode.description = dNode.text().toString();
			parentNode.raw = cNode;
			
			var nodeToUse:String = cNode.@['use'].toString();
			
			// create the ideal structure
			var structure:Array = [];				
			for each(var element:XML in dNode.structure.children())
				structure.push(element.name().toString());
			
			var children:Array = [];
			for each(var element:XML in cNode.children())
			{
				for each(var elementName:String in structure)
				{
					// validate the existent (or non-existent) nodes
					if(element.child(elementName)[0] == null)
					{
						errors.push("'" + elementName + "' node is missing in configuration file");
						continue;
					}
				}
				
				var subNodes:Object = {};
				for each(var subNode:XML in element.children())
				{
					var descriptorNode:XML = dNode.structure.child(subNode.name().toString())[0];
					
					var node:ConfigurationNode = new ConfigurationNode();
					node.name = descriptorNode.name().toString();
					node.type = descriptorNode.@type.toString();
					node.label = descriptorNode.@label.toString();
					node.category = descriptorNode.@category.toString();
					node.defaultValue = descriptorNode.@['default'].toString();
					node.value = subNode.text().toString();
					node.description = descriptorNode.text().toString();
					node.nodeName = element.name().toString();
					node.raw = subNode;
					node.parentRaw = cNode;
					
					if(descriptorNode.attribute("options")[0] != null)
					{
						var options:Array = [];
						var splitOptions:Array = descriptorNode.@options.toString().split(",");
						for each(var option:String in splitOptions)
						{
							var parts:Array = option.split(":");
							options.push({label:parts[0], data:parts[1]});
						}
						
						node.options = options;
					}
					
					subNodes[subNode.name().toString()] = node;
				}
				
				children.push(subNodes);
				
				if(element.name().toString() == nodeToUse)
					parentNode.nodeToUse = element.name().toString();
			}
			
			parentNode.children = children;
			return parentNode;
		}
	}
}