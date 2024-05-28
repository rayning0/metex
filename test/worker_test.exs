defmodule WorkerTest do
  use ExUnit.Case, async: true
  doctest Metex.Worker
  import Mox
  # Ensure mocks are verified when the test exits
  setup :verify_on_exit!

  @http_response_no_city {:ok,
                          %HTTPoison.Response{
                            status_code: 404,
                            body: "{\"cod\":\"404\",\"message\":\"city not found\"}",
                            headers: [
                              {"Server", "openresty"},
                              {"Date", "Tue, 28 May 2024 05:25:37 GMT"},
                              {"Content-Type", "application/json; charset=utf-8"},
                              {"Content-Length", "40"},
                              {"Connection", "keep-alive"},
                              {"X-Cache-Key", "/data/2.5/weather?q=blahblah&units=imperial"},
                              {"Access-Control-Allow-Origin", "*"},
                              {"Access-Control-Allow-Credentials", "true"},
                              {"Access-Control-Allow-Methods", "GET, POST"}
                            ],
                            request_url:
                              "http://api.openweathermap.org/data/2.5/weather?q=blahblah&units=imperial&appid=ac987ac826a14642299c9824ce4fa190",
                            request: %HTTPoison.Request{
                              method: :get,
                              url:
                                "http://api.openweathermap.org/data/2.5/weather?q=blahblah&units=imperial&appid=ac987ac826a14642299c9824ce4fa190",
                              headers: [],
                              body: "",
                              params: %{},
                              options: []
                            }
                          }}

  @http_response_la {:ok,
                     %HTTPoison.Response{
                       status_code: 200,
                       body:
                         "{\"coord\":{\"lon\":-118.2437,\"lat\":34.0522},\"weather\":[{\"id\":804,\"main\":\"Clouds\",\"description\":\"overcast clouds\",\"icon\":\"04n\"}],\"base\":\"stations\",\"main\":{\"temp\":58.42,\"feels_like\":58.06,\"temp_min\":54.45,\"temp_max\":64.33,\"pressure\":1018,\"humidity\":87},\"visibility\":10000,\"wind\":{\"speed\":8.05,\"deg\":110},\"clouds\":{\"all\":100},\"dt\":1716873123,\"sys\":{\"type\":2,\"id\":2034962,\"country\":\"US\",\"sunrise\":1716813864,\"sunset\":1716864982},\"timezone\":-25200,\"id\":5368361,\"name\":\"Los Angeles\",\"cod\":200}",
                       headers: [
                         {"Server", "openresty"},
                         {"Date", "Tue, 28 May 2024 05:15:42 GMT"},
                         {"Content-Type", "application/json; charset=utf-8"},
                         {"Content-Length", "484"},
                         {"Connection", "keep-alive"},
                         {"X-Cache-Key",
                          "/data/2.5/weather?q=los%20angeles,%20california&units=imperial"},
                         {"Access-Control-Allow-Origin", "*"},
                         {"Access-Control-Allow-Credentials", "true"},
                         {"Access-Control-Allow-Methods", "GET, POST"}
                       ],
                       request_url:
                         "http://api.openweathermap.org/data/2.5/weather?q=Los%20Angeles,%20California&units=imperial&appid=ac987ac826a14642299c9824ce4fa190",
                       request: %HTTPoison.Request{
                         method: :get,
                         url:
                           "http://api.openweathermap.org/data/2.5/weather?q=Los%20Angeles,%20California&units=imperial&appid=ac987ac826a14642299c9824ce4fa190",
                         headers: [],
                         body: "",
                         params: %{},
                         options: []
                       }
                     }}

  test "gets LA temperature" do
    expect(HTTPoison.BaseMock, :get, fn _ -> @http_response_la end)

    assert Metex.Worker.temperature_of("Los Angeles, California") ==
             "Los Angeles, California: 58.4°F"
  end

  test "can't find city" do
    expect(HTTPoison.BaseMock, :get, fn _ -> @http_response_no_city end)

    assert Metex.Worker.temperature_of("blahblah") ==
             "blahblah not found"
  end
end
