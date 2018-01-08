import com.Components.WinComp
import com.Utils.Signal;

class GUI.RPListGetRoleplayersWindow extends WinComp
{
	
	public static var SignalRoleplayersAcquired:Signal = new Signal();
	
	public function RPListGetRoleplayersWindow() 
	{
		super();
		
		SignalRoleplayersAcquired.Connect(SlotRoleplayersAcquired, this);
	}
	
	public function configUI()
	{
		super.configUI();
	}

	public function onLoad()
	{
		super.configUI();
		
		var visibleRect = Stage["visibleRect"];
		_x = visibleRect.x;
		_y = visibleRect.y;
		SetContent("RPListGetRoleplayersContent");
		
		_x = 200;
		_y = 200;
	}
	
	private function SlotRoleplayersAcquired() {
		removeMovieClip();
	}
	
}