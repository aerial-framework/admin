package controllers
{
    import flash.filesystem.File;

    import org.osflash.signals.Signal;

    public class ProjectController
	{
		private static var _instance:ProjectController;

        public var projectSelected:Signal;
		
		{
			_instance = new ProjectController();
		}
		
		public function ProjectController()
		{
            projectSelected = new Signal(File);
		}
		
		public static function get instance():ProjectController
		{
			return _instance;
		}

        public function getNumOpenedProjects():int
        {
            return 1;
        }
    }
}