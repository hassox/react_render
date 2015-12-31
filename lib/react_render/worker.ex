defmodule ReactRender.Worker do
  use GenServer
  alias Porcelain.Process, as: Proc
  alias Porcelain.Result

  def start_link(opts \\ []) do
    IO.inspect("THE OPTIONS ARE: #{inspect(opts)}")
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def stop do
    GenServer.call(ReactRender.Worker, :stop)
  end

  ## Server callbacks

  def init(:ok) do
    IO.puts("STARTING THE SERVER")
    proc = %Proc{pid: pid} = start_js_server
    {:ok, %{js_server: pid, js_proc: proc}}
  end

  def handle_cast({:render, stuff}, from, state) do
    Proc.send_input(state.js_proc, stuff)
    {:reply, "RENDERED #{inspect(stuff)}", state}
  end

  def handle_call(:stop, _from, state) do
    IO.puts("STOPPING #{inspect(self)}")
    {:stop, :normal, :ok, state}
  end

  def handle_info({js_pid, :data, :out, <<4>>}, state) do
    IO.puts("END OF FILE")
    {:noreply, state}
  end

  # The js server has stopped
  def handle_info({js_pid, :result, %Result{err: _, status: status}} = msg, state) do
    IO.puts("THE JS SERVER HAS STOPPED")
    IO.inspect(msg)
    {:stop, :normal, state}
  end

  def handle_info(stuff, state) do
    IO.inspect(stuff)
    {:noreply, state}
  end

  def terminate(reason, %{js_proc: server} = state) do
    IO.puts("TERMINATING")
    IO.inspect(server)
    Porcelain.Process.signal(server, :kill)
    Porcelain.Process.stop(server)
    :ok
  end

  def terminate(reason, state) do
    IO.puts("TERMINATING with no server")
    :ok
  end

  defp start_js_server do
    Porcelain.spawn_shell("node #{Path.join([__DIR__, "..", "js", "server.js"])}",
                                in: :receive, out: {:send, self()})
  end
end
