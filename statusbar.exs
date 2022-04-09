wx = :wx.new()
wxID_EXIT = 5006

menu = :wxMenu.new()
:wxMenu.append(menu, wxID_EXIT, "Quit")
:wxMenu.connect(menu, :command_menu_selected)

statusbar =
  :wxTaskBarIcon.new(
    iconType: 1,
    createPopupMenu: fn -> menu end
  )

icon = :wxArtProvider.getIcon('wxART_PLUS')
:wxTaskBarIcon.setIcon(statusbar, icon, tooltip: "Demo")

receive do
  event ->
    IO.inspect(event)
end
