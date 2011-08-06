package com.jacwright.nativemenu
{
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.system.Capabilities;

	[DefaultProperty("items")]
	public class Menu extends NativeMenu
	{		
		override public function set items(value:Array):void
		{
			while (numItems)
				removeItemAt(0);
			
			var os:String = Capabilities.os.substring(0, 3).toLowerCase();
			
			for each (var item:NativeMenuItem in value)
			{
				if (item is MenuItem && MenuItem(item).os && MenuItem(item).os.toLowerCase().indexOf(os) == -1)
					continue;
				
				addItem(item);
			}
		}
	}
}