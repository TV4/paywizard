defmodule Singula.Request do
  defstruct [:method, :url, :body, :headers]
end

defmodule Singula.Response do
  defstruct [:body, :json, :status_code]

  @type t :: %__MODULE__{body: binary, json: nil | map | list, status_code: integer}
end

defmodule Singula.Error do
  defstruct [:code, :developer_message, :user_message]

  @type t :: %__MODULE__{code: integer | nil, developer_message: binary | nil, user_message: binary | nil}
end

defmodule Singula.Client do
  require Logger

  @type payload :: map | binary

  @callback get(path :: binary) :: {:ok, Singula.Response.t()} | {:error, Singula.error()}
  def get(path, current_time \\ &DateTime.utc_now/0) do
    signed_request(current_time, :get, path, "", [{"Accept", "application/json"}])
  end

  @callback patch(path :: binary, payload) :: {:ok, Singula.Response.t()} | {:error, Singula.error()}
  def patch(path, data, current_time \\ &DateTime.utc_now/0) do
    body = if is_map(data), do: Jason.encode!(data), else: data

    signed_request(
      current_time,
      :patch,
      path,
      body,
      [{"Content-Type", "application/json; charset=utf-8"}, {"Accept", "application/json"}]
    )
  end

  @callback post(path :: binary, payload) :: {:ok, Singula.Response.t()} | {:error, Singula.error()}
  def post(path, data, current_time \\ &DateTime.utc_now/0) do
    body = if is_map(data), do: Jason.encode!(data), else: data

    signed_request(
      current_time,
      :post,
      path,
      body,
      [{"Content-Type", "application/json; charset=utf-8"}, {"Accept", "application/json"}]
    )
  end

  defp signed_request(current_time, method, path, body, headers) do
    url = singula_url(path)
    headers = signed_headers(method, path, current_time) ++ headers
    Singula.Telemetry.emit_request_event(%Singula.Request{method: method, url: url, body: body, headers: headers})

    response = http_client().request(method, url, body, headers)

    Singula.Telemetry.emit_response_event(response)

    translate_response(response)
  end

  defp signed_headers(method, path, current_time) do
    method = method |> to_string |> String.upcase()
    timestamp = current_time.() |> DateTime.to_unix()
    api_key = Application.get_env(:singula, :api_key)
    api_secret = Application.get_env(:singula, :api_secret)
    path = URI.parse(path).path

    signature = :crypto.mac(:hmac, :sha256, api_secret, "#{timestamp}#{method}#{path}") |> Base.encode16()

    [
      {"Authorization", "hmac #{api_key}:#{signature}"},
      {"Timestamp", to_string(timestamp)}
    ]
  end

  defp translate_response({:error, error}), do: {:error, error}

  defp translate_response({:ok, %{body: body, headers: headers, status_code: status_code}}) do
    response = %Singula.Response{body: body, status_code: status_code}

    response =
      Enum.find(headers, fn {key, _value} -> String.downcase(key) == "content-type" end)
      |> case do
        nil ->
          response

        {_, "application/json" <> _charset} ->
          %Singula.Response{response | json: Jason.decode!(body)}

        _otherwise ->
          Logger.error("Unknown Singula response: #{inspect(response)}")
          response
      end

    separate_error(response)
  end

  defp separate_error(%Singula.Response{json: %{"errorCode" => code} = json}) do
    {:error, %Singula.Error{code: code, developer_message: json["developerMessage"], user_message: json["userMessage"]}}
  end

  defp separate_error(response), do: {:ok, response}

  defp http_client, do: Application.get_env(:singula, :http_client, Singula.HTTPClient.HTTPoison)
  defp singula_url(path), do: Application.get_env(:singula, :base_url) <> path
end
