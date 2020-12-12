defmodule Kxir.CLI.Help do
  @moduledoc """
  Modules implementing this behaviour provide a nice help text that can be printed to
  the terminal.
  """
  @callback help_text() :: String.t()

  def help(module) do
    module.help_text()
  end

end
