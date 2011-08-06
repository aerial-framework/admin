package models
{
    import controllers.ApplicationController;

    import flash.filesystem.File;

	[Bindable]
	public class Project
	{
		public var location:File;
		public var lastAccessed:Date;
		
		public function Project()
		{
		}
	}
}