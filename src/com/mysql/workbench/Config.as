package com.mysql.workbench
{
	public class Config
	{
		private static var _instance:Config;
		
		public var extendTableNameWithSchemaName:Boolean = false;
		public var defaultCharacterSetName:String = "utf8";
		
		public function Config(enforcer:SingletonEnforcer){}
		
		public static function getInstance():Config
		{
			if(!_instance)
				_instance = new Config(new SingletonEnforcer());
			
			return _instance;
		}
		
	}
}

class SingletonEnforcer{};