package components.config
{
	import controllers.ApplicationController;
	
	import flash.events.MouseEvent;
	
	import mx.containers.FormItem;
	import mx.events.FlexEvent;
	
	import utils.ConfigurationNode;
	import utils.ConfigurationUtil;
	
	public class ConfigItem extends FormItem implements IConfigItem
	{
		public var node:ConfigurationNode;
		
		[Bindable]
		public var editable:Boolean = true;
		
		[Embed(source="../../assets/icons/dusseldorf/hire-me-16.png")]
		private var iconX:Class;
		
		public function ConfigItem()
		{
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			this.addEventListener(MouseEvent.CLICK, mouseClickHandler);
		}

		private function mouseClickHandler(event:MouseEvent):void
		{
			/*trace(this.node.raw.toXMLString());
			
			if(this.node.parentRaw)
			{
				var r:XML = this.node.raw;
				r.setChildren("hello!");
				
				trace(XML(this.node.parentRaw[this.node.nodeName][this.node.name]).toXMLString());
				trace("---------------");
				trace(XML(this.node.parentRaw[this.node.nodeName]).replace(this.node.name, r).toXMLString());
			}*/
		}

		private function creationCompleteHandler(event:FlexEvent):void
		{
			ApplicationController.instance.configModeChanged.add(modeChangeHandler);
			ApplicationController.instance.configViewChanged.add(viewChangeHandler);
			modeChangeHandler(ApplicationController.instance.configMode);
			
			this.label = node.label;
			this.setStyle("indicatorSkin", iconX);
			this.toolTip = node.description;
			
			this.required = (node && node.isAlt);
		}
		
		private function modeChangeHandler(mode:String):void
		{
			// show all when mode is ADVANCED, selected nodes when mode is SIMPLE
			this.visible = this.includeInLayout = (mode == ConfigurationUtil.ADVANCED || node.category == mode);
		}
		
		private function viewChangeHandler(mode:String, enabled:Boolean):void
		{
			this.editable = enabled;
		}
		
		public function getValue():Object
		{
			return null;
		}
	}
}