package com.mysql.workbench.model
{
	import com.mysql.workbench.Inflector;
	import com.mysql.workbench.model.base.Base;
	
	public class ForeignKey
	{
		public var name:String;
		public var column:Column;
		public var columnClassName:String;
		public var referencedTable:Table;
		public var referencedColumn:Column;
		
		public function ForeignKey(xml:XML)
		{
			name = xml.value.(@key=='name');
			column = Registry.getInstance().getModel(xml.value.(@key=='columns').link[0].toString()) as Column;
			
			//We base the class name of the relationship off the fk column.
			if(column.name.substr(-2, 2) == "Id")
				columnClassName = column.name.substr(0,column.name.length - 2);
			columnClassName = Inflector.singularPascalize(columnClassName);
			
			referencedTable = Registry.getInstance().getModel(xml.link.(@key=='referencedTable').toString()) as Table;
			referencedColumn = Registry.getInstance().getModel(xml.value.(@key=='referencedColumns').link[0].toString()) as Column;
		}
	}
}