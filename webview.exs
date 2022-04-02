wx = :wx.new()

f = :wxFrame.new(wx, -1, "Demo", pos: {50, 50}, size: {800, 600})
:wxFrame.show(f)

mb = :wxMenuBar.new()
:wxFrame.setMenuBar(f, mb)
:wxMenuBar.connect(mb, :command_menu_selected, skip: true)

:wxWebView.new(f, -1, url: "https://elixir-lang.org", size: {800, 600})

receive do
  event ->
    IO.inspect(event)
end
