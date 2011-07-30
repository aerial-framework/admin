package controllers
{
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import models.FieldDefinition;

    import models.GenerationOptions;
    import models.ModelDefinition;

    import mx.controls.Alert;

    public class GenerationController
    {
        private static var options:GenerationOptions;
		private static var primitives:Array = ["int", "Number", "uint", "Boolean", "Object", "Array", "String", "Date", "ByteArray"];
		private static var imports:Object = {};

        public static function generate(options:GenerationOptions):void
        {
            GenerationController.options = options;

			imports["ByteArray"] = "flash.utils.ByteArray";
			imports["ArrayCollection"] = "mx.collections.ArrayCollection";
            
            var hasModelsSelected:Boolean = options.selectedModels.length > 0;

            if(options.generateBootstrap)
            {
                generateBootstrapper();
            }

            if(options.generatePHPModels)
            {
                if(hasModelsSelected)
                    generatePHPModels();
                else
                {
                    fireSelectionError();
                    return;
                }
            }

            if(options.generatePHPServices)
            {
                if(hasModelsSelected)
                    generatePHPServices();
                else
                {
                    fireSelectionError();
                    return;
                }
            }

            if(options.generateAS3Models)
            {
                if(hasModelsSelected)
                    generateAS3Models();
                else
                {
                    fireSelectionError();
                    return;
                }
            }

            if(options.generateAS3Services)
            {
                if(hasModelsSelected)
                    generateAS3Services();
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

            var bootstrapPackage:String = getPackageString(options.basePath.getRelativePath(options.bootstrapPath), "src_flex");

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

            for each(var definition:ModelDefinition in options.selectedModels)
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

            for each(var definition:ModelDefinition in options.selectedModels)
            {
                var replacementTokens:Object = {};
                var className:String = definition.modelName + options.serviceSuffix;

                replacementTokens["model"] = definition.modelName;
                replacementTokens["class"] = className;

                var data:String = template;
                for(var property:String in replacementTokens)
                    data = data.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);

                if(FileIOController.write(options.phpServicesPath.resolvePath(className + ".php"), data))
                    writeOK = true;
            }

            if(!writeOK)
                firePermissionsError(options.phpServicesPath, "PHP services");
        }

        private static function generateAS3Models():void
        {
            var writeOK:Boolean = false;

            var template:String = getTemplate("as3.vo.tmpl");
            var replacementTokens:Object = {};

            var packageString:String = getPackageString(options.basePath.getRelativePath(options.as3ModelsPath), "src_flex");
            var phpModelsPackageString:String = getPackageString(options.phpModelsPath.nativePath, "src_php");

            for each(var definition:ModelDefinition in options.selectedModels)
            {
                replacementTokens["package"] =              packageString.replace(/[\/\\]/gi, ".");
                replacementTokens["collectionImport"] =     "";
                replacementTokens["class"] =                definition.modelName + options.voSuffix;
                replacementTokens["remoteClass"] =          phpModelsPackageString + "." + definition.modelName;

                var properties:Array = [];
                var accessors:Array = [];

                var accessorStub:String = getPart("all.xml", "as3AccessorStub");

                var toImport:Array = [];
                for each(var field:FieldDefinition in definition.fields)
                {
                    var name:String = field.name;
                    var many:Boolean = field.many && field.isRelation;

                    var type:String;

                    if(many)
                        type = "IList";
                    else
                    {
                        type = field.type;

                        // if the type is not primitive, add the VO suffix
                        if(primitives.indexOf(type) == -1)
                            type += options.voSuffix;

                        // Convert int to Number.  This fixes a bug where Flash won't hit the setter if you're trying to
                        // set a zero value because * type retruns zero from the getter.
                        if(type == "int" || type == "uint")
                            type = "Number";
                    }

                    if(imports[type])            // if this type has a specific import string
                    {
                        var str:String = "import " + imports[type] + ";";
                        if(toImport.indexOf(str) == -1)
                            toImport.push(str);
                    }

                    properties.push("\t\tprivate var _" + name + ":*\n");

                    var accessor:String = accessorStub.replace(new RegExp("{{field}}", "gi"), name);
                    accessor = accessor.replace(new RegExp("{{type}}", "gi"), type);

                    accessors.push(accessor);
                }

                replacementTokens["collectionImport"] += toImport.join("\n\t");

                replacementTokens["privateVars"] = properties.join("");
                replacementTokens["accessors"] = accessors.join("\n");

                var data:String = template;
                for(var property:String in replacementTokens)
                    data = data.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);

                if(FileIOController.write(options.as3ModelsPath.resolvePath(definition.modelName + options.voSuffix + ".as"), data))
                    writeOK = true;
            }

            if(!writeOK)
                firePermissionsError(options.as3ModelsPath, "ActionScript models");
        }

		private static function generateAS3Services():void
		{
            var writeOK:Boolean = false;

			var template:String = getTemplate("as3.service.tmpl");
			var replacementTokens:Object = {};

            var modelPackageString:String = getPackageString(options.basePath.getRelativePath(options.as3ModelsPath), "src_flex");
            var servicePackageString:String = getPackageString(options.basePath.getRelativePath(options.as3ServicesPath), "src_flex");
            var bootstrapPackageString:String = getPackageString(options.basePath.getRelativePath(options.bootstrapPath), "src_flex");

            for each(var definition:ModelDefinition in options.selectedModels)
            {
                replacementTokens["model"] = 				definition.modelName + options.voSuffix;
                replacementTokens["class"] = 				definition.modelName + options.serviceSuffix;
                replacementTokens["package"] = 				servicePackageString.replace(/[\/\\]/gi, ".");
                replacementTokens["modelPackage"] = 		modelPackageString.replace(/[\/\\]/gi, ".");
                replacementTokens["bootstrapPackage"] = 	bootstrapPackageString.replace(/[\/\\]/gi, ".");
                replacementTokens["bootstrapClass"] = 		"Aerial";

                trace(definition.modelName + " > " + replacementTokens["model"] + " > " + replacementTokens["class"]);

                var data:String = template;
                for(var property:String in replacementTokens)
                    data = data.replace(new RegExp("{{" + property + "}}", "gi"), replacementTokens[property]);

                if(FileIOController.write(options.as3ServicesPath.resolvePath(definition.modelName + options.serviceSuffix + ".as"), data))
                    writeOK = true;
            }

            if(!writeOK)
                firePermissionsError(options.as3ServicesPath, "ActionScript services");
		}

        private static function getPackageString(path:String, keyElement:String):String
        {
            var offset:int = path.indexOf(keyElement);
            if(offset != -1)
                offset += (keyElement).length + 1;
            else
                offset = 0;

            var toReturn:String = path.substring(offset);
            toReturn = toReturn.replace(/[\/\\]/gi, ".");

            return toReturn;
        }

        private static function firePermissionsError(path:File, fileType:String):void
        {
            if(path)
            {
                Alert.show("Could not write " + fileType + " to " + path.nativePath + ". Please ensure that this " +
                        "path exists and is owned by the correct user & group.", "Error");
            }
            else
            {
                Alert.show("Could not write " + fileType + ". Please ensure that the " + fileType + " " +
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

		private static function getPart(filename:String, match:String):String
		{
			var file:File = File.applicationDirectory.resolvePath("codegen/parts/" + filename);
			var content:XML = new XML(FileIOController.read(file, false));
            
            try
            {
                var part:XML = XML(content.part.(attribute("name") == match));
                if(part)
                    return part.content.text();
            }
            catch(e:Error)
            {
                return null;
            }

			return null;
		}
    }
}