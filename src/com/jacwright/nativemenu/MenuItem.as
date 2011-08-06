package com.jacwright.nativemenu
{
	import flash.display.NativeMenuItem;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;

	[DefaultProperty("items")]
	public class MenuItem extends NativeMenuItem
	{
		public var os:String;
		
		public function MenuItem()
		{
			super(null, false);
		}
		
		public override function set label(value:String):void
		{
			var index:int = value.indexOf("_");
			super.label = value;
			
			if (index != -1)
			{
				mnemonicIndex = index;
				value = value.substring(0, index) + value.substring(index + 1);
			}
			
			super.label = value;
		}
		
		public function get items():Array
		{
			if (submenu)
				return submenu.items;
			else
				return [];
		}
		
		public function set items(value:Array):void
		{
			submenu = new Menu();
			Menu(submenu).items = value;
		}
		
		public function get shortcut():String
		{
			if (!keyEquivalent && !keyEquivalentModifiers.length)
				return "";
			
			var shortcut:String = "";
			
			if (keyEquivalentModifiers.indexOf(Keyboard.COMMAND) != -1)
				shortcut += "Cmd+";
			if (keyEquivalentModifiers.indexOf(Keyboard.CONTROL) != -1)
				shortcut += "Ctrl+";
			if (keyEquivalentModifiers.indexOf(Keyboard.ALTERNATE) != -1)
				shortcut += "Alt+";
			if (keyEquivalentModifiers.indexOf(Keyboard.SHIFT) != -1)
				shortcut += "Shift+";
			
			shortcut += keyEquivalent;
			
			return shortcut;
		}
		
		public function set shortcut(value:String):void
		{
			var keys:Array = value.toLowerCase().split("+");
			var mods:Array = [];
			var theKey:String;
			var os:String = Capabilities.os.substr(0, 3).toLowerCase();
			
			for each (var key:String in keys)
			{
				if (key == "cmd" && os == "mac")
					mods.push(Keyboard.COMMAND);
				else if (key == "cmd")
					mods.push(Keyboard.CONTROL);
				else if (key == "ctrl")
					mods.push(Keyboard.CONTROL);
				else if (key == "alt")
					mods.push(Keyboard.ALTERNATE);
				else if (key == "shift")
					mods.push(Keyboard.SHIFT)
				else if (!theKey)
					theKey = key;
				else
					throw new Error(value + " is an invalid menu shortcut");
			}
			
			keyEquivalentModifiers = mods;
			keyEquivalent = theKey;
		}
	}
}