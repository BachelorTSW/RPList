import GUI.RPListShareLocationWindow;
import com.GameInterface.Browser.Browser;

class GUI.RPListShareLocationContent extends com.Components.WindowComponentContent
{
	
	private var m_Loader:gfx.controls.UILoader;
	private var m_Browser:Browser;
	private var m_sharingLocationText:TextField;

	public function RPListShareLocationContent()
	{
		super();
	}

	public function configUI()
	{
		super.configUI()

		m_Browser = new com.GameInterface.Browser.Browser(5.0000, this.m_Loader._width, this.m_Loader._height);

		m_Browser.SignalBrowserShowPage.Connect(SlotLoadingPageComplete, this);
		
		m_Browser.OpenURL(RPListMod.URL);

		m_Loader.loadMovie("img://browsertexture/" + m_Browser.GetBrowserName());
	}
	
	private function SlotLoadingPageComplete()
	{
		RPListShareLocationWindow.SignalShareLocationDone.Emit();
	}

}