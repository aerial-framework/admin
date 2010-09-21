package controllers
{
	import flash.events.EventDispatcher;
	import flash.net.sendToURL;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	[Event(name="result", type="mx.rpc.events.ResultEvent")]
	[Event(name="fault", type="mx.rpc.events.FaultEvent")]
	public class CoreVersionController extends EventDispatcher
	{
		private static var _instance:CoreVersionController;
		
		private static var service:HTTPService;
		private static var data:XML;
		
		public static function get instance():CoreVersionController
		{
			if(!_instance)
				_instance = new CoreVersionController();
			
			return _instance;
		}
		
		public function check():void
		{
			service = new HTTPService();
			service.url = "http://aerial-project.org/core-version.xml";
			service.resultFormat = "e4x";
			service.addEventListener(ResultEvent.RESULT, result);
			service.addEventListener(FaultEvent.FAULT, fault);
			
			service.send();
		}
		
		public function get latest():Object
		{
			var info:Object = {};
			for each(var property:XML in data.latest.children())
				info[property.name()] = property.text().toString();
				
			return info;
		}
		
		private function result(event:ResultEvent):void
		{
			data = event.result as XML;
			dispatchEvent(event);
		}
		
		private function fault(event:FaultEvent):void
		{
			dispatchEvent(event);
		}
	}
}