defmodule Kxir.Core do

  import Logger

def acquire_connection! do
    K8s.Conn.lookup(:default)
    |> return_connection_or_raise
  end

  defp return_connection_or_raise({:ok, conn}), do: conn
  defp return_connection_or_raise({:error,reason}) do
    Logger.error("Could not read kube config file: #{reason}")
    raise "Could not read the kube config file"
  end


  def get do
    K8s.Client.get()
    |> K8s.Client.run(acquire_connection!())
  end

  def list(api_version, resource, namespace) do
    K8s.Client.list(api_version, resource, namespace: namespace)
    |> K8s.Client.run(acquire_connection!())
    |> items!()
  end

  def list(api_version, resource), do: list(api_version, resource, "default")

  defp items!({:ok, response}), do: response |> Map.get("items")
  defp items!({:error, reason}) do
    Logger.error("Could not read items due to: #{reason}")
    raise "Could not read items: #{reason}"
  end
end
