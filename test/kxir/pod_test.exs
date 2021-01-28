defmodule Kxir.PodTest do
  use ExUnit.Case

  describe "parse/1" do
    test "parses 'kubectl get pods'" do
      s =
        "NAME                                      READY   STATUS    RESTARTS   AGE\natlas-atlas-beta-cdfcc4775-kt455          2/2     Running   0          46d\nfreya-freya-beta-7f5d8fc546-zrtgd         2/2     Running   0          2d5h\nheimdall-heimdall-beta-7b6f786ffc-dcmsz   3/3     Running   1          10d\nmysql-master-0                            2/2     Running   0          88d\npostgres-beta-postgresql-0                3/3     Running   0          83d\nrain-rain-beta-7bdf89d6cd-wmrcq           2/2     Running   14         3d1h\n"

      result = Kxir.Pod.parse(s)

      assert result == [
               "atlas-atlas-beta-cdfcc4775-kt455",
               "freya-freya-beta-7f5d8fc546-zrtgd",
               "heimdall-heimdall-beta-7b6f786ffc-dcmsz",
               "mysql-master-0",
               "postgres-beta-postgresql-0",
               "rain-rain-beta-7bdf89d6cd-wmrcq"
             ]
    end
  end
end
