defmodule TxtLocalEx.HTTPClient.HTTPoison do
  @behaviour TxtLocalEx.HTTPClient
  def request(method, url, body, headers \\ [], options \\ []) do
    HTTPoison.request(
      method,
      url,
      body,
      headers,
      options
    )
    |> case do
      {:ok, %{body: body, headers: headers, status_code: status}} ->
        {:ok, %{body: body, headers: headers, status: status}}

      {:ok, %{headers: headers, status_code: status}} ->
        {:ok, %{headers: headers, status: status}}

      {:error, error} ->
        {:error, error}
    end
  end
end
