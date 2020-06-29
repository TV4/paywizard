defmodule Singula.Response do
  defstruct [:body, :json, :status_code]

  @type t :: %__MODULE__{body: binary, json: nil | map | list, status_code: integer}
end

defmodule Singula.Error do
  defstruct [:message]

  @type t :: %__MODULE__{message: any}
end

defmodule Singula.HTTPClient do
  require Logger

  @type payload :: map | binary

  @callback get(binary) :: {:ok, Singula.Response.t()} | {:error, %HTTPoison.Error{}}
  def get(path, http_client \\ HTTPoison, current_time \\ &DateTime.utc_now/0) do
    signed_request(http_client, current_time, :get, path, "", Accept: "application/json")
  end

  @callback patch(binary, payload) :: {:ok, Singula.Response.t()} | {:error, %HTTPoison.Error{}}
  def patch(path, data, http_client \\ HTTPoison, current_time \\ &DateTime.utc_now/0) do
    body = if is_map(data), do: Jason.encode!(data), else: data

    signed_request(http_client, current_time, :patch, path, body,
      "Content-Type": "application/json; charset=utf-8",
      Accept: "application/json"
    )
  end

  @callback post(binary, payload) :: {:ok, Singula.Response.t()} | {:error, %HTTPoison.Error{}}
  def post(path, data, http_client \\ HTTPoison, current_time \\ &DateTime.utc_now/0) do
    body = if is_map(data), do: Jason.encode!(data), else: data

    signed_request(http_client, current_time, :post, path, body,
      "Content-Type": "application/json; charset=utf-8",
      Accept: "application/json"
    )
  end

  defp signed_request(http_client, current_time, method, path, body, headers, options \\ []) do
    url = singula_url(path)
    headers = Keyword.merge(signed_headers(method, path, current_time), headers)
    options = Keyword.merge(options, recv_timeout: timeout())

    Logger.debug(
      "Singula request: #{
        inspect(%HTTPoison.Request{method: method, url: url, body: body, headers: headers, options: options})
      }"
    )

    {time, response} = :timer.tc(fn -> http_client.request(method, url, body, headers, options) end)
    Logger.debug("Singula response: #{inspect(response)}")
    Logger.info("Singula request time: measure#singula.request=#{div(time, 1000)}ms")

    translate_response(response)
  end

  defp signed_headers(method, path, current_time) do
    method = method |> to_string |> String.upcase()
    timestamp = current_time.() |> DateTime.to_unix()
    api_key = Application.get_env(:singula, :api_key)
    api_secret = Application.get_env(:singula, :api_secret)
    path = URI.parse(path).path

    signature = :crypto.hmac(:sha256, api_secret, "#{timestamp}#{method}#{path}") |> Base.encode16()

    [
      Authorization: "hmac #{api_key}:#{signature}",
      Timestamp: timestamp
    ]
  end

  defp translate_response({:error, %HTTPoison.Error{reason: message}}) do
    {:error, %Singula.Error{message: message}}
  end

  defp translate_response({:ok, %HTTPoison.Response{body: body, headers: headers, status_code: status_code}}) do
    response = %Singula.Response{body: body, status_code: status_code}

    response =
      Enum.find(headers, fn {key, _value} -> String.downcase(key) == "content-type" end)
      |> case do
        nil -> response
        {_, "application/json" <> _charset} -> %Singula.Response{response | json: Jason.decode!(body)}
      end

    {:ok, response}
  end

  defp singula_url(path), do: Application.get_env(:singula, :base_url) <> path
  defp timeout, do: Application.get_env(:singula, :timeout_ms, 10000)
end
