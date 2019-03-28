defmodule TxtLocalEx.Request do
  @api_url "http://api.textlocal.in"

  @default_headers [{"Content-Type", "application/x-www-form-urlencoded"}]
  @default_options Application.get_env(:txt_local_ex, :default_options)

  def request(method, url, data) do
    method
    |> HTTPoison.request(
      process_url(url),
      process_request_body(data),
      @default_headers,
      @default_options
    )
    |> process_response()
  end

  defp process_url(url) do
    @api_url <> url
  end

  defp process_request_body(body) when is_map(body) do
    URI.encode_query(body)
  end

  defp process_request_body(body), do: body

  defp process_response({:ok, %{body: body} = response}) do
    case Jason.decode(body) do
      {:ok, data} ->
        {:ok, %{response | body: data}}

      _ ->
        {:error, %TxtLocalEx.Errors.ApiError{reason: "error decoding response body", args: body}}
    end
  end

  defp process_response(response) do
    response
  end
end
