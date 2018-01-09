import GUI.RPListGetRoleplayersWindow;
import com.GameInterface.Browser.Browser;
import com.Utils.ID32;
import dto.RPListRoleplayerDto;
import dto.RPListRoleplayersListDto;
import gfx.utils.Delegate;

class GUI.RPListGetRoleplayersContent extends com.Components.WindowComponentContent
{
	private var m_Loader:gfx.controls.UILoader;
	private var m_Browser:Browser;
	
	private var m_loadTimeout:Number;

	public function RPListGetRoleplayersContent()
	{
		super();
	}

	public function configUI()
	{
		super.configUI()

		m_Browser = new com.GameInterface.Browser.Browser(5.0000, this.m_Loader._width, this.m_Loader._height);

		m_Browser.SignalStartLoadingURL.Connect(SlotLoadingPageStart, this);

		m_loadTimeout = setTimeout(Delegate.create(this, loadingTimedOut), 5000);
		
		m_Browser.OpenURL("https://***REMOVED***/list-mod");

		m_Loader.loadMovie("img://browsertexture/" + m_Browser.GetBrowserName());
	}

	private function SlotLoadingPageStart(url:String)
	{
		if (url.indexOf("list-mod-response") != -1)
		{
			clearTimeout(m_loadTimeout);
			var dto:RPListRoleplayersListDto = null;
			if (url.indexOf("?") > -1)
			{
				var params = url.substr(url.indexOf("?") + 1);
				dto = new RPListRoleplayersListDto(params);
			}
			RPListGetRoleplayersWindow.SignalRoleplayersAcquired.Emit(dto);
		}
	}
	
	private function loadingTimedOut()
	{
		var errorMessageDto:RPListRoleplayerDto = new RPListRoleplayerDto();
		errorMessageDto.id = new ID32(_global.Enums.TypeID.e_Type_GC_Character, 1);
		errorMessageDto.nick = "Unavailable";
		errorMessageDto.zone = "Temporarily unavailable";
		var dto:RPListRoleplayersListDto = new RPListRoleplayersListDto();
		dto.roleplayers.push(errorMessageDto);
	}

}