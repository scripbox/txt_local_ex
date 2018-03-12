defmodule TxtLocalEx.Request do
  use HTTPoison.Base

  @api_url "http://api.textlocal.in"

  defp process_url(url) do
    @api_url <> url
  end

  defp base_headers do
    %{"Content-Type" => "application/x-www-form-urlencoded"}
  end

  defp process_request_body(body) when is_map(body) do
    body
    |> URI.encode_query()
  end

  defp process_request_body(body), do: body

  # Override the base headers with any passed in.
  defp process_request_headers(request_headers) do
    headers =
      request_headers
      |> Enum.into(%{})

    Map.merge(base_headers(), headers)
    |> Enum.into([])
  end

  # :timeout - timeout to establish a connection, in milliseconds.
  # :recv_timeout - timeout used when receiving a connection.
  defp process_request_options(options) do
    [timeout: 5000, recv_timeout: 2000]
  end

  def process_response_body(body) do
    case Poison.decode(body) do
      {:ok, data} -> data
      _ -> body
    end
  end
end
