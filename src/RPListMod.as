import GUI.RPListPlayerListWindow;
import GUI.RPListShareLocationContent;
import GUI.RPListShareLocationWindow;
import com.Utils.Archive;

class RPListMod
{
	private static var SHARE_LOCATION_INTERVAL = 1000 * 60 * 5;
	
	private var _Flash: MovieClip;
	private var m_swfRoot: MovieClip;
	private var m_shareLocationWindow:RPListShareLocationWindow;
	private var m_playerListWindow:RPListPlayerListWindow;

	public function RPListMod(swfRoot: MovieClip)
	{
		// Store a reference to the root MovieClip
		m_swfRoot = swfRoot;
		_Flash = MovieClip(swfRoot);

		registerGuiElements();
	}

	public function OnLoad()
	{
		m_playerListWindow = new RPListPlayerListWindow(_Flash.attachMovie("RPListPlayerListWindow", "m_playerListWindow", _Flash.getNextHighestDepth()));
		
		shareLocation();
		setInterval(this, "shareLocation", SHARE_LOCATION_INTERVAL);
	}

	public function OnUnload()
	{
	}

	public function Activate(config: Archive)
	{
	}

	public function Deactivate(): Archive
	{
		var archive: Archive = new Archive();
		return archive;
	}

	public function shareLocation() {
		m_shareLocationWindow = new RPListShareLocationWindow(_Flash.attachMovie("RPListShareLocationWindow", "m_shareLocationWindow", _Flash.getNextHighestDepth()));
	}
	
	private function registerGuiElements()
	{
		// Browser window for sharing player's location
		Object.registerClass("RPListShareLocationWindow", RPListShareLocationWindow);
		Object.registerClass("RPListShareLocationContent", RPListShareLocationContent);
		// Browser window for displaying player list
		Object.registerClass("RPListPlayerListWindow", GUI.RPListPlayerListWindow);
		Object.registerClass("RPListPlayerListContent", GUI.RPListPlayerListContent);
	}	

}