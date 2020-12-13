defmodule Kxir.Logs.Filter.Jaro do
  @behaviour Kxir.Logs.Filter.Base
  @jaro_threshold 0.6

  def filter(tuple, [name: filtered_name]) do
   elem(tuple, 0) |> String.jaro_distance(filtered_name) < @jaro_threshold
  end

end
