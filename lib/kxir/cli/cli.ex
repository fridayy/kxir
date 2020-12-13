defmodule Kxir.CLI do
  @moduledoc """
  Entry point for the Kxir CLI.
  """

  @behaviour Kxir.CLI.Help

  def main([]) do
    IO.puts(Kxir.CLI.Help.help(Kxir.CLI))
  end

  def main(args) do
    parsed_args = OptionParser.parse(args, strict: [help: :boolean, jaro: :string])

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

      _ ->
        IO.puts(Kxir.CLI.Help.help(Kxir.CLI))
    end
  end

  def help_text() do
    "Not yet available"
  end
end
