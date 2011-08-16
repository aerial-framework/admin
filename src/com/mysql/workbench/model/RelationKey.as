package com.mysql.workbench.model
{
	import com.mysql.workbench.Inflector;
	import com.mysql.workbench.model.base.Base;
	
	public class RelationKey
	{
		public var relationName:String; //Can be an aerial:mn value
		public var referencedTable:Table;
		public var foreignAlias:String; //Can be an aerial:mn value
		public var joinTable:Table 
		public var joinLocal:Column;
		public var joinForeign:Column;
		
	}
}