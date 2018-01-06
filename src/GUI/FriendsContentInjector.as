import GUI.Friends.FriendsContent;
import GUI.Friends.FriendsViewsContainer;
import com.GameInterface.DistributedValue;
import mx.utils.Delegate;

/**
 * ...
 * @author Peter Bunting
 */
class GUI.FriendsContentInjector
{
	private static var ROLEPLAYERS:String = "ROLEPLAYERS";
	private static var ROLEPLAYERS_BUTTON:String = "";

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
		friendsContent["m_TabButtonArray"].splice(1, 0, {label: ROLEPLAYERS, view: FriendsViewsContainer.FRIENDS_VIEW, responseLabel: ROLEPLAYERS_BUTTON});
		friendsContent["m_ButtonBar"].invalidateData()
	}

}
