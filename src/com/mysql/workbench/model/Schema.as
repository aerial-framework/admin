package com.mysql.workbench.model
{
	import com.mysql.workbench.Inflector;
	import com.mysql.workbench.YamlWriter;
	
	public class Schema
	{
		public var name:String;
		public var tables:Array;
		public var views:Array;
		public var defaultCollationName:String;
		public var defaultCharacterSetName:String;
		
		
		public function Schema(xml:XML = null)
		{
			/*Set Schema name*/
			name = String(xml.value.(@key=='name'));
			defaultCollationName = String(xml.value.(@key=='defaultCollationName'));
			defaultCharacterSetName = String(xml.value.(@key=='defaultCharacterSetName'));
			tables = new Array();
			views = new Array();
			
			/*Set Tables & Columns*/
			var xmlTables:XMLList = xml.value.(@key=='tables').value;
			for each(var xmlTable:XML in xmlTables)
			{
				tables.push(new Table(xmlTable));
			}
			
			/*Set PK's & ForeignKeys*/
			for each(var table:Table in tables)
			{
				table.loadForeignKeys();
				table.loadIndices();
			}
			
			/*Set Views*/  //Not implemented yet
			var xmlViews:XML = xml.value.(@key=='views')[0];
			for each(var xmlView:XML in xmlViews)
			{
				views.push(new View(xmlView));
			}
		}
		
		public function get yaml():String
		{
			var yaml:YamlWriter = YamlWriter.getInstance();
			yaml.addKeyValue("detect_relations", true);
			yaml.addNode("options");
			yaml.addKeyValue("collate", this.defaultCollationName);
			yaml.addKeyValue("charset", this.defaultCharacterSetName);
			yaml.addKeyValue("type", "InnoDB");
			yaml.closeNode();
			yaml.addLineBreak();
			
			for each (var table:Table in this.tables)
			{
				yaml.addNode(table.className);
				yaml.addKeyValue("tableName", table.name);
				
				if(table.columns.length > 0)
					yaml.addNode("columns");
				for each (var column:Column in table.columns)
				{
					yaml.addNode(column.name);
					if(column.name != column.propertyName)
						yaml.addKeyValue("name", column.name + " as " + column.propertyName);
					yaml.addKeyValue("type", column.type);
					if(column.isPrimary)
						yaml.addKeyValue("primary", column.isPrimary);
					if(column.isNotNull == true)
						yaml.addKeyValue("notnull", column.isNotNull);
					if(column.autoIncrement == true)
						yaml.addKeyValue("autoincrement", column.autoIncrement);
					if(column.defaultValue)
						yaml.addKeyValue("default", column.defaultValue);
					yaml.closeNode();//Column End
				}
				yaml.closeNode();//Columns End
				
				if(table.foreignKeys.length > 0)
					yaml.addNode("relations");
				for each(var fk:ForeignKey in table.foreignKeys)
				{  
					yaml.addNode(fk.columnClassName);
					yaml.addKeyValue("class", fk.referencedTable.className);
					yaml.addKeyValue("local", fk.column.name);
					yaml.addKeyValue("foreign", fk.referencedColumn.name);
					yaml.addKeyValue("foreignAlias", Inflector.pluralCamelize(table.className)); 
					yaml.closeNode();//FK's End
				}
				yaml.closeNode();//Relations End
				
				var addedIndexNode:Boolean = false;
				for each(var index:Index in table.indices)
				{  
					if(index.indexType == "INDEX")
					{
						if(!addedIndexNode)
						{
							addedIndexNode = true;
							yaml.addNode("indexes");
						}
						yaml.addNode(index.name);
						var colArray:Array = new Array();
						for each(var col:Column in index.columns)
						{
							colArray.push(col.name);
						}
						yaml.addKeyValue("fields", "[" + colArray.join(", ") + "]");
						yaml.closeNode();//Index End
					}
				}
				yaml.closeNode();//Indexes End
				
				yaml.closeNode();//Table End
				yaml.addLineBreak(); 
			}
			return yaml.stream;
		}
	}
}