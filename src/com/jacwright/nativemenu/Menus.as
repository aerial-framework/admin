package com.jacwright.nativemenu
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.system.Capabilities;
	
	public class Menus
	{
		protected static var os:String = Capabilities.os.substring(0, 3).toLowerCase();
		protected static var menus:Object = {};
		public static var registeredMenus:Object = {
			//"main": MainMenu
		};
		
		public static function getMenu(menu:String):Menu
		{
			if (menu in menus && menus[menu] is Menu)
				return menus[menu];
			
			try {
				var menuClass:Class = registeredMenus[menu];
				var menuInst:Menu = new menuClass();
				menus[menu] = menuInst;
				return menuInst;
			} catch (e:Error) {
				trace("No menu found: " + menu);
			}
			
			return null;
		}
		
		
		public static function init(registeredMenus:Object, win:NativeWindow):void
		{
			Menus.registeredMenus = registeredMenus;
			
			var mainMenu:Menu = getMenu("main");
			if (mainMenu) {
				initMainMenu(mainMenu, win);
			}
		}
		
		
		public static function initMainMenu(mainMenu:Menu, win:NativeWindow):void
		{
			
			if (NativeApplication.supportsMenu) {
				if (os == "mac") {
					// keep the application menu
					var menu:NativeMenu = NativeApplication.nativeApplication.menu;
					while (menu.numItems > 1) {
						menu.removeItemAt(1);
					}
					
					for each (var item:NativeMenuItem in mainMenu.items) {
						mainMenu.removeItem(item);
						menu.addItem(item);
					}
					
					var appMenu:NativeMenu = menu.getItemAt(0).submenu;
					
					// put the preferences in the correct place for mac
					var editMenu:NativeMenuItem = menu.getItemByName("edit");
					if (editMenu && editMenu.submenu) {
						var prefs:NativeMenuItem = editMenu.submenu.getItemByName("preferences");
						if (prefs) {
							var index:int = editMenu.submenu.getItemIndex(prefs);
							editMenu.submenu.removeItem(prefs);
							appMenu.addItemAt(prefs, 1);
							appMenu.addItemAt(editMenu.submenu.removeItemAt(index - 1), 1);
						}
					}
					
					// put the about in the correct place if it exists
					var helpMenu:NativeMenuItem = menu.getItemByName("help");
					if (helpMenu && helpMenu.submenu) {
						var about:NativeMenuItem = helpMenu.submenu.getItemByName("about");
						if (about) {
							helpMenu.submenu.removeItem(about);
							appMenu.removeItemAt(0);
							appMenu.addItemAt(about, 0);
						}
					}
					
				} else {
					NativeApplication.nativeApplication.menu = mainMenu;
				}
			} else if (NativeWindow.supportsMenu) {
				win.menu = mainMenu;
			}
		}
		
	}
}