package events
{
	import flash.events.Event;
	
	public class ArchiveControlEvent extends Event
	{
		public static const DOWNLOAD_START:String = "downloadStart";
		public static const DOWNLOAD_ERROR:String = "downloadError";
		public static const DOWNLOAD_COMPLETE:String = "downloadComplete";
		public static const ARCHIVE_SAVE:String = "archiveSave";
		public static const ARCHIVE_SAVE_ERROR:String = "archiveSaveError";
		public static const ARCHIVE_READ:String = "archiveRead";
		public static const FILE_OPEN:String = "fileOpen";
		
		public function ArchiveControlEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}