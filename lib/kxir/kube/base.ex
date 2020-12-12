defmodule Kxir.Kube.Base do
  @moduledoc """
  The base implementation of the Kxir.Kube behaviours. Delegates to the set
  :kube_module which is by default [K8s](https://github.com/coryodaniel/k8s).
  """
  @implementation Application.get_env(:kxir, :kube_module, Kxir.Kube.K8s)
  @behaviour Kxir.Kube

  @impl Kxir.Kube
  defdelegate get(api_group, resource, opts), to: @implementation
  @impl Kxir.Kube
  defdelegate list(api_group, resource, opts), to: @implementation

  def get!(api_group, resource, opts \\ []) do
    case @implementation.get(api_group, resource, opts) do
      {:ok, result} -> result
      {:error, reason} -> raise ArgumentError, message: "Could not fulfil request: #{reason}"
    end
  end

  def list!(api_group, resource, opts \\ []) do
    case @implementation.list(api_group, resource, opts) do
      {:ok, result} -> result
      {:error, reason} -> raise ArgumentError, message: "Could not fulfil request: #{reason}"
    end
  end
end
