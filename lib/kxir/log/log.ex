defmodule Kxir.Logs do
  @moduledoc """
  Provides convience operations over kubernetes logging facilities.
  Requires a 'pod_name' and optionally a namespace (defaults to "default").

  Example: kx logs some-pod somenamespace

  """
  @behaviour Kxir.CLI.Help
  alias Kxir.{Pod, Logs.Filter.Jaro}

  @doc """
  Aggregates the logs from the given pod by considering all init containers.
  This should replace commands like:

    $ kubectl logs some-pod-23123 -c current-init-container

  """
  def aggregate(pod_name), do: aggregate(pod_name, [])

  def aggregate(pod_name, []) do
    do_aggregate(pod_name, "default")
  end

  def aggregate(pod_name, namespace: namespace) do
    do_aggregate(pod_name, namespace)
  end

  def aggregate(pod_name, jaro: filtered_name),
    do: aggregate(pod_name, namespace: "default", jaro: filtered_name)

  def aggregate(pod_name, namespace: namespace, jaro: filtered_name) do
    # todo: remove duplicated code and extract filter and namespace to keyword opts
    Pod.logs(pod_name, namespace)
    |> Stream.filter(fn tuple -> Jaro.filter(tuple, name: filtered_name) end)
    |> Stream.map(fn t -> attach_name_to_line(t) end)
  end

  defp do_aggregate(pod_name, namespace) do
    Pod.logs(pod_name, namespace)
    |> Stream.map(fn t -> attach_name_to_line(t) end)
    #|> Enum.sort_by(fn x -> elem(x, 0) end, :asc)
    |> Stream.each(&(IO.puts(elem(&1,1))))
    |> Enum.to_list()
  end

  defp attach_name_to_line({idx, name, lines}) do
    logs = String.split(lines, "\n")
    |> Stream.filter(&(String.length(&1) > 0))
    |> Stream.map(fn line -> color_for(name) <> "[#{name}] " <> IO.ANSI.reset() <> line end)
    |> Enum.join("\n")
    {idx, logs <> "\n"}
  end

  defp color_for(name) do
    colors = [
      IO.ANSI.light_magenta(),
      IO.ANSI.light_blue(),
      IO.ANSI.light_red(),
      IO.ANSI.light_cyan(),
      IO.ANSI.light_green()
    ]

    idx = :erlang.phash2(name, length(colors) - 1)
    Enum.at(colors, idx)
  end

  def help_text() do
    "#{IO.ANSI.green()}\nUsage: #{IO.ANSI.reset()}logs #{IO.ANSI.red()}[pod_name] #{
      IO.ANSI.yellow()
    }[namespace]"
  end
end
