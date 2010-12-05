package components.backuprestore
{
    import flash.events.Event;
    
    import mx.controls.CheckBox;
    import mx.core.UIComponent;
    
    import org.as3commons.lang.ClassUtils;

    public class CheckBoxSelector extends CheckBox
    {
        public var children:Array;

        public function CheckBoxSelector()
        {
            this.addEventListener(Event.CHANGE, changeHandler);
        }

		private function changeHandler(event:Event):void
		{
			setChildren();
		}
		
        private function setChildren():void
        {
			trace("Setting children of " + this.id + " to " + this.selected);
            for each(var child:Object in children)
			{
                child.selected = this.selected;
				trace(ClassUtils.forInstance(child) + " > " + child.id + " > " + child.selected);
				
				if(child is CheckBoxSelector)
					child.setChildren();
			}
        }
    }
}