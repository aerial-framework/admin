package com.mysql.workbench.model
{
	import flash.utils.Dictionary;

	public class Registry
    {
		private static var _instance:Registry;
		private var _dic:Dictionary = new Dictionary();
		
		public function Registry(enforcer:SingletonEnforcer)
		{
		}
		
		public static function getInstance():Registry
		{
			if(!_instance)
				_instance = new Registry(new SingletonEnforcer());
			
			return _instance;
		}

		public function getModel(id:String):Object
		{
			return _dic[id];
		}

		public function setModel(id:String, model:Object):void
		{
			_dic[id] = model;
		}
	}
}

class SingletonEnforcer{};