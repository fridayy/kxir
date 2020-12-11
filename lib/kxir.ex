defmodule Kxir do
  @moduledoc """
  Documentation for `Kxir`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Kxir.hello()
      :world

  """
  def main(args) do
    case args do
       ["logs", pod_name]-> Kxir.Logs.aggregate(pod_name, "default")
       ["logs", pod_name, namespace] -> Kxir.Logs.aggregate(pod_name, namespace)
       _ ->
        IO.puts("Dont know what to do :(")
    end
  end
end
