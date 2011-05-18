package models
{
	import flash.filesystem.File;

	[Bindable]
	public class Project
	{
		public var location:File;
		public var lastAccessed:Date;
		
		public function Project()
		{
		}

        public function get isValid():Boolean
        {
            var invalid:Boolean;

            if(location)
            {
                if(!location.exists)
                {
                    invalid = true;
                }
            }
            else
                invalid = true;

            if(!location.resolvePath(".aerial").exists)
                invalid = true;

            return !invalid;
        }
	}
}