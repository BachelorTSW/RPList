import GUI.Friends.FriendsContent;
import GUI.Friends.FriendsViewsContainer;
import GUI.Friends.FriendsViewsContainerExtended;
import com.GameInterface.DistributedValue;
import com.GameInterface.UtilsBase;
import mx.utils.Delegate;

/**
 * ...
 * @author Peter Bunting
 */
class GUI.FriendsContentInjector
{
	private static var ROLEPLAYERS_VIEW:String = "RPListRoleplayersView";
	private static var ROLEPLAYERS:String = "ROLEPLAYERS";
	private static var ROLEPLAYERS_BUTTON:String = "";

	private var m_RPListRoleplayersView:MovieClip;
	private var m_FriendsMonitor:DistributedValue;

	public function FriendsContentInjector()
	{
		m_FriendsMonitor = DistributedValue.Create("friends_window");
		m_FriendsMonitor.SignalChanged.Connect(onFriendsWindowStateChange, this);
	}

	function onFriendsWindowStateChange():Void
	{
		var isOpen = DistributedValue.GetDValue("friends_window");
		if (isOpen)
		{
			setTimeout(Delegate.create(this, injectTabs), 500);
		}
	}

	function injectTabs()
	{		
		var friendsContent:FriendsContent = _root.friends.m_Window.m_Content;
		var friendsViewsContainer:FriendsViewsContainer = friendsContent["m_ViewsContainer"];
		
		createRoleplayersView(friendsViewsContainer);
		
		// Replace FriendsViewsContainer with new instance - shrinks UI
		//friendsContent["m_ViewsContainer"] = friendsContent.attachMovie("ViewsContainer", "m_ViewsContainer", friendsContent.getNextHighestDepth());
		
		//friendsContent["m_TabButtonArray"].splice(1, 0, {label: ROLEPLAYERS, view: FriendsViewsContainerExtended.ROLEPLAYERS_VIEW, responseLabel: ROLEPLAYERS_BUTTON});
		friendsContent["m_TabButtonArray"].push({label: ROLEPLAYERS, view: ROLEPLAYERS_VIEW, responseLabel: ROLEPLAYERS_BUTTON});
		friendsContent["m_ButtonBar"].invalidateData()
	}
	
	function createRoleplayersView(friendsViewsContainer:FriendsViewsContainer)
	{		
		// Check that the Roleplayers view doesn't exist
		var viewExists:Boolean = false;
		var viewsArray:Array = friendsViewsContainer["m_ViewsArray"];
		for (var i:Number = 0; i < viewsArray.length; i++)
		{
			if (viewsArray[i].name == ROLEPLAYERS_VIEW)
			{
				viewExists = true;
			}
		}
		if (!viewExists)
		{
			//m_RPListRoleplayersView = _root.attachMovie(ROLEPLAYERS_VIEW, "m_" + ROLEPLAYERS_VIEW, _root.getNextHighestDepth());
			m_RPListRoleplayersView = friendsViewsContainer.attachMovie(ROLEPLAYERS_VIEW, "m_" + ROLEPLAYERS_VIEW, friendsViewsContainer.getNextHighestDepth());
			friendsViewsContainer["m_" + ROLEPLAYERS_VIEW] = m_RPListRoleplayersView;
			//viewsArray.splice(1, 0, {name: ROLEPLAYERS_VIEW, view: friendsViewsContainer["m_" + ROLEPLAYERS_VIEW]});
			viewsArray.push({name: ROLEPLAYERS_VIEW, view: m_RPListRoleplayersView});
			UtilsBase.PrintChatText("Roleplayer view created");
			UtilsBase.PrintChatText("Visible: " + m_RPListRoleplayersView._visible);
		}
	}

}
