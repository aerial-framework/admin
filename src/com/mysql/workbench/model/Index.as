package com.mysql.workbench.model
{
	public class Index
	{
		public var name:String;
		public var indexType:String;
		public var columns:Array;
		public var isPrimary:Boolean = false;
		public var isUnique:Boolean = false;
		
		public function Index(xml:XML)
		{
			name = xml.value.(@key=='name');
			indexType = xml.value.(@key=='indexType');
			isPrimary = Boolean(int(xml.value.(@key=='isPrimary')));
			isUnique = Boolean(int(xml.value.(@key=='unique')));
			columns = new Array();
			
			var xmlColumns:XMLList = xml.value.(@key=='columns').value;
			for each(var xmlColumn:XML in xmlColumns)
			{
				var columnId:String = xmlColumn.link.(@key=='referencedColumn').toString();
				var column:Column = Registry.getInstance().getModel(columnId) as Column;
				if(isPrimary)
					column.isPrimary = true;
				columns.push(column);
			}
			
		}
	}
}