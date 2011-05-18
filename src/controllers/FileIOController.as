package controllers
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class FileIOController
	{
		public static function read(file:File, createIfNotExists:Boolean=false, returnFormat:Class=null):*
		{
			// can't use a Class as a parameter initializer...
			if(!returnFormat)
				returnFormat = String;
			
			if(!file || !file.exists)
			{
				if(!createIfNotExists)
					return null;
				
				file = FileIOController.createIfNotExists(file.url);
				if(!file || !file.exists)
					return null;
				
				FileIOController.read(file, false, returnFormat);
			}
			
			if(file.isDirectory)
				throw new Error("Cannot write data to directory " + file.nativePath);
			
			try
			{
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				
				stream.position = 0;
				
				var contents:*;
				
				switch(returnFormat)
				{
					case String:
						contents = stream.readUTFBytes(stream.bytesAvailable);
						break;
					case XML:
						contents = XML(stream.readUTFBytes(stream.bytesAvailable));
						break;
					case ByteArray:
						contents = new ByteArray();
						stream.readBytes(contents);
						break;
					default:
						throw new Error("No return format available for type " + returnFormat);
						break;
				}
				
				stream.close();
			}
			catch(e:Error)
			{
				throw new Error("An error occurred while attempting to read the data from this file.\n\nStack Trace:" + e.getStackTrace());
				return null;
			}
			
			return contents;
		}
		
		public static function write(file:File, data:*, createIfNotExists:Boolean=true, dataFormat:Class=null):Boolean
		{
			// can't use a Class as a parameter initializer...
			if(!dataFormat)
				dataFormat = String;
			
			if(!file || !file.exists)
			{
				if(!createIfNotExists)
					return false;
				
				file = FileIOController.createIfNotExists(file.url);
				if(!file || !file.exists)
					return false;
				
				FileIOController.write(file, data, false, dataFormat);
			}
			
			if(file.isDirectory)
            {
                throw new Error("Cannot write data to directory " + file.nativePath);
                return false;
            }
			
			try
			{
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				
				stream.position = 0;
				
				switch(dataFormat)
				{
					case String:
						stream.writeUTFBytes(data as String);
						break;
					case ByteArray:
						stream.writeBytes(data as ByteArray);
						break;
					default:
						throw new Error("No data format available for type " + dataFormat);
						break;
				}
				
				stream.close();
			}
			catch(e:Error)
			{
				throw new Error("An error occurred while attempting to write data to this file.\n\nStack Trace:" + e.getStackTrace());
                return false;
			}

            return true;
		}
		
		public static function createIfNotExists(path:String):File
		{
			var newFile:File = new File(path);
			if(newFile.exists)
				return newFile;
			
			try
			{
				var stream:FileStream = new FileStream();
				stream.open(newFile, FileMode.WRITE);
                stream.writeUTFBytes("");               // empty file
				stream.close();
				
				return newFile;
			}
			catch(e:Error)
			{
				throw new Error("An error occurred while attempting to create this file.\n\nStack Trace:" + e.getStackTrace());
				return null;
			}
			finally
			{
				return newFile;
			}
		}
	}
}