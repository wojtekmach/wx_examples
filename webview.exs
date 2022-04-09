wx = :wx.new()
size = {800, 600}
f = :wxFrame.new(wx, -1, "Window", size: size)

if :os.type() == {:unix, :darwin} do
  # create a new menu bar to handle built-in "quit" menu item
  mb = :wxMenuBar.new()
  :wxFrame.setMenuBar(f, mb)
end

:wxFrame.connect(f, :close_window, skip: true)
:wxFrame.connect(f, :command_menu_selected, skip: true)
:wxFrame.show(f)

webview = :wxWebView.new(f, -1, url: "https://elixir-lang.org", size: size)
:wxWebView.connect(webview, :webview_newwindow)
:wxWebView.connect(webview, :webview_navigating)
:wxWebView.connect(webview, :webview_loaded)
:wxWebView.connect(webview, :webview_error)

defmodule Loop do
  require Logger

  @wxID_EXIT 5006

  def loop do
    receive do
      {:wx, @wxID_EXIT, _, _, _} = event ->
        Logger.debug(inspect(event))
        :ok

      {:wx, _, _, _, {:wxClose, :close_window}} = event ->
        Logger.debug(inspect(event))
        :ok

      {:wx, _, _webview, _, {:wxWebView, :webview_navigating, _, _, _, 'http://wx/quit'}} = event ->
        Logger.debug(inspect(event))
        :ok

      {:wx, _, _webview, _, {:wxWebView, :webview_navigating, _, _, _, _}} = event ->
        Logger.debug(inspect(event))
        loop()

      {:wx, _, webview, _, {:wxWebView, :webview_loaded, _, _, _, _url}} = event ->
        Logger.debug(inspect(event))

        js = """
        var handleDocumentKeyDown = function(event) {
          const isMacOS = /(Mac|iPhone|iPod|iPad)/i.test(navigator.platform);
          const cmd = isMacOS ? event.metaKey : event.ctrlKey;
          const shift = event.shiftKey;
          const key = event.key;

          if (cmd && key === "q") {
            window.location.replace('http://wx/quit');
          }
        }
        document.addEventListener("keydown", handleDocumentKeyDown);
        """

        {true, _} = :wxWebView.runScript(webview, js)
        loop()

      event ->
        Logger.debug(inspect(event))
        loop()
    end
  end
end

Loop.loop()
