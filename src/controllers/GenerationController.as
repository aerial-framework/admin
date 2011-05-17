package controllers
{
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import models.GenerationOptions;
    import models.ModelDefinition;

    import mx.controls.Alert;

    public class GenerationController
    {
        private static var options:GenerationOptions;

        public static function generate(options:GenerationOptions):void
        {
            GenerationController.options = options;
            var hasModelsSelected:Boolean = options.phpModels.length > 0;

            if(options.bootstrapPath)
            {
                generateBootstrapper();
            }

            if(options.phpModelsPath)
            {
                if(hasModelsSelected)
                    generatePHPModels();
                else
                {
                    fireSelectionError();
                    return;
                }
            }

            if(options.phpServicesPath)
            {
                if(hasModelsSelected)
                    generatePHPServices();
                else
                {
                    fireSelectionError();
                    return;
                }
            }
        }

        private static function fireSelectionError():void
        {
            Alert.show("Please select one or more models to generate.", "Error");
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

            if(!FileIOController.write(options.bootstrapPath.resolvePath(replacementTokens["class"] + ".as"), template))
                firePermissionsError(options.phpModelsPath, "Bootstrap file");
        }

        /**
         * Uses definitions from Doctrine
         *
         * @return
         */
        private static function generatePHPModels():void
        {
            var writeOK:Boolean = false;

            for each(var definition:ModelDefinition in options.phpModels)
            {
                var className:String = definition.modelName;
                var derivedFile:File = options.phpModelsPath.resolvePath(className + ".php");
                var baseFile:File = options.phpModelsPath.resolvePath("base" + File.separator + "Base" + className + ".php");

                var derived:Boolean = FileIOController.write(derivedFile, definition.phpModel.content);
                var base:Boolean = FileIOController.write(baseFile, definition.phpBaseModel.content);

                if(derived && base)
                    writeOK = true;
            }

            if(!writeOK)
                firePermissionsError(options.phpModelsPath, "PHP models");
        }

		private static function generatePHPServices():void
		{
			var template:String = getTemplate("php.service.tmpl");

            var writeOK:Boolean = false;

            for each(var definition:ModelDefinition in options.phpModels)
            {
                var replacementTokens:Object = {};
                var className:String = definition.modelName + options.serviceSuffix;

                replacementTokens["model"] = definition.modelName;
                replacementTokens["class"] = className;

                for(var property:String in replacementTokens)
                    template = template.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);

                if(FileIOController.write(options.phpServicesPath.resolvePath(className + ".php"), template))
                    writeOK = true;
            }

            if(!writeOK)
                firePermissionsError(options.phpServicesPath, "PHP services");
		}

        private static function firePermissionsError(path:File, fileType:String):void
        {
            if(path)
            {
                Alert.show("Could not write " + fileType + " to " + path.nativePath + ". Please ensure that this " +
                        "path exists and is owned by the correct user & group.", "Error");
            }
            else
            {Alert.show("Could not write " + fileType + ". Please ensure that the " + fileType + " " +
                        "path exists and is owned by the correct user & group.", "Error");
            }
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