import GUI.FriendsContentInjector;
import GUI.RPListPlayerListWindow;
import GUI.RPListShareLocationContent;
import GUI.RPListShareLocationWindow;
import com.Utils.Archive;
import com.GameInterface.Nametags;
import com.Utils.ID32;
import com.GameInterface.UtilsBase;
import com.GameInterface.Game.Character;

class RPListMod
{
	private static var SHARE_LOCATION_INTERVAL = 1000 * 60 * 1;

	private var _Flash: MovieClip;
	private var m_swfRoot: MovieClip;
	private var m_shareLocationWindow:RPListShareLocationWindow;
	private var m_playerListWindow:RPListPlayerListWindow;
	private var m_clientID:Number;
	private var m_clientNick:String;
	private var m_clientFName:String;
	private var m_clientLName:String;
	private var m_clientPlayfieldID:Number;
	private var m_friendsContentInjector:FriendsContentInjector;

	public static var ToonsInVicinity:Array;
	public static var URL;
	public static var PlayersURL:String;

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

		ToonsInVicinity = new Array();
		Nametags.SignalNametagAdded.Connect(SlotNameAdded, this);
		Nametags.SignalNametagRemoved.Connect(SlotNameRemoved, this);

		m_clientID = Character.GetClientCharacter().GetID().m_Instance;
		m_clientNick = Character.GetClientCharacter().GetName();
		m_clientFName = Character.GetClientCharacter().GetFirstName();
		m_clientLName = Character.GetClientCharacter().GetLastName();
		m_clientPlayfieldID = Character.GetClientCharacter().GetPlayfieldID();

		PlayersURL = "";

		var m_NameArray = _root.nametagcontroller;

		for (var proc in _root.nametagcontroller.m_NametagIncomingQueue)
		{
			var temp:ID32 = _root.nametagcontroller.m_NametagIncomingQueue[proc];
			if (temp.IsPlayer)
			{
				ToonsInVicinity.push(temp);

			}
		}

		shareLocation();
		setInterval(this, "shareLocation", SHARE_LOCATION_INTERVAL);

		// Prepare tab injector for Friends window
		m_friendsContentInjector = new FriendsContentInjector();
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

	public function shareLocation()
	{

		MakePlayersURL();
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

	function MakePlayersURL()
	{
		PlayersURL = "";
		var TempToons;
		TempToons = ToonsInVicinity;

		PlayersURL = TempToons[0].m_Instance;
		for ( var i:Number = 1 ; i < TempToons.length ; ++i )
		{
			PlayersURL = PlayersURL + "," + TempToons[i].m_Instance;
		}
		URL = "https://***REMOVED***/update?playerId=" + m_clientID +"&nick=" + m_clientNick + "&firstName=" + m_clientFName + "&lastName=" + m_clientLName + "&playfieldId=" + m_clientPlayfieldID + "&players=" + PlayersURL + "&clearInstance=true";
		UtilsBase.PrintChatText(URL);
	}

	public function SlotNameAdded(characterID:ID32)
	{
		if (characterID.IsPlayer())
		{
			ToonsInVicinity.push(characterID);
			UtilsBase.PrintChatText("SlotNameAdded - " + Character.GetCharacter(characterID).GetName() + " Length " + ToonsInVicinity.length );
		}
	}

	public function SlotNameRemoved(characterID:ID32)
	{
		for ( var i:Number = 0 ; i < ToonsInVicinity.length ; ++i )
		{
			if ( ToonsInVicinity[i].Equal( characterID ) )
			{
				ToonsInVicinity.splice( i, 1 );
				UtilsBase.PrintChatText("SlotNameRemoved [" + i +"] - " + Character.GetCharacter(characterID).GetName() + " Length " + ToonsInVicinity.length  + " Distance " + Character.GetCharacter(characterID).GetDistanceToPlayer());
			}
		}

	}
	//_root.nametagcontroller.m_NametagArray[x].m_Character.GetID()
	//https://***REMOVED***/update?playerId=123&nick=Bachelor&firstName=Peter&lastName=Bunting&playfieldId=1&players=1234,123456&clearInstance=true
}
