package models
{
	import flash.filesystem.File;

	public class GenerationOptions
	{
        // paths
        public var basePath:File;
		public var packageString:String;
		public var bootstrapPath:File;
		public var phpModelsPath:File;
        public var phpBaseModelsPath:File;
		public var phpServicesPath:File;
		public var as3ModelsPath:File;
		public var as3ServicesPath:File;

        // options
		public var voSuffix:String;
		public var serviceSuffix:String;

        // data
        public var phpModels:Vector.<Object>;
        // ModelDefinition instances
	}
}