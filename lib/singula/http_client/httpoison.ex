defmodule Singula.HTTPClient.HTTPoison do
  def request(method, url, body, headers) do
    options = [recv_timeout: timeout()]

    case HTTPoison.request(method, url, body, headers, options) do
      {:ok, %HTTPoison.Response{} = response} -> {:ok, Map.take(response, [:status_code, :headers, :body])}
    end
  end

  defp timeout, do: Application.get_env(:singula, :timeout_ms, 10000)
end
