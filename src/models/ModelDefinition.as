package models
{
	[Bindable]
	public class ModelDefinition
	{
		public var modelName:String;
		
		// an array of FieldDefinition objects
		public var fields:Array;
		
		public var phpModel:GeneratedFile = new GeneratedFile(GeneratedFile.PHP_MODEL);
		public var phpBaseModel:GeneratedFile = new GeneratedFile(GeneratedFile.PHP_BASE_MODEL);
		public var phpService:GeneratedFile = new GeneratedFile(GeneratedFile.PHP_SERVICE);
		public var as3Model:GeneratedFile = new GeneratedFile(GeneratedFile.AS3_MODEL);
		public var as3Service:GeneratedFile = new GeneratedFile(GeneratedFile.AS3_SERVICE);
		
		public function ModelDefinition()
		{
		}
	}
}