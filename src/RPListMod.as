import GUI.RPListFriendsContentInjector;
import GUI.RPListGetRoleplayersContent;
import GUI.RPListGetRoleplayersWindow;
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
	private static var AGARTHA_PLAYFIELD_ID:Number = 5060;

	private var _Flash: MovieClip;
	private var m_swfRoot: MovieClip;
	private var m_shareLocationWindow:RPListShareLocationWindow;
	private var m_clientID:Number;
	private var m_clientNick:String;
	private var m_clientFName:String;
	private var m_clientLName:String;
	private var m_lastClientPlayfieldID:Number;
	private var m_friendsContentInjector:RPListFriendsContentInjector;
	private var m_zoneChanged:Boolean;

	public static var ToonsInVicinity:Array;
	public static var URL;
	public static var PlayersURL:String;

	public function RPListMod(swfRoot: MovieClip)
	{
		// Store a reference to the root MovieClip
		m_swfRoot = swfRoot;
		_Flash = MovieClip(swfRoot);

		m_zoneChanged = true;
		registerGuiElements();
	}

	public function OnLoad()
	{
		ToonsInVicinity = new Array();
		Nametags.SignalNametagAdded.Connect(SlotNameAdded, this);
		Nametags.SignalNametagUpdated.Connect(SlotNameAdded, this);
		Nametags.SignalNametagRemoved.Connect(SlotNameRemoved, this);
		Nametags.SignalAllNametagsRemoved.Connect(SlotAllNamesRemoved, this);
		UtilsBase.SignalSplashScreenActivated.Connect(SlotSplashScreenActivated, this);

		m_clientID = Character.GetClientCharacter().GetID().m_Instance;
		m_clientNick = Character.GetClientCharacter().GetName();
		m_clientFName = Character.GetClientCharacter().GetFirstName();
		m_clientLName = Character.GetClientCharacter().GetLastName();
		m_lastClientPlayfieldID = -1;

		PlayersURL = "";

		var m_NameArray = _root.nametagcontroller;

		// Ignore for Agartha - everyone is in same instance
		if (Character.GetClientCharacter().GetPlayfieldID() != AGARTHA_PLAYFIELD_ID)
		{
			for (var proc in _root.nametagcontroller.m_NametagIncomingQueue)
			{
				var temp:ID32 = _root.nametagcontroller.m_NametagIncomingQueue[proc];
				if (temp.IsPlayer() && temp.m_Instance != m_clientID)
				{
					ToonsInVicinity.push(temp);
				}
			}
		}

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

		// Browser window for getting list of roleplayers
		Object.registerClass("RPListGetRoleplayersWindow", RPListGetRoleplayersWindow);
		Object.registerClass("RPListGetRoleplayersContent", RPListGetRoleplayersContent);

		// Prepare tab injector for Friends window
		m_friendsContentInjector = new RPListFriendsContentInjector(_Flash);
	}

	function MakePlayersURL()
	{
		var currentPlayfieldID:Number = Character.GetClientCharacter().GetPlayfieldID();

		URL = "https://***REMOVED***/update?playerId=" + m_clientID +"&nick=" + m_clientNick + "&firstName=" + m_clientFName + "&lastName=" + m_clientLName + "&playfieldId=" + currentPlayfieldID;

		if (m_zoneChanged)
		{
			// Player has changed zones since last update
			URL = URL + "&clearInstance=true";
			m_zoneChanged = false;
		}
		else if (ToonsInVicinity.length > 0)
		{
			URL = URL + "&players=" + ToonsInVicinity[0].m_Instance;
			for ( var i:Number = 1 ; i < ToonsInVicinity.length ; ++i )
			{
				URL = URL + "," + ToonsInVicinity[i].m_Instance;
			}
		}
		
		UtilsBase.PrintChatText("URL: " + URL);

		m_lastClientPlayfieldID = currentPlayfieldID;
	}

	public function SlotNameAdded(characterID:ID32)
	{
		// Ignore for Agartha - everyone is in same instance
		if (Character.GetClientCharacter().GetPlayfieldID() != AGARTHA_PLAYFIELD_ID)
		{
			if (characterID.IsPlayer() && !characterID.Equal(Character.GetClientCharacter().GetID()))
			{
				for (var i:Number = 0; i < ToonsInVicinity.length; ++i)
				{
					// Avoid duplicates
					if (ToonsInVicinity[i].Equal(characterID))
					{
						return;
					}
				}

				ToonsInVicinity.push(characterID);
				UtilsBase.PrintChatText("SlotNameAdded - " + Character.GetCharacter(characterID).GetName() + " Length " + ToonsInVicinity.length );
			}
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
	
	public function SlotAllNamesRemoved()
	{
		ToonsInVicinity = new Array();
		UtilsBase.PrintChatText("SlotAllNamesRemoved");
	}
	
	public function SlotSplashScreenActivated()
	{
		m_zoneChanged = true;
		UtilsBase.PrintChatText("SlotSplashScreenActivated");
	}

}
