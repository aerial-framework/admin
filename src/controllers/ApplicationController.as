/**
 * User: Danny Kopping
 * Date: 2011/08/06
 */
package controllers
{
    import flash.filesystem.File;

    import models.Project;

    import org.osflash.signals.Signal;

    public class ApplicationController
    {
        private static var _instance:ApplicationController;

        public static const PROJECT_EXTENSION:String = "aerial";

		private var preferencesFile:File;
		private var preferencesXML:XML;

		public var applicationDescriptorLoad:Signal;

        {
            _instance = new ApplicationController();
        }

        public function ApplicationController()
        {
            applicationDescriptorLoad = new Signal();
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
			preferencesFile = File.applicationStorageDirectory.resolvePath("preferences.xml");

			if(!preferencesFile || !preferencesFile.exists)
				preferencesFile = FileIOController.createIfNotExists(preferencesFile.url);

			if(!preferencesFile || !preferencesFile.exists)
				throw new Error("Cannot create or open application preferences file");

			preferencesXML = FileIOController.read(preferencesFile, false, XML) as XML;
			applicationDescriptorLoad.dispatch();
		}

		public function getProjects():Array
		{
			if(!preferencesXML)
				return [];

			var projects:Array = [];
			for each(var projectXML:XML in preferencesXML.projects..project)
			{
				var project:Project = new Project();
				project.location = new File(projectXML.@location.toString());
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
                var projectXML:XML = new XML("<project location=\"" + project.location.nativePath + "\" " +
                        "lastAccessed=\"" + project.lastAccessed.getTime() + "\"/>");

                preferences.projects.appendChild(projectXML);
            }

            FileIOController.write(preferencesFile, preferences.toXMLString());
        }
    }
}