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
          :wxMenu.append(menu, @wxID_NEW, "Debug")
          :wxMenu.append(menu, @wxID_EXIT, "Quit")

          # For some reason, on macOS the menu event must be handled in another process
          # but on Windows it must be either the same process OR we use the callback.
          case :os.type() do
            {:unix, :darwin} ->
              env = :wx.get_env()

              Task.start_link(fn ->
                :wx.set_env(env)
                :wxMenu.connect(menu, :command_menu_selected)

                receive do
                  message ->
                    send(pid, message)
                end
              end)

            {:win32, _} ->
              :ok =
                :wxMenu.connect(menu, :command_menu_selected,
                  callback: fn wx, _ ->
                    send(pid, wx)
                  end
                )
          end

          menu
        end
      )

    logo_path = Application.app_dir(:wx, "examples/demo/erlang.png")
    icon = :wxIcon.new(logo_path, type: @wxBITMAP_TYPE_PNG)
    :wxTaskBarIcon.setIcon(taskbar, icon)

    {:ok, %{}}
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
