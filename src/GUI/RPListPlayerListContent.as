import com.GameInterface.Browser.Browser;

class GUI.RPListPlayerListContent extends com.Components.WindowComponentContent
{

	private var m_Browser:Browser;
	private var m_MouseListener:Object;
	private var m_Loader:gfx.controls.UILoader;
	private static var SCROLL_AMOUNT:Number = 32;

	public function RPListPlayerListContent()
	{
		super();
	}

	function configUI()
	{
		super.configUI();

		this.m_Browser = new com.GameInterface.Browser.Browser(5.0000, this.m_Loader._width, this.m_Loader._height); //Loads browser. The 5.000 is a browser ID state and I think it's unused from TSW.

		this.m_Browser.OpenURL("http://www2.latech.edu/~acm/HelloWorld.shtml");

		this.m_Loader.loadMovie("img://browsertexture/" + this.m_Browser.GetBrowserName());
		this.onMouseMove = mx.utils.Delegate.create(this,this.MouseMoveEventHandler);
		this.onMouseDown = mx.utils.Delegate.create(this,this.MouseDownEventHandler);
		this.onMouseUp = mx.utils.Delegate.create(this,this.MouseUpEventHandler);
		this.m_MouseListener = new Object();
		this.m_MouseListener.onMouseWheel = mx.utils.Delegate.create(this,this.MouseWheelEventHandler);
		Mouse.addListener(this.m_MouseListener);
		this.m_Browser.SetFocus(true);
		Selection.setFocus(this);
	}

	function onUnload()
	{
		super.onUnload();
		this.onMouseMove = undefined;
		this.onMouseDown = undefined;
		this.onMouseUp = undefined;
		Mouse.removeListener(this.m_MouseListener);
		Selection.setFocus(null);
	}
	function MouseMoveEventHandler()
	{
		if (this.m_Loader != undefined && this.m_Loader.hitTest(_root._xmouse,_root._ymouse,true) /*&& Mouse.IsMouseOver(this.m_Loader)*/)
		{
			this.m_Browser.MouseMove(this.GetBrowserMouseLocation().x,this.GetBrowserMouseLocation().y);
		}
	}
	function MouseDownEventHandler()
	{
		if (this.m_Loader != undefined && this.m_Loader.hitTest(_root._xmouse,_root._ymouse,true) /*&& Mouse.IsMouseOver(this.m_Loader)*/)
		{
			this.m_Browser.MouseDown(this.GetBrowserMouseLocation().x,this.GetBrowserMouseLocation().y);
		}
	}
	function MouseWheelEventHandler(delta)
	{
		if (this.m_Loader != undefined && this.m_Loader.hitTest(_root._xmouse,_root._ymouse,true) /*&& Mouse.IsMouseOver(this.m_Loader)*/)
		{
			this.m_Browser.MouseWheel(delta * SCROLL_AMOUNT);
		}
	}
	function MouseUpEventHandler()
	{
		if (this.m_Loader != undefined && this.m_Loader.hitTest(_root._xmouse,_root._ymouse,true) /*&& Mouse.IsMouseOver(this.m_Loader)*/)
		{
			this.m_Browser.SetFocus(true);
			Selection.setFocus(this);
			this.m_Browser.MouseUp(this.GetBrowserMouseLocation().x,this.GetBrowserMouseLocation().y);
		}
		else
		{
			this.m_Browser.SetFocus(false);
			Selection.setFocus(null);
		}
	}
	function GetBrowserMouseLocation()
	{
		var _loc3_ = new flash.geom.Point();
		_loc3_.x = _root._xmouse - this._parent._x - this._x;
		_loc3_.y = _root._ymouse - this._parent._y - this._y;
		return _loc3_;
	}
}