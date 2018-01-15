import GUI.RPListFriendsContentInjector;
import GUI.RPListGetRoleplayersContent;
import GUI.RPListGetRoleplayersWindow;
import GUI.RPListShareLocationContent;
import GUI.RPListShareLocationWindow;
import com.GameInterface.Chat;
import com.GameInterface.DistributedValue;
import com.GameInterface.UtilsBase;
import com.Utils.Archive;
import com.GameInterface.Nametags;
import com.Utils.ID32;
import com.GameInterface.Game.Character;
import mx.utils.Delegate;

class RPListMod
{
	private static var m_instance:RPListMod;

	private static var SHARE_LOCATION_INTERVAL = 1000 * 60 * 1;
	private static var AGARTHA_PLAYFIELD_ID:Number = 5060;

	public static var URL;

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
	private var m_shareLocationInterval:Number;
	private var m_toonsInVicinity:Array;
	private var m_incognito:Boolean;
	private var m_showedIncognitoWarning:Boolean;

	public function RPListMod(swfRoot: MovieClip)
	{
		m_instance = this;
		m_shareLocationInterval = -1;
		m_showedIncognitoWarning = false;

		// Store a reference to the root MovieClip
		m_swfRoot = swfRoot;
		_Flash = MovieClip(swfRoot);

		m_zoneChanged = true;
		registerGuiElements();
	}

	public static function GetInstance():RPListMod
	{
		return m_instance;
	}

	public function OnLoad()
	{
		m_toonsInVicinity = new Array();
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

		var m_NameArray = _root.nametagcontroller;

		// Ignore for Agartha - everyone is in same instance
		if (Character.GetClientCharacter().GetPlayfieldID() != AGARTHA_PLAYFIELD_ID)
		{
			for (var proc in _root.nametagcontroller.m_NametagIncomingQueue)
			{
				var temp:ID32 = _root.nametagcontroller.m_NametagIncomingQueue[proc];
				if (temp.IsPlayer() && temp.m_Instance != m_clientID)
				{
					m_toonsInVicinity.push(temp);
				}
			}
		}
	}

	public function OnUnload()
	{
		clearInterval(m_shareLocationInterval);
		Nametags.SignalNametagAdded.Disconnect(SlotNameAdded);
		Nametags.SignalNametagUpdated.Disconnect(SlotNameAdded);
		Nametags.SignalNametagRemoved.Disconnect(SlotNameRemoved);
		Nametags.SignalAllNametagsRemoved.Disconnect(SlotAllNamesRemoved);
		UtilsBase.SignalSplashScreenActivated.Disconnect(SlotSplashScreenActivated);
		m_friendsContentInjector.OnUnload();
		delete m_friendsContentInjector;
	}

	public function Activate(config: Archive)
	{
		setIncognito(config.FindEntry("is_incognito", false));
	}

	public function Deactivate(): Archive
	{
		var archive: Archive = new Archive();
		archive.AddEntry("is_incognito", m_incognito);
		return archive;
	}

	public function isIncognito()
	{
		return m_incognito;
	}

	public function setIncognito(incognito:Boolean)
	{
		m_incognito = incognito;
		if (incognito)
		{
			stopSharingLocation();
		}
		else
		{
			startSharingLocation();
		}
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

	public function startSharingLocation()
	{
		if (m_shareLocationInterval == -1)
		{
			setTimeout(Delegate.create(this, shareLocation), 10);
			m_shareLocationInterval = setInterval(this, "shareLocation", SHARE_LOCATION_INTERVAL);
		}
	}

	public function stopSharingLocation()
	{
		if (m_shareLocationInterval != -1)
		{
			clearInterval(m_shareLocationInterval);
			m_shareLocationInterval = -1;
			URL = "https://***REMOVED***/remove?playerId=" + m_clientID;
			sendServerRequest();
		}
	}

	public function shareLocation()
	{

		MakePlayersURL();
		sendServerRequest();
	}

	private function sendServerRequest()
	{
		m_shareLocationWindow = new RPListShareLocationWindow(_Flash.attachMovie("RPListShareLocationWindow", "m_shareLocationWindow", _Flash.getNextHighestDepth()));
	}

	function MakePlayersURL()
	{
		var currentPlayfieldID:Number = Character.GetClientCharacter().GetPlayfieldID();

		var autoMeetup:Boolean = DistributedValue.GetDValue("MeetUpPrompts");

		URL = "https://***REMOVED***/update?playerId=" + m_clientID
			  + "&nick=" + m_clientNick + "&firstName=" + m_clientFName + "&lastName=" + m_clientLName
			  + "&playfieldId=" + currentPlayfieldID + "&autoMeetup=" + autoMeetup;

		if (m_zoneChanged)
		{
			// Player has changed zones since last update
			URL = URL + "&clearInstance=true";
			m_zoneChanged = false;
		}
		else if (m_toonsInVicinity.length > 0)
		{
			URL = URL + "&players=" + m_toonsInVicinity[0].m_Instance;
			for ( var i:Number = 1 ; i < m_toonsInVicinity.length ; ++i )
			{
				URL = URL + "," + m_toonsInVicinity[i].m_Instance;
			}
		}
		m_lastClientPlayfieldID = currentPlayfieldID;
	}

	public function SlotNameAdded(characterID:ID32)
	{
		// Ignore for Agartha - everyone is in same instance
		if (Character.GetClientCharacter().GetPlayfieldID() != AGARTHA_PLAYFIELD_ID)
		{
			if (characterID.IsPlayer() && !characterID.Equal(Character.GetClientCharacter().GetID()))
			{
				for (var i:Number = 0; i < m_toonsInVicinity.length; ++i)
				{
					// Avoid duplicates
					if (m_toonsInVicinity[i].Equal(characterID))
					{
						return;
					}
				}

				m_toonsInVicinity.push(characterID);
			}
		}
	}

	public function SlotNameRemoved(characterID:ID32)
	{
		for ( var i:Number = 0 ; i < m_toonsInVicinity.length ; ++i )
		{
			if ( m_toonsInVicinity[i].Equal( characterID ) )
			{
				m_toonsInVicinity.splice( i, 1 );
			}
		}
	}

	public function SlotAllNamesRemoved()
	{
		m_toonsInVicinity = new Array();
	}

	public function SlotSplashScreenActivated(activated:Boolean)
	{
		m_zoneChanged = true;

		if (!activated)
		{
			if (!m_showedIncognitoWarning && isIncognito())
			{
				Chat.SignalShowFIFOMessage.Emit("RPList Mod: You are currently invisible");
			}
			m_showedIncognitoWarning = true;
		}
	}

}
