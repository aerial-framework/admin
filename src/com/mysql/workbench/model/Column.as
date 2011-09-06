package com.mysql.workbench.model
{
	import com.mysql.workbench.DatatypeConverter;
	import com.mysql.workbench.Inflector;
	import com.mysql.workbench.model.base.Base;
	
	public class Column extends Base
	{
		public var name:String;
		public var propertyName:String;
		public var type:String;
		public var autoIncrement:Boolean = false;
		public var defaultValue:String;
		public var isNotNull:Boolean = false;
		public var isPrimary:Boolean = false;
		public var isUnique:Boolean = false;
		public var owner:Table;
		
		public function Column(xml:XML)
		{
			super(xml);
			
			var ownerId:String = XMLList(xml.link.(@key=="owner")).toString();
			owner = Registry.getInstance().getModel(ownerId) as Table;
			
			name = xml.value.(@key=='name');
			propertyName = Inflector.singularCamelize(name);
			
			if(XMLList(xml.link.(@key == 'simpleType')).length() > 0)
			{
				type = DatatypeConverter.getDataType(xml.link.(@key == 'simpleType'));
			}
			else
			{
				type = DatatypeConverter.getDataType(xml.link.(@key == 'userType'));
				if(!type)
					type = this.owner.schema.document.userDefinedTypes[XMLList(xml.link.(@key == 'userType')).toString()];
			}
			
			isNotNull = Boolean(int(xml.value.(@key=='isNotNull')));
			autoIncrement = Boolean(int(xml.value.(@key=='autoIncrement')));
			defaultValue = xml.value.(@key == 'defaultValue');
			
			var typeLength:int = int(xml.value.(@key == 'length'));
			if(typeLength != -1)
				type += "(" + String(typeLength) + ")";
			
			
		}
	}
}