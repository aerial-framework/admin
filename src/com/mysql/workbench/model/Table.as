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
		public var relations:Array;
		
		public function Table(xml:XML)
		{
			super(xml);
			name = String(xml.value.(@key=='name'));
			className = Inflector.singularPascalize(name);
			columns = new Array();
			foreignKeys = new Array();
			indices = new Array();
			relations = new Array();
			
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
		
		public function loadRelationHelper():void
		{
			var comment:String = String(xml.value.(@key=='comment'));
			var relation:Array = comment.match(/<aerial:(\w+).*(?:\/>|<\/aerial:\1>)/i);
			if(relation)
			{
				var relationXml:XML = XML(String(relation[0]).replace("aerial:", ""));
				var relationType:String = relation[1];
			}
			
			switch(relationType)
			{
				case "mn":{
					var relationKey:RelationKey = new RelationKey();
					var keys:Array = String(relationXml.@keys).split(/,\s*/);
					var aliases:Array = String(relationXml.@aliases).split(/,\s*/);
					
					for each(var fk:ForeignKey in this.foreignKeys)
					{
						if(keys[0] == fk.column.name)
							var key1:ForeignKey =  fk;
						if(keys[1] == fk.column.name)
							var key2:ForeignKey =  fk;
					}

					/*Set the relation's alias name*/
					if(aliases[0] && (String(aliases[0]).length > 0))
						relationKey.relationName = Inflector.pluralCamelize(aliases[0]); 
					else
					{
						relationKey.relationName = Inflector.pluralCamelize(key1.referencedTable.className);
					}
					
					/*Set the relations foreign alias name*/
					if(aliases[1] && (String(aliases[1]).length > 0))
						relationKey.foreignAlias = Inflector.pluralCamelize(aliases[1]); 
					else
					{
						relationKey.foreignAlias = Inflector.pluralCamelize(key2.referencedTable.className);
					}
					
					relationKey.referencedTable = key1.referencedTable;
					relationKey.joinTable = this;
					relationKey.joinLocal = key2.column;
					relationKey.joinForeign = key1.column;
					
					//We're adding the relation to the table of the second key/alias in the setting.
					key2.referencedTable.relations.push(relationKey);
					break;
				}
					
					
			}
		}
		
		
	}
}