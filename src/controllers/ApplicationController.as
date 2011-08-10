package controllers
{
    import flash.filesystem.File;

    import models.Project;

    import org.osflash.signals.Signal;

    public class ApplicationController
    {
        private static var _instance:ApplicationController;

        public static const PROJECT_EXTENSION:String = "aerial";

		private var _preferencesFile:File;
		private var _preferencesXML:XML;

		public var applicationDescriptorLoaded:Signal;

        {
            _instance = new ApplicationController();
        }

        public function ApplicationController()
        {
            applicationDescriptorLoaded = new Signal();
        }

        public static function get instance():ApplicationController
        {
            return _instance;
        }

		/**
		 * Load up projects and preferences
		 */
		public function initialize():void
		{
			_preferencesFile = File.applicationStorageDirectory.resolvePath("preferences.xml");

			if(!_preferencesFile || !_preferencesFile.exists)
				_preferencesFile = FileIOController.createIfNotExists(_preferencesFile.url);

			if(!_preferencesFile || !_preferencesFile.exists)
				throw new Error("Cannot create or open application preferences file");

			_preferencesXML = FileIOController.read(_preferencesFile, false, XML) as XML;
			applicationDescriptorLoaded.dispatch();
		}

        public function get preferences():XML
        {
            return _preferencesXML;
        }

		public function getProjects():Array
		{
			if(!_preferencesXML)
				return [];

			var projects:Array = [];
			for each(var projectXML:XML in _preferencesXML.projects..project)
			{
				var project:Project = new Project();
				project.preferencesFile = new File(projectXML.@location.toString());
				project.lastAccessed = new Date();
				project.lastAccessed.setTime(projectXML.@lastAccessed.toString());

				projects.push(project);
			}

			return projects;
		}

        public function setProjects(projects:Array):void
        {
            var preferences:XML = <preferences><projects/></preferences>;
            for each(var project:Project in projects)
            {
                var projectXML:XML = new XML("<project location=\"" + project.preferencesFile.nativePath + "\" " +
                        "lastAccessed=\"" + project.lastAccessed.getTime() + "\"/>");

                preferences.projects.appendChild(projectXML);
            }

            FileIOController.write(_preferencesFile, preferences.toXMLString());
        }
    }
}