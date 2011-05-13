package models
{
	import flash.filesystem.File;

	[Bindable]
	public class Project
	{
		public var name:String;
		public var location:File;
		public var lastAccessed:Date;
		
		public function Project()
		{
		}
	}
}