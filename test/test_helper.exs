ExUnit.start()

Mox.defmock(HTTPoison.BaseMock, for: HTTPoison.Base)
Application.put_env(:metex, :http_client, HTTPoison.BaseMock)
