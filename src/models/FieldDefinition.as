package models
{
	[Bindable]
	public class FieldDefinition
	{
		public var name:String;
		public var type:String;
		public var length:int;
		public var isRelation:Boolean;
		public var many:Boolean;
		
		public function FieldDefinition()
		{
		}
	}
}