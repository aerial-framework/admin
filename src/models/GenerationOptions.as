package models
{
	import flash.filesystem.File;

	public class GenerationOptions
	{
		public var packageString:String;
		public var bootstrapPath:File;
		public var phpModelsPath:File;
		public var phpServicesPath:File;
		public var as3ModelsPath:File;
		public var as3ServicesPath:File;
		public var voSuffix:String;
		public var serviceSuffix:String;
	}
}