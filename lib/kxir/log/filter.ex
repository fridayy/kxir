defmodule Kxir.Logs.Filter.Base do
  @doc """
  Filters log lines by a given criteria.
  """
  @callback filter(tuple :: {String.t(), String.t()}, opts :: Keyword.t()) :: Boolean.t()
end
