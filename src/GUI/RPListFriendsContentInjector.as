import GUI.Friends.FriendsContent;
import GUI.Friends.FriendsViewsContainer;
import GUI.Friends.Views.FriendsView;
import GUI.RPListGetRoleplayersWindow;
import com.Components.MultiColumnList.MCLItemDefault;
import com.Components.MultiColumnList.MCLItemValueData;
import com.Components.MultiColumnListView;
import com.GameInterface.DistributedValue;
import com.GameInterface.Friends;
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
				columnListView.AddColumn(0, "Name", 150, 0);
				columnListView.AddColumn(1, "Zone", 300, 0);
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
	}

	function disconnectFriendsListSignal()
	{
		var friendsContent:FriendsContent = _root.friends.m_Window.m_Content;
		var friendsViewsContainer:FriendsViewsContainer = friendsContent["m_ViewsContainer"];
		var friendsView:FriendsView = friendsViewsContainer["m_FriendsView"];
		var columnListView:MultiColumnListView = friendsView["m_List"];
		Friends.SignalFriendsUpdated.Disconnect(friendsView["SlotFriendsUpdate"]);
		columnListView.RemoveAllItems();
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
	}

	function createRoleplayerItem(id:ID32, nick:String, zone:String):MCLItemDefault
	{
		var friendsItem:MCLItemDefault = new MCLItemDefault(id);

		var nameAndRightClickButtonValue:MCLItemValueData = new MCLItemValueData();
		nameAndRightClickButtonValue.m_Text = nick;
		nameAndRightClickButtonValue.m_TextColor = 0x00FF00;
		nameAndRightClickButtonValue.m_TextSize = 12;
		nameAndRightClickButtonValue.m_MovieClipName = "RightClickButton";
		nameAndRightClickButtonValue.m_MovieClipWidth = 20;
		friendsItem.SetValue(0, nameAndRightClickButtonValue, MCLItemDefault.LIST_ITEMTYPE_MOVIECLIP_AND_TEXT);

		var zoneValueDate:MCLItemValueData = new MCLItemValueData();
		zoneValueDate.m_Text = zone;
		zoneValueDate.m_TextColor = 0x00FF00;
		zoneValueDate.m_TextSize = 12;
		friendsItem.SetValue(1, zoneValueDate, MCLItemDefault.LIST_ITEMTYPE_STRING);

		return friendsItem;
	}

}
