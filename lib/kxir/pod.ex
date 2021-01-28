defmodule Kxir.Pod do
  @moduledoc """
  Contains operations specific to Pods
  """
  alias Kxir.Kube.Base

  @log_timeout 15_000

  def list(namespace) do
    Base.list("v1", "Pods", namespace: namespace)
  end

  def get(pod_name, namespace) do
    Base.get!("v1", "Pod", namespace: namespace, name: pod_name)
  end

  def get(pod_name), do: get(pod_name, "default")

  def containers(spec), do: extract(spec, "containers")

  def  non_waiting_container_names(spec) do
    main_container_statuses = spec
    |> Map.get("status")
    |> Map.get("containerStatuses")

    init_container_statuses = spec
    |> Map.get("status")
    |> Map.get("initContainerStatuses")

    [main_container_statuses, init_container_statuses]
    |> List.flatten()
    |> Enum.filter(fn status -> !is_waiting(status) end)
    |> Enum.map(fn %{"name" => name} -> name end)
  end

  defp is_waiting(%{"state" => %{"waiting" => _}}), do: true
  defp is_waiting(_), do: false

  def init_containers(spec), do: extract(spec, "initContainers")

  def all_containers(spec), do: (init_containers(spec) ++ containers(spec)) |> Enum.with_index()

  def multiple_containers?(spec) do
    spec |> Enum.count() > 0
  end

  def logs(pod_name, namespace) do
    spec = get(pod_name, namespace)
    multiple_containers = spec |> multiple_containers?()

    if multiple_containers do
      merged_logs(spec)
    else
      Base.get!("v1", "Pods/log", namespace: namespace, name: pod_name)
    end
  end

  @doc """
  Parses a string from e.g stdin and returns a list of pod names
  """
  @spec parse(binary()) :: [binary()]
  def parse(string) do
    String.split(string, "\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.drop(1)
    |> Enum.flat_map(&Regex.run(~r{^\S+}, &1))
  end

  defp extract(result, c) do
    result
    |> Map.get("spec", %{})
    |> Map.get(c, [])
  end

  defp merged_logs(spec) do
    non_waiting_container_names(spec)
    |> Enum.with_index()
    |> Task.async_stream(fn {name, idx} -> container_logs(spec, {idx, name}) end, timeout: @log_timeout)
    |> Stream.map(&(elem(&1, 1)))
  end

  defp container_logs(spec, {idx, container_name}) do
    metadata = Map.fetch!(spec, "metadata")
    name = Map.fetch!(metadata, "name")
    namespace = Map.fetch!(metadata, "namespace")

    logs =
      Base.get!("v1", "Pods/log",
        namespace: namespace,
        name: name,
        query_params: %{
          "container" => container_name,
          "pretty" => "true"
        }
      )

    {idx, container_name, logs}
  end
end
