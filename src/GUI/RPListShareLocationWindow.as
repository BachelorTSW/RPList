import com.Components.WinComp
import com.Utils.Signal;

class GUI.RPListShareLocationWindow extends WinComp
{
	
	public static var SignalShareLocationDone:Signal = new Signal();

	public function RPListShareLocationWindow()
	{
		super();
		
		SignalShareLocationDone.Connect(SlotShareLocationDone, this);
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
		SetContent("RPListShareLocationContent");
		
		_x = 200;
		_y = 200;
	}
	
	private function SlotShareLocationDone() {
		removeMovieClip();
	}

}