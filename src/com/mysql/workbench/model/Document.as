package com.mysql.workbench.model
{
	
	import com.mysql.workbench.Config;
	import com.mysql.workbench.DatatypeConverter;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.core.ByteArrayAsset;
	
	import nochump.util.zip.ZipFile;
	
	public class Document
	{
		public static const MWB_XML_NAME:String = "document.mwb.xml";
		public var config:Config = Config.getInstance();
		public var schemas:Array;
		public var userDefinedTypes:Dictionary;
		
		public function Document(mwbFile:ByteArrayAsset = null)
		{
			schemas = new Array();
			userDefinedTypes = new Dictionary();
			if(mwbFile)
				this.loadByteArray(mwbFile);
		}
		
		public function loadByteArray(mwbFile:ByteArrayAsset):void
		{
			var zipFile:ZipFile = new ZipFile(mwbFile);
			var ba:ByteArray = zipFile.getInput(zipFile.getEntry(MWB_XML_NAME));
			var x:XML = new XML(ba.readUTFBytes(ba.length));
			
			
			var xmlUserDefinedTypes:XMLList = x.value.value.(@key=='physicalModels').value.value.(@key=='catalog').value.(@key=='userDatatypes').value;
			var actualType:String;
			var typeId:String;
			for each(var xmlUserDefinedType:XML in xmlUserDefinedTypes)
			{
				actualType = xmlUserDefinedType.link.(@key=='actualType');
				userDefinedTypes[String(xmlUserDefinedType.@id)] = DatatypeConverter.getDataType(actualType);
			}
			
			
			//We need to change this as there can be more than one physicalModel.
			var xmlSchemas:XMLList = x.value.value.(@key=='physicalModels').value.value.(@key=='catalog').value.(@key=='schemata').value;
			
			for each(var xmlSchema:XML in xmlSchemas)
			{
				schemas.push(new Schema(this, xmlSchema));
			}
		}
	}
}




