import com.Utils.Archive;
import com.GameInterface.UtilsBase;
import com.GameInterface.Nametags;
import com.Utils.ID32;
import com.GameInterface.Game.Character;

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
	
	
	public static function SlotNameAdd(characterID:ID32)
	{
		if (characterID.IsPlayer())
		{
		ToonsInVicinity.push(characterID);
		UtilsBase.PrintChatText("SlotNameAdded - " + Character.GetCharacter(characterID).GetName() + " Length " + ToonsInVicinity.length ); 
		}
	}
	
	public static function SlotNameRemoved(characterID:ID32)
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
}