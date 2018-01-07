import GUI.Friends.FriendsViewsContainer;
/**
 * ...
 * @author Peter Bunting
 */
class GUI.Friends.FriendsViewsContainerExtended extends FriendsViewsContainer
{
	
	public static var ROLEPLAYERS_VIEW:String = "RPListRoleplayersView";
	
	private var m_RPListRoleplayersView:MovieClip;
	
	public function FriendsViewsContainerExtended() 
	{
		super();
		
		initExtensions();
	}
	
	private function initExtensions() {
		//m_RPListRoleplayersView = attachMovie(ROLEPLAYERS_VIEW, "m_" + ROLEPLAYERS_VIEW, getNextHighestDepth());
		//m_ViewsArray.splice(1, 0, {name: ROLEPLAYERS_VIEW, view: m_RPListRoleplayersView});
		//m_ViewsArray.push({name: ROLEPLAYERS_VIEW, view: m_RPListRoleplayersView});
		//m_RPListRoleplayersView._visible = false;
	}
	
}