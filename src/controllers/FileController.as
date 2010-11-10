package controllers
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipFile;
	import nochump.util.zip.ZipOutput;

	public class FileController
	{
		private static var _instance:FileController;
		
		{
			_instance = new FileController();
		}
		
		public function FileController()
		{
			if(_instance)
				throw new Error("Singleton class cannot be instantiated");
		}
		
		public static function get instance():FileController
		{
			return _instance;
		}
		
		public function read(file:File, type:Class=null):*
		{
			if(!type)
				type = String;
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			
			var contents:*;
			
			switch(type)
			{
				case String:
					contents = stream.readUTFBytes(stream.bytesAvailable);
					break;
				case ByteArray:
					contents = new ByteArray();
					stream.readBytes(contents);
					break;
			}
			
			stream.close();
			return contents;
		}
		
		public function write(file:File, data:*, type:Class=null):void
		{
			if(!type)
				type = String;
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			
			switch(type)
			{
				case String:
					stream.writeUTFBytes(data);
					break;
				case ByteArray:
					stream.writeBytes(data);
					break;
			}
			
			stream.close();
		}
		
		public function backup(original:File, backup:File):void
		{
			var originalContents:String = this.read(original);
			
			var backupBytes:ByteArray = new ByteArray();
			backupBytes.writeUTFBytes(originalContents);
			
			var output:ZipOutput = new ZipOutput();
			var entry:ZipEntry = new ZipEntry(original.name);
			output.putNextEntry(entry);
			output.write(backupBytes);
			output.closeEntry();
			
			output.finish();
			
			this.write(backup, output.byteArray, ByteArray);
		}
	}
}