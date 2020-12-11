defmodule Kxir.Pod do
  @moduledoc """
  Contains operations specific to Pods
  """
  alias Kxir.Core

  def list(namespace) do
    Core.list("v1", "Pods", namespace)
  end

  def list do
    list("default")
  end

  def get(pod_name, namespace) do
    Core.get("v1", "Pod", namespace: namespace, name: pod_name)
  end

  def get(pod_name), do: get(pod_name, "default")

  def containers({:ok, spec}) do
    spec |> extract("containers")
  end

  def init_containers({:ok, spec}) do
    spec |> extract("initContainers")
  end

  def all_containers(s = {:ok, _spec}) do
    init_containers(s) ++ containers(s)
  end

  def multiple_containers?({:ok, spec}) do
    spec |> Enum.count() > 0
  end

  defp extract(result, c) do
    result
    |> Map.get("spec", %{})
    |> Map.get(c, [])
  end


  def logs(pod_name, namespace) do
    spec = get(pod_name, namespace)
    multiple_containers = spec |> multiple_containers?()
    if multiple_containers do
      merged_logs(spec)
    else
      Core.get("v1", "Pods/log", namespace: namespace, name: pod_name)
    end
  end

  defp merged_logs(spec) do
    all_containers(spec)
      |> Enum.map(fn cspec -> Map.get(cspec, "name") end)
      |> Enum.map(fn name -> container_logs(spec, name) end)
  end

  defp container_logs({:ok, spec}, container_name) do
    metadata = Map.fetch!(spec, "metadata")
    name = Map.fetch!(metadata, "name")
    namespace = Map.fetch!(metadata, "namespace")
    {:ok, logs} = Core.get("v1", "Pods/log", [namespace: namespace, name: name, query_params: %{
      "container" => container_name,
      "pretty" => "true"
    }])
    {container_name, logs}
  end

end
