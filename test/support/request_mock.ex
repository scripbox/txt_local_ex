defmodule RequestMock do
  # Public API
  def request(method, url, body, _headers, _opts) do
    send(self(), %{method: method, url: url, body: body})
    {:ok, %{body: successful_response()}}
  end

  # Private API
  # %{
  #   "balance" => 1162,
  #   "batch_id" => 123456789,
  #   "cost" => 2,
  #   "message" => %{
  #     "content" => "This is your message",
  #     "num_parts" => 1,
  #     "sender" => "Jims Autos"
  #   },
  #   "messages" => [
  #     %{"id" => "1151346216", "recipient" => 447123456789},
  #     %{"id" => "1151347780", "recipient" => 447987654321}
  #   ],
  #   "num_messages" => 2,
  #   "status" => "success"
  # }
  defp successful_response do
    "{\"balance\":1162,\"batch_id\":123456789,\"cost\":2,\"message\":{\"content\":\"This is your message\",\"num_parts\":1,\"sender\":\"Jims Autos\"},\"messages\":[{\"id\":\"1151346216\",\"recipient\":447123456789},{\"id\":\"1151347780\",\"recipient\":447987654321}],\"num_messages\":2,\"status\":\"success\"}"
  end
end
