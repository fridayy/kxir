defmodule Kxir.Kube do
  @moduledoc """
  This is the behaviour that a kubernetes API abstraction must implement in oder to work with `Kxir`.
  See: `Kxir.Kube.Base`
  """

  @doc """
  Gets a single kubernetes resource. Corresponds to the kubernetes API get verb.
  see: [Kubernetes API](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#determine-the-request-verb)

  Path and query parameters are provided as a keyword list where as path parameters are passed directly and
  query params shall be passed as a map

  Example: list("v1", "Pods", namespace: "test", query_params: %{"pretty" => "true"})
  """
  @callback get(api_group :: String.t(), resource :: String.t(), options :: Keyword.t()) :: {:ok, Map.t()} | {:error, String.t()}

  @doc """
  Gets a list of kuberetes resources. Corresponds to the kubernetes API get verb for resource collections.
  see: [Kubernetes API](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#determine-the-request-verb)

  Path and query parameters are provided as a keyword list where as path parameters are passed directly and
  query params shall be passed as a map

  Example: list("v1", "Pods", namespace: "test", query_params: %{"pretty" => "true"})
  """
  @callback list(api_group :: String.t(), resource :: String.t(), options :: Keyword.t()) :: {:ok, Map.t()} | {:error, String.t()}

end
