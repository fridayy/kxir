defmodule Kxir.CLI do
  @moduledoc """
  Entry point for the Kxir CLI.
  """

  @behaviour Kxir.CLI.Help

  def main([]) do
    IO.puts(Kxir.CLI.Help.help(Kxir.CLI))
  end

  def main(args) do
    parsed_args =
      OptionParser.parse(args,
        aliases: [p: :pipe],
        strict: [help: :boolean, jaro: :string, pipe: :boolean]
      )

    case parsed_args do
      {[], ["logs", pod_name, namespace], []} ->
        Kxir.Logs.aggregate(pod_name, namespace: namespace)

      {[], ["logs", pod_name], []} ->
        Kxir.Logs.aggregate(pod_name)

      {[jaro: name], ["logs", pod_name], []} ->
        Kxir.Logs.aggregate(pod_name, jaro: name)

      {[jaro: name], ["logs", pod_name, namespace], []} ->
        Kxir.Logs.aggregate(pod_name, namespace: namespace, jaro: name)

      {[help: true], ["logs"], []} ->
        IO.puts(Kxir.CLI.Help.help(Kxir.Logs))

      {[], ["logs"], []} ->
        IO.puts(Kxir.CLI.Help.help(Kxir.Logs))

      {[pipe: true], [number], []} ->
        # TODO: extract to fn and extract case block into fns for guards
        IO.read(:all)
        |> Kxir.Pod.parse()
        |> Enum.at(String.to_integer(number))
        |> Kxir.Logs.aggregate()

      {[pipe: true], [number, namespace], []} ->
        IO.read(:all)
        |> Kxir.Pod.parse()
        |> Enum.at(String.to_integer(number))
        |> Kxir.Logs.aggregate(namespace: namespace)
      {[pipe: true, jaro: name], [number, namespace], []} ->
        IO.read(:all)
        |> Kxir.Pod.parse()
        |> Enum.at(String.to_integer(number))
        |> Kxir.Logs.aggregate(namespace: namespace, jaro: name)

      _ ->
        IO.puts(Kxir.CLI.Help.help(Kxir.CLI))
    end
  end

  def help_text() do
    "Not yet available"
  end
end
