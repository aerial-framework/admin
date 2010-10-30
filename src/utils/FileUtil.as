package utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class FileUtil
	{
		public function FileUtil()
		{
		}
		
		public static function write(file:File, data:*, format:String="String"):void
		{
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			
			switch(format)
			{
				case "String":
					stream.writeUTFBytes(data as String);
					break;
				case "ByteArray":
					stream.writeBytes(data as ByteArray);
					break;
				case "Array":
					stream.writeObject(data as Array);
					break;
				default:
					throw new Error("Unsupported format " + format);
					break;
			}
			
			stream.close();
		}
		
		public static function read(file:File, format:String="String"):*
		{
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			
			var data:*;
			
			switch(format)
			{
				case "String":
					data = stream.readUTFBytes(stream.bytesAvailable);
					break;
				case "ByteArray":
					data = new ByteArray();
					stream.readBytes(data);
					break;
				case "Array":
					data = stream.readObject() as Array;
					break;
				default:
					throw new Error("Unsupported format" + format);
					break;
			}
			
			stream.close();
			return data;
		}
	}
}