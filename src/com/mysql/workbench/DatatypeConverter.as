package com.mysql.workbench
{
	import flash.utils.Dictionary;
	
	public class DatatypeConverter
	{
		public function DatatypeConverter()
		{
		}
		
		private static var datatypes:Dictionary = new Dictionary();
		
		{
			datatypes["com.mysql.rdbms.mysql.datatype.tinyint"] = "integer(1)";
			datatypes["com.mysql.rdbms.mysql.datatype.smallint"] = "integer(2)";
			datatypes["com.mysql.rdbms.mysql.datatype.mediumint"] = "integer(3)";
			datatypes["com.mysql.rdbms.mysql.datatype.int"] = "integer(4)";
			datatypes["com.mysql.rdbms.mysql.datatype.bigint"] = "integer(8)";
			datatypes["com.mysql.rdbms.mysql.datatype.float"] = "float";
			datatypes["com.mysql.rdbms.mysql.datatype.double"] = "double";
			datatypes["com.mysql.rdbms.mysql.datatype.decimal"] = "decimal";
			datatypes["com.mysql.rdbms.mysql.datatype.char"] = "char";
			datatypes["com.mysql.rdbms.mysql.datatype.varchar"] = "string";
			datatypes["com.mysql.rdbms.mysql.datatype.binary"] = "binary";
			datatypes["com.mysql.rdbms.mysql.datatype.varbinary"] = "varbinary";
			datatypes["com.mysql.rdbms.mysql.datatype.tinytext"] = "clob(255)";
			datatypes["com.mysql.rdbms.mysql.datatype.text"] = "clob(65535)";
			datatypes["com.mysql.rdbms.mysql.datatype.mediumtext"] = "clob(16777215)";
			datatypes["com.mysql.rdbms.mysql.datatype.longtext"] = "clob";
			datatypes["com.mysql.rdbms.mysql.datatype.tinyblob"] = "blob(255)";
			datatypes["com.mysql.rdbms.mysql.datatype.blob"] = "blob(65535)";
			datatypes["com.mysql.rdbms.mysql.datatype.mediumblob"] = "blob(16777215)";
			datatypes["com.mysql.rdbms.mysql.datatype.longblob"] = "blob";
			datatypes["com.mysql.rdbms.mysql.datatype.datetime"] = "timestamp";
			datatypes["com.mysql.rdbms.mysql.datatype.date"] = "date";
			datatypes["com.mysql.rdbms.mysql.datatype.time"] = "time";
			datatypes["com.mysql.rdbms.mysql.datatype.year"] = "integer(2)";
			datatypes["com.mysql.rdbms.mysql.datatype.timestamp"] = "timestamp";
			datatypes["com.mysql.rdbms.mysql.datatype.geometry"] = "geometry";
			datatypes["com.mysql.rdbms.mysql.datatype.linestring"] = "linestring";
			datatypes["com.mysql.rdbms.mysql.datatype.polygon"] = "polygon";
			datatypes["com.mysql.rdbms.mysql.datatype.multipoint"] = "multipoint";
			datatypes["com.mysql.rdbms.mysql.datatype.multilinestring"] = "multilinestring";
			datatypes["com.mysql.rdbms.mysql.datatype.multipolygon"] = "multipolygon";
			datatypes["com.mysql.rdbms.mysql.datatype.geometrycollection"] = "geometrycollection";
			datatypes["com.mysql.rdbms.mysql.datatype.bit"] = "bit";
			datatypes["com.mysql.rdbms.mysql.datatype.enum"] = "enum";
			datatypes["com.mysql.rdbms.mysql.datatype.set"] = "set";
			
			// userdatatypes
			datatypes["com.mysql.rdbms.mysql.userdatatype.boolean"] = "boolean";
			datatypes["com.mysql.rdbms.mysql.userdatatype.bool"] = "boolean";
			datatypes["com.mysql.rdbms.mysql.userdatatype.fixed"] = "decimal";
			datatypes["com.mysql.rdbms.mysql.userdatatype.float4"] = "float";
			datatypes["com.mysql.rdbms.mysql.userdatatype.float8"] = "double";
			datatypes["com.mysql.rdbms.mysql.userdatatype.int1"] = "integer(1)";
			datatypes["com.mysql.rdbms.mysql.userdatatype.int2"] = "integer(2)";
			datatypes["com.mysql.rdbms.mysql.userdatatype.int3"] = "integer(3)";
			datatypes["com.mysql.rdbms.mysql.userdatatype.int4"] = "integer(4)";
			datatypes["com.mysql.rdbms.mysql.userdatatype.int8"] = "integer(8)";
			datatypes["com.mysql.rdbms.mysql.userdatatype.integer"] = "integer(4)";
			datatypes["com.mysql.rdbms.mysql.userdatatype.longvarbinary"] = "blob(16777215)";
			datatypes["com.mysql.rdbms.mysql.userdatatype.longvarchar"] = "clob(16777215)";
			datatypes["com.mysql.rdbms.mysql.userdatatype.long"] = "clob(16777215)";
			datatypes["com.mysql.rdbms.mysql.userdatatype.middleint"] = "integer(3)";
			datatypes["com.mysql.rdbms.mysql.userdatatype.numeric"] = "decimal";
			datatypes["com.mysql.rdbms.mysql.userdatatype.dec"] = "decimal";
			datatypes["com.mysql.rdbms.mysql.userdatatype.character"] = "char";
			
		}
		
		public static function getDataType(mysqlType:String):String
		{
			if(datatypes.hasOwnProperty(mysqlType))
				return datatypes[mysqlType];
			else
				return null;
		}
		
	}
}