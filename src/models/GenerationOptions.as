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

        public var generateBootstrap:Boolean;
        public var generateAS3Models:Boolean;
        public var generateAS3Services:Boolean;
        public var generatePHPModels:Boolean;
        public var generatePHPServices:Boolean;

        // data
        public var selectedModels:Vector.<Object>;          // ModelDefinition instances
	}
}