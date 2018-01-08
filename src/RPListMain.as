import com.Utils.Archive;

class RPListMain
{
	private static var s_app: RPListMod;
	private static var ToonsInVicinity:Array;
	private static var t_app: RPListMain;

	public static function main(swfRoot:MovieClip):Void
	{

		
		ToonsInVicinity = new Array();
		
		s_app = new RPListMod(swfRoot);
		t_app = new RPListMain(swfRoot);
		
		swfRoot.onLoad = OnLoad;
		swfRoot.OnUnload = OnUnload;
		swfRoot.OnModuleActivated = OnActivated;
		swfRoot.OnModuleDeactivated = OnDeactivated;
		
	}

	public function RPListMain(swfRoot:MovieClip) 
	{ 

		
	}
	
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