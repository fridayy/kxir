defmodule Kxir.Kube.K8s do
  @behaviour Kxir.Kube

  require Logger

  def acquire_connection! do
    K8s.Conn.lookup(:default)
    |> return_connection_or_raise
  end

  defp return_connection_or_raise({:ok, conn}), do: conn

  defp return_connection_or_raise({:error, reason}) do
    Logger.error("Could not read kube config file: #{reason}")
    raise "Could not read the kube config file"
  end

  @impl Kxir.Kube
  def get(api_group, resource, opts \\ []) do
    query_params = opts[:query_params]

    if query_params |> is_nil do
      op = K8s.Client.get(api_group, resource, opts)
      op |> K8s.Client.run(acquire_connection!())
    else
      op = K8s.Client.get(api_group, resource, namespace: opts[:namespace], name: opts[:name])

      Enum.reduce(query_params, op, fn param, acc ->
        K8s.Operation.put_query_param(
          acc,
          elem(param, 0),
          elem(param, 1)
        )
      end)
      |> K8s.Client.run(acquire_connection!())
    end
  end

  @impl Kxir.Kube
  def list(api_version, resource, opts \\ []) do
    K8s.Client.list(api_version, resource, opts)
    |> K8s.Client.run(acquire_connection!())
  end
end
