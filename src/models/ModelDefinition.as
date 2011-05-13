package models
{
	[Bindable]
	public class ModelDefinition
	{
		public var name:String;
		public var type:String;
		public var length:int;
		public var isRelation:Boolean;
		public var many:Boolean;
		
		public function ModelDefinition()
		{
		}
	}
}