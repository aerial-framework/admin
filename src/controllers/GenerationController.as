package controllers
{
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import models.GenerationOptions;

    public class GenerationController
    {
        private static var options:GenerationOptions;

        public static function generate(options:GenerationOptions):void
        {
            GenerationController.options = options;

            if(options.bootstrapPath)
            {
                generateBootstrapper();
            }
        }

        private static function generateBootstrapper():void
        {
            //log.dispatch("Initiating Bootstrapper generation", "process");

			var template:String = getTemplate("bootstrap.tmpl");
			var replacementTokens:Object = {};

            var bootstrapPackage:String = options.basePath.getRelativePath(options.bootstrapPath);
            var offset:int = bootstrapPackage.indexOf("src_flex");
            if(offset != -1)
                offset += ("src_flex").length + 1;
            else
                offset = 0;

            bootstrapPackage = bootstrapPackage.substring(offset);
            bootstrapPackage = bootstrapPackage.replace(new RegExp(File.separator, "gi"), ".");

			replacementTokens["package"] = bootstrapPackage;
			replacementTokens["class"] = "Aerial";

			var bootstrapConsts:Array = ProjectController.instance.getBootstrapValues();

			replacementTokens["configValues"] = [];
			for each(var item:Object in bootstrapConsts)
			{
				var type:String = getConstType(item.value);
				var value:String = item.value;

				if(type == "String")
					value = '"' + value + '"';

				replacementTokens["configValues"].push("\t\tpublic static const " +
												sanitizeConstName(item.name) + ":" + type + " = " + value + ";");
			}

			replacementTokens["configValues"] = replacementTokens["configValues"].join("\n");

			for(var property:String in replacementTokens)
				template = template.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);

            trace(options.bootstrapPath.resolvePath(replacementTokens["class"] + ".as").nativePath);
            FileIOController.write(options.bootstrapPath.resolvePath(replacementTokens["class"] + ".as"), template);
        }

		private static function sanitizeConstName(name:String):String
		{
			return name.replace("-", "_").toUpperCase();
		}

		private static function getConstType(value:String):String
		{
			var type:String = "String";
			if(value == "true" || value == "false")
				return "Boolean";

			return type;
		}

		private static function getTemplate(filename:String):String
		{
			var file:File = File.applicationDirectory.resolvePath("codegen/templates/" + filename);
			if(!file.exists)
				throw new Error("No template file found at " + file.nativePath);

			//log.dispatch("Using " + file.name + " template", "info");

			return FileIOController.read(file, false, String).toString();
		}
    }
}