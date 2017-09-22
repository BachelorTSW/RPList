class GUI.RPListPlayerListWindow extends com.Components.WinComp
{

	public function RPListPlayerListWindow()
	{
		super();
	}

	function configUI()
	{
		super.configUI();
	}

	function onLoad()
	{
		super.configUI();

		var visibleRect = Stage["visibleRect"];
		_x = visibleRect.x;
		_y = visibleRect.y;
		SetPadding(10);
		SetContent("RPListPlayerListContent");
		SignalClose.Connect(CloseWindowHandler,this);
		ShowCloseButton(true);
		ShowStroke(false);
		ShowResizeButton(false);
		ShowFooter(false);

		_x = Math.round((visibleRect.width / 2) - (m_Background._width / 2));
		_y = Math.round((visibleRect.height / 2) - (m_Background._height / 2));
	}

	function CloseWindowHandler()
	{
		removeMovieClip();
	}
	
	
   function onUnload()
   {
      super.onUnload();

      Selection.setFocus(null);
   }
}