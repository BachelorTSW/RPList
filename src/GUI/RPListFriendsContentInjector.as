import GUI.Friends.FriendsContent;
import GUI.Friends.FriendsViewsContainer;
import GUI.Friends.Views.FriendsView;
import GUI.RPListGetRoleplayersWindow;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValue;
import com.Components.MultiColumnList.MCLItemValueData;
import com.Components.MultiColumnListView;
import com.GameInterface.DistributedValue;
import com.GameInterface.FriendInfo;
import com.GameInterface.Friends;
import com.GameInterface.Game.Character;
import com.Utils.ID32;
import dto.RPListRoleplayerDto;
import dto.RPListRoleplayersListDto;
import mx.utils.Delegate;

/**
 * Injects custom content into the Friends window - adds Roleplayers tab and modifies FriendsView for its purposes
 */
class GUI.RPListFriendsContentInjector
{
	private static var ROLEPLAYERS:String = "ROLEPLAYERS";
	private static var ROLEPLAYERS_BUTTON:String = "";
	private static var COLUMN_NAME = 0;
	private static var COLUMN_ZONE = 1;

	private var _Flash: MovieClip;
	private var m_FriendsMonitor:DistributedValue;

	private var m_FriendsViewColumnTableBackup:Array;

	private var m_getRoleplayersWindow:RPListGetRoleplayersWindow;

	public function RPListFriendsContentInjector(flash:MovieClip)
	{
		this._Flash = flash;
		m_FriendsMonitor = DistributedValue.Create("friends_window");
		m_FriendsMonitor.SignalChanged.Connect(onFriendsWindowStateChange, this);
	}

	function onFriendsWindowStateChange():Void
	{
		var isOpen = DistributedValue.GetDValue("friends_window");
		if (isOpen)
		{
			// Give the UI time to finish configuring before injecting the tab
			setTimeout(Delegate.create(this, injectTabs), 500);
		}
	}

	function injectTabs()
	{
		var friendsContent:FriendsContent = _root.friends.m_Window.m_Content;
		var friendsViewsContainer:FriendsViewsContainer = friendsContent["m_ViewsContainer"];

		friendsContent["m_TabButtonArray"].push({label: ROLEPLAYERS, view: FriendsViewsContainer.FRIENDS_VIEW, responseLabel: ROLEPLAYERS_BUTTON});
		friendsContent["m_ButtonBar"].invalidateData()

		friendsContent["m_ButtonBar"].addEventListener("change", this, "onTabChange");
	}

	function onTabChange(event:Object)
	{
		var friendsContent:FriendsContent = _root.friends.m_Window.m_Content;
		var friendsViewsContainer:FriendsViewsContainer = friendsContent["m_ViewsContainer"];
		var columnListView:MultiColumnListView = friendsViewsContainer["m_FriendsView"]["m_List"];

		if (event.index == 0)
		{
			// Friends tab selected - return the view to original state
			columnListView["m_ColumnTable"].splice(0, columnListView["m_ColumnTable"].length);
			columnListView.LayoutHeaders(true);
			columnListView["m_ColumnTable"] = columnListView["m_ColumnTable"].concat(m_FriendsViewColumnTableBackup);
			columnListView.LayoutHeaders(true);
			reconnectFriendsListSignal();
		}
		else
		{
			var selectedTab = friendsContent["m_TabButtonArray"][event.index].label;
			if (selectedTab == ROLEPLAYERS)
			{
				disconnectFriendsListSignal();

				// Roleplayers tab selected - modify columns of the Friends view
				m_FriendsViewColumnTableBackup = (new Array()).concat(columnListView["m_ColumnTable"]);
				columnListView["m_ColumnTable"].splice(0, columnListView["m_ColumnTable"].length);
				columnListView.LayoutHeaders(true);
				columnListView.AddColumn(COLUMN_NAME, "Name", 150, 0);
				columnListView.AddColumn(COLUMN_ZONE, "Zone", 300, 0);
				columnListView.LayoutHeaders(true);

				m_getRoleplayersWindow = new RPListGetRoleplayersWindow(_Flash.attachMovie("RPListGetRoleplayersWindow", "m_getRoleplayersWindow", _Flash.getNextHighestDepth()));
				RPListGetRoleplayersWindow.SignalRoleplayersAcquired.Connect(addRoleplayersToList, this);
			}
		}
	}

	function reconnectFriendsListSignal()
	{
		var friendsContent:FriendsContent = _root.friends.m_Window.m_Content;
		var friendsViewsContainer:FriendsViewsContainer = friendsContent["m_ViewsContainer"];
		var friendsView:FriendsView = friendsViewsContainer["m_FriendsView"];
		var columnListView:MultiColumnListView = friendsView["m_List"];
		Friends.SignalFriendsUpdated.Connect(friendsView["SlotFriendsUpdate"], friendsView);
		columnListView.RemoveAllItems();
		Friends.SignalFriendsUpdated.Emit();

		columnListView.SignalItemClicked.Disconnect(SlotItemClicked);
		columnListView.SignalItemClicked.Connect(friendsView["SlotItemClicked"], friendsView);
	}

	function disconnectFriendsListSignal()
	{
		var friendsContent:FriendsContent = _root.friends.m_Window.m_Content;
		var friendsViewsContainer:FriendsViewsContainer = friendsContent["m_ViewsContainer"];
		var friendsView:FriendsView = friendsViewsContainer["m_FriendsView"];
		var columnListView:MultiColumnListView = friendsView["m_List"];
		Friends.SignalFriendsUpdated.Disconnect(friendsView["SlotFriendsUpdate"]);
		columnListView.RemoveAllItems();

		columnListView.SignalItemClicked.Disconnect(friendsView["SlotItemClicked"]);
		columnListView.SignalItemClicked.Connect(SlotItemClicked, this);

		friendsView["m_Header"].m_Title.text = "Roleplayers (loading)";
	}

	function SlotItemClicked(index:Number, buttonIndex:Number)
	{
		var friendsContent:FriendsContent = _root.friends.m_Window.m_Content;
		var friendsViewsContainer:FriendsViewsContainer = friendsContent["m_ViewsContainer"];
		var friendsView:FriendsView = friendsViewsContainer["m_FriendsView"];
		var columnListView:MultiColumnListView = friendsView["m_List"];
		var selected:MCLItemDefault = columnListView["m_Items"][index];
		var selectedNameCol:MCLItemValue = selected.GetValues()[COLUMN_NAME];

		var shouldRemoveFriend:Boolean = false;
		var id = selected.GetId();
		if (Character.GetClientCharacter().GetID().Equal(id))
		{
			return;
		}
		var idInstance:Number = selected.GetId().GetInstance();
		if (Friends.m_Friends[idInstance] == null)
		{
			var newFriendInfo:FriendInfo = new FriendInfo();
			newFriendInfo.m_FriendID = id;
			newFriendInfo.m_Name = selectedNameCol.m_Value.m_Text;
			newFriendInfo.m_Online = true;
			newFriendInfo.m_Faction = 1;
			newFriendInfo.m_OnlineTime = 1;
			Friends.m_Friends[idInstance] = newFriendInfo;
			shouldRemoveFriend = true;
		}

		friendsView.SlotItemClicked(index, buttonIndex);

		if (shouldRemoveFriend)
		{
			delete Friends.m_Friends[idInstance];
		}
	}

	function addRoleplayersToList(roleplayersDto:RPListRoleplayersListDto)
	{
		var friendsContent:FriendsContent = _root.friends.m_Window.m_Content;
		var friendsViewsContainer:FriendsViewsContainer = friendsContent["m_ViewsContainer"];
		var friendsView:FriendsView = friendsViewsContainer["m_FriendsView"];
		var columnListView:MultiColumnListView = friendsView["m_List"];
		var roleplayers:Array = new Array();
		if (roleplayersDto != null)
		{
			for (var i = 0 ; i < roleplayersDto.roleplayers.length ; ++i)
			{
				var roleplayer:RPListRoleplayerDto = roleplayersDto.roleplayers[i];
				roleplayers.push(createRoleplayerItem(roleplayer.id, roleplayer.nick, roleplayer.zone));
			}
		}
		columnListView.RemoveAllItems();
		columnListView.AddItems(roleplayers);
		friendsView["m_Header"].m_Title.text = "Roleplayers (" + roleplayers.length + ")";
	}

	function createRoleplayerItem(id:ID32, nick:String, zone:String):MCLItemDefault
	{
		var friendsItem:MCLItemDefault = new MCLItemDefault(id);

		var nameValue:MCLItemValueData = new MCLItemValueData();
		nameValue.m_Text = nick;
		nameValue.m_TextColor = 0x00FF00;
		nameValue.m_TextSize = 12;
		nameValue.m_MovieClipWidth = 20;
		friendsItem.SetValue(COLUMN_NAME, nameValue, MCLItemDefault.LIST_ITEMTYPE_STRING);

		var zoneValueDate:MCLItemValueData = new MCLItemValueData();
		zoneValueDate.m_Text = zone;
		zoneValueDate.m_TextColor = 0x00FF00;
		zoneValueDate.m_TextSize = 12;
		friendsItem.SetValue(COLUMN_ZONE, zoneValueDate, MCLItemDefault.LIST_ITEMTYPE_STRING);

		return friendsItem;
	}

}
