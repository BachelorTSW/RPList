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
import dto.RPListRoleplayerDto;
import dto.RPListRoleplayersListDto;
import gfx.controls.ButtonBar;
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
	private static var COLUMN_AUTO_MEETUP = 2;

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
			// Can be safely called repeatedly
			for (var waitTime:Number = 200; waitTime <= 2000; waitTime = waitTime + 200)
			{
				setTimeout(Delegate.create(this, injectTabs), waitTime);
			}
		}
	}

	function injectTabs()
	{
		var friendsContent:FriendsContent = _root.friends.m_Window.m_Content;
		var buttonBar:ButtonBar = friendsContent["m_ButtonBar"];
		var tabButtonArray:Array = friendsContent["m_TabButtonArray"];
		
		if (buttonBar == undefined || buttonBar == null || !buttonBar.hasEventListener("focusIn"))
		{
			return;
		}
		
		var shouldAddButton:Boolean = true;
		for (var i:Number = 0; i < tabButtonArray.length; ++i)
		{
			if (tabButtonArray[i].label == ROLEPLAYERS)
			{
				shouldAddButton = false;
				break;
			}
		}
		if (shouldAddButton)
		{
			friendsContent["m_TabButtonArray"].push({label: ROLEPLAYERS, view: FriendsViewsContainer.FRIENDS_VIEW, responseLabel: ROLEPLAYERS_BUTTON});
			buttonBar.addEventListener("change", this, "onTabChange");
		}
		
		buttonBar.invalidateData()		
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
				columnListView.AddColumn(COLUMN_ZONE, "Zone", 500, 0);
				columnListView.AddColumn(COLUMN_AUTO_MEETUP, "Auto Meetup", 150, 0);
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
				roleplayers.push(createRoleplayerItem(roleplayer));
			}
		}
		columnListView.RemoveAllItems();
		columnListView.AddItems(roleplayers);
		friendsView["m_Header"].m_Title.text = "Roleplayers (" + roleplayers.length + ")";
	}

	function createRoleplayerItem(roleplayer:RPListRoleplayerDto):MCLItemDefault
	{
		var friendsItem:MCLItemDefault = new MCLItemDefault(roleplayer.id);

		var nameValue:MCLItemValueData = new MCLItemValueData();
		nameValue.m_Text = roleplayer.nick;
		nameValue.m_TextColor = 0x00FF00;
		nameValue.m_TextSize = 12;
		nameValue.m_MovieClipWidth = 20;
		friendsItem.SetValue(COLUMN_NAME, nameValue, MCLItemDefault.LIST_ITEMTYPE_STRING);

		var zoneValue:MCLItemValueData = new MCLItemValueData();
		zoneValue.m_Text = roleplayer.zone;
		zoneValue.m_TextColor = 0x00FF00;
		zoneValue.m_TextSize = 12;
		friendsItem.SetValue(COLUMN_ZONE, zoneValue, MCLItemDefault.LIST_ITEMTYPE_STRING);
		
		var autoMeetupValue:MCLItemValueData = new MCLItemValueData();
		autoMeetupValue.m_TextColor = 0xFF0000;
		switch (roleplayer.autoMeetup)
		{
			case RPListRoleplayerDto.AUTOMEETUP_OFF:
				autoMeetupValue.m_Text = "No";
				break;
			case RPListRoleplayerDto.AUTOMEETUP_ON:
				autoMeetupValue.m_Text = "Yes";
				autoMeetupValue.m_TextColor = 0x00FF00;
				break;
			default:
				autoMeetupValue.m_Text = "Unknown";
				break;
		}
		autoMeetupValue.m_TextSize = 12;
		friendsItem.SetValue(COLUMN_AUTO_MEETUP, autoMeetupValue, MCLItemDefault.LIST_ITEMTYPE_STRING);

		return friendsItem;
	}

	function OnUnload()
	{
		var friendsContent:FriendsContent = _root.friends.m_Window.m_Content;
		var friendsViewsContainer:FriendsViewsContainer = friendsContent["m_ViewsContainer"];
		var friendsView:FriendsView = friendsViewsContainer["m_FriendsView"];
		var columnListView:MultiColumnListView = friendsView["m_List"];
		m_FriendsMonitor.SignalChanged.Disconnect(onFriendsWindowStateChange);
		columnListView.SignalItemClicked.Connect(SlotItemClicked, this);
	}
}
