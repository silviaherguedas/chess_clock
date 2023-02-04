defmodule ChessClock.GameServer do
  use GenServer

  def start_link(live_pid, time \\ 100) do
    GenServer.start_link(__MODULE__, %{live_pid: live_pid, time: time})
  end

  def change(pid) do
    GenServer.cast(pid, :change)
  end

  # Callbacks
  @impl true
  def init(opts) do
    Process.send_after(self(), :tick, :timer.seconds(1))

    {:ok, %{live_pid: opts.live_pid, current_player: :player1, times: {opts.time, opts.time}}}
  end

  @impl true
  def handle_info(:tick, state), do: tiks_handler(state)

  @impl true
  def handle_cast(:change, %{current_player: player} = state) do
    {:noreply, Map.put(state, :current_player, alternate_player(player))}
  end

  def tiks_handler(%{current_player: :player1, times: {time1, _}} = state) when time1 <= 0 do
    send(state.live_pid, {:winner, :player2})
    {:stop, :normal, state}
  end

  def tiks_handler(%{current_player: :player1, times: {time1, time2}} = state) do
    Process.send_after(self(), :tick, :timer.seconds(1))
    send(state.live_pid, {:tick, {:player1, {time1 - 1, time2}}})

    {:noreply, Map.put(state, :times, {time1 - 1, time2})}
  end

  def tiks_handler(%{current_player: :player2, times: {_, time2}} = state) when time2 <= 0 do
    send(state.live_pid, {:winner, :player1})
    {:stop, :normal, state}
  end

  def tiks_handler(%{current_player: :player2, times: {time1, time2}} = state) do
    Process.send_after(self(), :tick, :timer.seconds(1))
    send(state.live_pid, {:tick, {:player2, {time1, time2 - 1}}})

    {:noreply, Map.put(state, :times, {time1, time2 - 1})}
  end

  def alternate_player(:player1), do: :player2
  def alternate_player(:player2), do: :player1
end
