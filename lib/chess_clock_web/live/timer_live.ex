defmodule ChessClockWeb.TimerLive do
  use ChessClockWeb, :live_view

  alias ChessClock.GameServer

  @init_time 10

  def mount(_params, _session, socket) do
    {:ok, pid} = GameServer.start_link(self(), @init_time)

    socket =
      socket
      |> assign(:game_pid, pid)
      |> assign(:current_player, :player1)
      |> assign(:times, %{time1: @init_time, time2: @init_time})

    {:ok, socket}
  end

  def handle_event("change_player", _value, socket) do
    GameServer.change(socket.assigns.game_pid)
    {:noreply, socket}
  end

  def handle_info({:tick, {player, {time1, time2}}}, socket) do
    socket =
      socket
      |> assign(:current_player, player)
      |> assign(:times, %{time1: time1, time2: time2})

    {:noreply, socket}
  end

  def handle_info({:winner, player}, socket) do
    {:noreply, assign(socket, :winner_message, "Winner #{player}")}
  end
end
