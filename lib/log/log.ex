defmodule Logs do
  @moduledoc """
  Provides convience operations over the kubernetes logging facilities
  """

  @doc """
  Aggregates the logs from the given pod by considering all init containers.
  This should replace commands like:

    $ kubectl logs some-pod-23123 -c current-init-container

  """
  def aggregate do
    {:ok, conn} = K8s.Conn.lookup(:default)
    pods = K8s.Client.list("v1", "Pod", namespace: "")
  end
end
