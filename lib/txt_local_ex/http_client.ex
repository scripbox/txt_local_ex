defmodule TxtLocalEx.HTTPClient do
  @type http_method :: :get | :post | :put | :delete | :options | :head
  @callback request(
              method :: http_method,
              url :: binary,
              req_body :: binary,
              headers :: [{binary, binary}, ...],
              http_opts :: term
            ) ::
              {:ok, %{status: pos_integer, headers: any}}
              | {:ok, %{status: pos_integer, headers: any, body: binary}}
              | {:error, any}
end
