import Config

config :k8s,
  clusters: %{
    default: %{
      conn: "~/.kube/config"
    }
  }
