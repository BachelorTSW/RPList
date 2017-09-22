import com.Utils.Archive;

class RPListMain
{
	private static var s_app: RPListMod;

	public static function main(swfRoot:MovieClip):Void
	{
		s_app = new RPListMod(swfRoot);

		swfRoot.onLoad = OnLoad;
		swfRoot.OnUnload = OnUnload;
		swfRoot.OnModuleActivated = OnActivated;
		swfRoot.OnModuleDeactivated = OnDeactivated;
	}

	public function RPListMain() { }

	public static function OnLoad()
	{
		s_app.OnLoad();
	}

	public static function OnUnload()
	{
		s_app.OnUnload();
	}

	public static function OnActivated(config: Archive)
	{
		s_app.Activate(config);
	}

	public static function OnDeactivated(): Archive
	{
		return s_app.Deactivate();
	}
}