package utils
{
	public class ConfigurationNode
	{
		public var type:String;
		public var category:String;
		public var lable:String;
		public var absolute:Boolean;
		public var defaultValue:String;
		public var multiple:Boolean;
		public var nodeNameRelevance:Boolean;
		public var options:Array;
		
		public var children:Array;
		
		public function ConfigurationNode()
		{
		}
	}
}