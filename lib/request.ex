defmodule TxtLocalEx.Request do
  use HTTPoison.Base

  @api_url "http://api.textlocal.in"

  defp process_url(url) do
    @api_url <> url
  end

  defp api_key_param do
    %{"apiKey" => Application.get_env(:txt_local_ex, :api_key)}
  end

  defp base_headers do
    %{"Content-Type" => "application/x-www-form-urlencoded"}
  end

  defp process_request_body(body) when is_map(body) do
    Map.merge(api_key_param(), body)
    |> URI.encode_query
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

  def process_response_body(body) do
    case Poison.decode(body) do
      { :ok, data } -> data
      _ -> body
    end
  end
end
