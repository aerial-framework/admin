package utils
{
	public class PermissionsUtil
	{
		public static const NONE:String = "none";
		public static const EXECUTE:String = "execute";
		public static const WRITE:String = "write";
		public static const READ:String = "read";
		
		/**
		 * @see http://snap.nlc.dcccd.edu/learn/madden/intro/perms.html
		 */
		public static function parsePermissions(permissions:String):Object
		{
			// Permissions must be in octal format (see http://php.net/manual/en/function.chmod.php)
			if(permissions.length < 4)
				return null;
				
			var split:Array = permissions.split("");
			
			// validate (ignore first number)
			for(var i:uint = 1; i < split.length; i++)
			{
				if(int(split[i]) > 7)
					return null;
				
				split[i] = uint(split[i]);
			}
			
			var data:Object = {};
			
			data["user"] = parseMode(split[1]);
			data["group"] = parseMode(split[2]);
			data["other"] = parseMode(split[3]);
			
			return data;
		}
		
		public static function getPermissions(modes:Object):String
		{
			var permissions:String = "0";
			permissions += parsePermission(modes["user"]);
			permissions += parsePermission(modes["group"]);
			permissions += parsePermission(modes["other"]);
			
			return permissions;
		}
		
		public static function parsePermission(permissions:Array):String
		{
			switch(permissions.join(","))
			{
				case NONE:
				default:
					return "0";
					break;
				case EXECUTE:
					return "1";
					break;
				case WRITE:
					return "2";
					break;
				case EXECUTE + "," + WRITE:
					return "3";
					break;
				case READ:
					return "4";
					break;
				case EXECUTE + "," + READ:
					return "5";
					break;
				case WRITE + "," + READ:
					return "6";
					break;
				case EXECUTE + "," + WRITE + "," + READ:
					return "7";
					break;
			}
		}
		
		public static function parseMode(mode:uint):Array
		{
			switch(mode)
			{
				case 0:
				default:
					return [NONE];
					break;
				case 1:
					return [EXECUTE];
					break;
				case 2:
					return [WRITE];
					break;
				case 3:
					return [EXECUTE, WRITE];
					break;
				case 4:
					return [READ];
					break;
				case 5:
					return [EXECUTE, READ];
					break;
				case 6:
					return [WRITE, READ];
					break;
				case 7:
					return [EXECUTE, WRITE, READ];
					break;
			}
		}
	}
}