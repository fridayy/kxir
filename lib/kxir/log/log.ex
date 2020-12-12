defmodule Kxir.Logs do
  @moduledoc """
  Provides convience operations over kubernetes logging facilities.
  Requires a 'pod_name' and optionally a namespace (defaults to "default").

  Example: kx logs some-pod somenamespace

  """
  @behaviour Kxir.CLI.Help
  alias Kxir.Pod


  @jaro_threshold 0.6

  @doc """
  Aggregates the logs from the given pod by considering all init containers.
  This should replace commands like:

    $ kubectl logs some-pod-23123 -c current-init-container

  """
  def aggregate(pod_name, namespace) do
    Pod.logs(pod_name, namespace)
    |> Enum.map(fn t -> attach_name_to_line(t) <> "\n" end)
    |> IO.puts()
  end

  def aggregate(pod_name, namespace, exclude_similar_name) do
    #todo: remove duplicated code and extract filter and namespace to keyword opts
    Pod.logs(pod_name, namespace)
    |> Enum.filter(fn t -> elem(t, 0) |> String.jaro_distance(exclude_similar_name) < @jaro_threshold end)
    |> Enum.map(fn t -> attach_name_to_line(t) <> "\n" end)
    |> IO.puts()
  end

  defp attach_name_to_line({name, lines}) do
    String.split(lines, "\n")
    |> Enum.filter(&(String.length(&1) > 0))
    |> Enum.map(fn line -> color_for(name) <> "[#{name}] " <> IO.ANSI.reset() <> line end)
    |> Enum.join("\n")
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
    "#{IO.ANSI.green}\nUsage: #{IO.ANSI.reset}logs #{IO.ANSI.red}[pod_name] #{IO.ANSI.yellow}[namespace]"
  end

end
