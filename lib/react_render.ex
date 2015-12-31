defmodule ReactRender do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(ReactRender.Worker, [[name: ReactRender.Worker]]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ReactRender.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def render(stuff) do
    GenServer.call(ReactRender.Worker, {:render, stuff})
  end
end