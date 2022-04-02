wx = :wx.new()

f = :wxFrame.new(wx, -1, "Demo 1", pos: {50, 50}, size: {800, 600})
mb = :wxMenuBar.new()
:wxFrame.setMenuBar(f, mb)
:wxMenuBar.connect(mb, :command_menu_selected, skip: true)
:wxFrame.show(f)
:wxWebView.new(f, -1, url: "https://elixir-lang.org", size: {800, 600})

f = :wxFrame.new(wx, -1, "Demo 2", pos: {100, 100}, size: {800, 600})
mb = :wxMenuBar.new()
:wxFrame.setMenuBar(f, mb)
:wxMenuBar.connect(mb, :command_menu_selected, skip: true)
:wxFrame.show(f)
:wxWebView.new(f, -1, url: "https://elixir-lang.org", size: {800, 600})

receive do
  event ->
    IO.inspect(event)
end
