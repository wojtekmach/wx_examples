:wx.new()

m = :wxMenu.new()
:wxMenu.append(m, 5001, "Close\tctrl-w")
mb = :wxMenuBar.new()
:wxMenuBar.append(mb, m, "File")

:wxMenuBar.destroy(:wxMenuBar.macGetCommonMenuBar())
:wxMenuBar.macSetCommonMenuBar(mb)

:wxMenuBar.connect(mb, :command_menu_selected, skip: true)

receive do
  event ->
    IO.inspect(event)
end
