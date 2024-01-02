defmodule Metex.Worker do
  def temperature_of(location) do
    result = url_for(location) |> HTTPoison.get() |> parse_response

    case result do
      {:ok, temp} ->
        "#{location}: #{temp}°C"

      :error ->
        "#{location} not found"
    end
  end

  # "units=metric" returns Celsius. Without it, this API call returns Kelvin.
  def url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&units=metric&appid=#{apikey()}"
  end

  # Uses pattern matching to get "body". If API result does not match this map exactly, view as error
  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> Jason.decode!() |> compute_temperature
  end

  # Any other HTTPoison response that's NOT 200 status is an error
  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      # Rounds temp to nearest 1 decimal point
      temp = json["main"]["temp"] |> Float.round(1)
      {:ok, temp}
    rescue
      # Any failure in parsing JSON response is error
      _ -> :error
    end
  end

  defp apikey do
    System.get_env("WEATHER_API_KEY")
  end
end
