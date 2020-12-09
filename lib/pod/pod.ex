defmodule Kxir.Pod do
  @moduledoc """
  Contains operations specific to Pods
  """

  def list(namespace) do
    Kxir.Core.list("v1", "Pods", namespace)
  end

  def list do
    list("default")
  end

end
