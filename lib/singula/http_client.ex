defmodule Singula.HTTPClient do
  @moduledoc """
  Specification for a Singula HTTP client.
  """

  @type method :: atom

  @type url :: binary

  @type status :: non_neg_integer

  @type header :: {binary, binary}

  @type body :: binary

  @doc """
  Callback to make an HTTP request.
  """
  @callback request(method, url, body, [header]) ::
              {:ok, %{status_code: status, headers: [header], body: body}}
              | {:error, Exception.t()}
end
