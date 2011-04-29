package controllers
{
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    import mx.controls.Alert;

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

        public function read(file:File, type:Class = null):*
        {
            if(!type)
                type = String;

            if(!file.exists)
                return null;

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

        public function write(file:File, data:*, type:Class = null):Boolean
        {
            if(!type)
                type = String;

            var writeOK:Boolean = true;

            var stream:FileStream = new FileStream();

            try
            {
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
            catch(e:Error)
            {
                Alert.show("Could not write " + file.nativePath + "\nReason: " + e.message +
                                                "\n\nPlease check file permissions for " + file.parent.nativePath,
                                                "File Write Error");

                writeOK = false;
            }

            return writeOK;
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

        public function backupMulti(originals:Array, backup:File):void
        {
            var output:ZipOutput = new ZipOutput();

            for each(var original:File in originals)
            {
                var originalContents:String = this.read(original);

                var backupBytes:ByteArray = new ByteArray();
                backupBytes.writeUTFBytes(originalContents);

                var entry:ZipEntry = new ZipEntry(original.name);
                output.putNextEntry(entry);
                output.write(backupBytes);
                output.closeEntry();
            }

            output.finish();

            this.write(backup, output.byteArray, ByteArray);
        }
    }
}