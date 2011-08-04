package com.mysql.workbench.model
{
	import com.mysql.workbench.Inflector;
	import com.mysql.workbench.model.base.Base;
	
	public class Table extends Base
	{
		public var name:String;
		public var className:String;
		public var columns:Array;
		public var foreignKeys:Array;
		public var indices:Array;

		public function Table(xml:XML)
		{
			super(xml);
			name = String(xml.value.(@key=='name'));
			className = Inflector.singularPascalize(name);
			columns = new Array();
			foreignKeys = new Array();
			indices = new Array();
			
			/*Set Columns*/
			var xmlColumns:XMLList = xml.value.(@key=='columns').value;
			for each(var xmlColumn:XML in xmlColumns)
			{
				columns.push(new Column(xmlColumn));
			}
		}
		
		public function loadForeignKeys():void
		{
			var xmlFKs:XMLList = xml.value.(@key=='foreignKeys').value;
			for each(var xmlFK:XML in xmlFKs)
			{
				foreignKeys.push(new ForeignKey(xmlFK));
			}
		}
		
		public function loadIndices():void
		{
			var xmlIndices:XMLList = xml.value.(@key=='indices').value;
			for each(var xmlIndex:XML in xmlIndices)
			{
				indices.push(new Index(xmlIndex));
			}
		}
		
		
	}
}