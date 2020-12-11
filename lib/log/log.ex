defmodule Kxir.Logs do
  @moduledoc """
  Provides convience operations over kubernetes logging facilities
  """

  alias Kxir.Pod

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
end
