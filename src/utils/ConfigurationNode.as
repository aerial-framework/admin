package utils
{
	[Bindable]
	public class ConfigurationNode
	{
		public var type:String;
		public var category:String;
		public var label:String;
		public var absolute:Boolean;
		public var defaultValue:String;
		public var multiple:Boolean;
		public var nodeNameRelevance:Boolean = true;
		public var options:Array;
		public var name:String;
		public var nodeToUse:String;
		public var description:String;
		public var nodeName:String;
		
		/**
		 * Is this config item representing a value from config-alt.xml
		 */
		public var isAlt:Boolean;
		
		public var raw:XML;
		public var parentRaw:XML;
		
		public var value:*;
		
		public var children:Array;
		
		public function ConfigurationNode()
		{
		}
	}
}