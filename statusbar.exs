defmodule Server do
  use GenServer
  require Logger

  @wxID_NEW 5002
  @wxID_EXIT 5006
  @wxBITMAP_TYPE_PNG 15

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    :wx.new()
    pid = self()

    taskbar =
      :wxTaskBarIcon.new(
        createPopupMenu: fn ->
          menu = :wxMenu.new()
          :wxMenu.append(menu, @wxID_NEW, "Debug\tCtrl-N")
          :wxMenu.append(menu, @wxID_EXIT, "Quit\tCtrl-Q")
          send(pid, {:taskbar_menu_created, menu})
          menu
        end
      )

    path = Application.app_dir(:wx, "priv/erlang-logo32.png")
    icon = :wxIcon.new(path, type: @wxBITMAP_TYPE_PNG)
    :wxTaskBarIcon.setIcon(taskbar, icon)

    {:ok, %{}}
  end

  @impl true
  def handle_info({:taskbar_menu_created, menu}, state) do
    :ok = :wxMenu.connect(menu, :command_menu_selected)
    {:noreply, state}
  end

  @impl true
  def handle_info({:wx, @wxID_EXIT, _, _, _} = event, state) do
    Logger.debug(inspect(event))
    System.stop()
    {:noreply, state}
  end

  @impl true
  def handle_info({:wx, @wxID_NEW, _, _, _} = event, state) do
    Logger.debug(inspect(event))
    {:noreply, state}
  end
end

{:ok, _} = Server.start_link()
Process.sleep(:infinity)
