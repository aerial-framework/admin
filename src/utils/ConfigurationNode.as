package utils
{
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
		
		public var value:*;
		
		public var children:Array;
		
		public function ConfigurationNode()
		{
		}
	}
}