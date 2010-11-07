package components.config
{
	import controllers.ApplicationController;
	
	import mx.containers.FormItem;
	import mx.events.FlexEvent;
	
	import utils.ConfigurationNode;
	import utils.ConfigurationUtil;
	
	public class BaseConfigItem extends FormItem
	{
		public var node:ConfigurationNode;
		
		public function BaseConfigItem()
		{
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			this.setStyle("showEffect", "Fade");
			this.setStyle("creationCompletionEffect", "Fade");
			this.setStyle("removeEffect", "Resize");
		}

		private function creationCompleteHandler(event:FlexEvent):void
		{
			ApplicationController.instance.configModeChanged.add(modeChangeHandler);
			modeChangeHandler(ApplicationController.instance.configMode);
			
			this.label = node.label;
			this.toolTip = node.description;
		}
		
		public function modeChangeHandler(mode:String):void
		{
			// show all when mode is ADVANCED, selected nodes when mode is SIMPLE
			this.visible = this.includeInLayout = (mode == ConfigurationUtil.ADVANCED || node.category == mode);
		}
	}
}