import GUI.RPListGetRoleplayersWindow;
import com.GameInterface.Browser.Browser;
import dto.RPListRoleplayersListDto;

class GUI.RPListGetRoleplayersContent extends com.Components.WindowComponentContent
{
	private var m_Loader:gfx.controls.UILoader;
	private var m_Browser:Browser;

	public function RPListGetRoleplayersContent()
	{
		super();
	}

	public function configUI()
	{
		super.configUI()

		m_Browser = new com.GameInterface.Browser.Browser(5.0000, this.m_Loader._width, this.m_Loader._height);

		m_Browser.SignalStartLoadingURL.Connect(SlotLoadingPageStart, this);

		m_Browser.OpenURL("https://***REMOVED***/list-mod");

		m_Loader.loadMovie("img://browsertexture/" + m_Browser.GetBrowserName());
	}

	private function SlotLoadingPageStart(url:String)
	{
		if (url.indexOf("list-mod-response") != -1)
		{
			var dto:RPListRoleplayersListDto = null;
			if (url.indexOf("?") > -1)
			{
				var params = url.substr(url.indexOf("?") + 1);
				dto = new RPListRoleplayersListDto(params);
			}
			RPListGetRoleplayersWindow.SignalRoleplayersAcquired.Emit(dto);
		}
	}

}