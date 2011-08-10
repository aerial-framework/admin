package models
{
    import controllers.ApplicationController;

    import flash.filesystem.File;

	[Bindable]
	public class Project
	{
		public var preferencesFile:File;
        public var preferences:XML;
		public var lastAccessed:Date;

        public var configFile:File;
        public var configAltFile:File;
		
		public function Project()
		{
		}
	}
}