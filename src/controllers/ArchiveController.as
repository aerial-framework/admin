package controllers
{
	import events.ArchiveControlEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipFile;
	
	[Bindable]
	
	[Event(name="downloadStart", type="events.ArchiveControlEvent")]
	[Event(name="downloadError", type="events.ArchiveControlEvent")]
	[Event(name="downloadComplete", type="events.ArchiveControlEvent")]
	[Event(name="archiveSave", type="events.ArchiveControlEvent")]
	[Event(name="archiveSaveError", type="events.ArchiveControlEvent")]
	[Event(name="archiveRead", type="events.ArchiveControlEvent")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	public class ArchiveController extends EventDispatcher
	{
		private static var _instance:ArchiveController;
		
		private var archive:File;
		private var destination:File;
		private var zipFile:ZipFile;
		
		public var fileIndex:uint = 0;
		
		private var _currentFile:File;
		
		public var files:Array = [];
		private var archiveLoader:URLLoader;
		
		public function ArchiveController()
		{
			addEventListener(ArchiveControlEvent.ARCHIVE_READ, processArchive);
		}
		
		public static function get instance():ArchiveController
		{
			if(!_instance)
				_instance = new ArchiveController();
			
			return _instance;
		}
		
		public function downloadArchive(url:String, hostname:String, file:File):void
		{
			this.archive = file;
			
			archiveLoader = new URLLoader();
			archiveLoader.dataFormat = URLLoaderDataFormat.BINARY;
			var req:URLRequest = new URLRequest(url);
			req.requestHeaders = [new URLRequestHeader("Host", hostname),		// fake the requestor host
									new URLRequestHeader("Range", "bytes=0-")];						// start from 0 bytes to end of file
			
			archiveLoader.load(req);
			dispatchEvent(new ArchiveControlEvent(ArchiveControlEvent.DOWNLOAD_START));
			
			archiveLoader.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			
			archiveLoader.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			archiveLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadError);
			
			archiveLoader.addEventListener(Event.COMPLETE, onDownloadComplete);
		}
		
		public function cancelDownload():void
		{
			archiveLoader.close();
		}
		
		public function extractArchive(destination:File, archive:File=null):void
		{
			if(archive != null)
				this.archive = archive;
			
			this.destination = destination;
			
			fileIndex = 0;								// reset file counter
			
			var stream:FileStream = new FileStream();
			stream.open(this.archive, FileMode.READ);
			
			var data:ByteArray = new ByteArray();
			stream.readBytes(data);
			
			this.zipFile = new ZipFile(data);
			this.files = this.zipFile.entries;
			
			dispatchEvent(new ArchiveControlEvent(ArchiveControlEvent.ARCHIVE_READ));
		}
		
		private function processArchive(event:ArchiveControlEvent):void
		{
			recursiveWriter();
		}
		
		private function recursiveWriter():void
		{
			var entry:ZipEntry = this.files[fileIndex];
			
			var file:File = new File(this.destination.nativePath + "/" + entry.name);
			_currentFile = file;
			
			if(entry.name.charAt(entry.name.length - 1) == "/")
			{
				file.createDirectory();
				goNext();
			}
			else
			{
				var stream:FileStream = new FileStream();
				stream.addEventListener(Event.CLOSE, goNext);
				stream.openAsync(file, FileMode.WRITE);
				
				dispatchEvent(new ArchiveControlEvent(ArchiveControlEvent.FILE_OPEN));
				
				var data:ByteArray = zipFile.getInput(entry);
				
				stream.writeBytes(data);
				stream.close();
			}
		}		
		
		private function goNext(event:Event=null):void
		{
			fileIndex++;
			if(fileIndex != files.length)
				recursiveWriter();
		}
		
		[Bindable(event="fileOpen")]
		public function get currentFile():File
		{
			return _currentFile;
		}
		
		private function onDownloadProgress(event:ProgressEvent):void
		{
			dispatchEvent(event);
		}
		
		private function onDownloadError(event:Event):void
		{
			dispatchEvent(new ArchiveControlEvent(ArchiveControlEvent.DOWNLOAD_ERROR));
		}
		
		private function onDownloadComplete(event:Event):void
		{
			dispatchEvent(new ArchiveControlEvent(ArchiveControlEvent.DOWNLOAD_COMPLETE));
			
			var stream:FileStream = new FileStream();
			try
			{
				stream.open(this.archive, FileMode.WRITE);
				stream.writeBytes(event.currentTarget.data);
				stream.close();
			}
			catch(e:Error)
			{
				dispatchEvent(new ArchiveControlEvent(ArchiveControlEvent.ARCHIVE_SAVE_ERROR));
			}
			
			dispatchEvent(new ArchiveControlEvent(ArchiveControlEvent.ARCHIVE_SAVE));
		}
	}
}