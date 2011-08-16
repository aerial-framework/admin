package com.mysql.workbench
{
	import mx.utils.StringUtil;
	
	public class YamlWriter
	{
		private static var _instance:YamlWriter;
		private var _stream:String = "";
		private var _indentCount:int = 0;
		private var _indent:int = 2;
		
		public function YamlWriter() //enforcer:SingletonEnforcer   //Don't need to enforce singleton.
		{
			_stream += "---";
			addLineBreak();
		}
		
		/**
		 * Number of spaces to use for indenting.  
		 * Note: this can only be changed on an empty stream.
		 */
		public function get indent():int
		{
			return _indent;
		}
		
		/**
		 *@private
		 */
		public function set indent(value:int):void
		{
			if(_stream == "")
				_indent = value;
			else
				throw new Error("Can only change the 'indent' on an empty stream");
		}
		
		public static function getInstance():YamlWriter
		{
			if(!_instance)
				_instance = new YamlWriter();  //new SingletonEnforcer()
			return _instance;
		}
		
		public function resetStream():void
		{
			_indentCount = 0;
			_stream = "";
		}
		
		public function addLineBreak():void
		{
			_stream += "\n";
		}
		
		private function  get currentIndent():String
		{
			return StringUtil.repeat(String.fromCharCode(32), indent * _indentCount);
		}
		
		public function addNode(name:String):void
		{
			_stream += currentIndent + name + ":";
			addLineBreak();
			_indentCount++;
		}
		
		public function closeNode():void
		{
			if(_indentCount > 0)
				_indentCount--;
		}
		
		public function addKeyValue(key:String, value:*):void
		{
			if(value is Boolean)
				value = String(value);
			_stream += currentIndent + key + ": " + value;
			addLineBreak();
		}
		
		public function get stream():String
		{
			return _stream;
		}
	}
}

class SingletonEnforcer{};