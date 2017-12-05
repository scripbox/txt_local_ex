defmodule TxtLocalEx.HttpMessenger do
  @behaviour TxtLocalEx.Messenger

  # Define API endpoints
  @send_sms_path "/send/?"

  alias TxtLocalEx.Request

  # Public API

  @doc """
  The send_sms/3 function sends an sms to a
  given phone number from a given phone number.
  ## Example:
    ```
    iex(1)> TxtLocalEx.HttpMessenger.send_sms("15005550006", "15005550001", "test message")
    %{
      "balance" => 1162,
      "batch_id" => 123456789,
      "cost" => 2,
      "num_messages" => 2,
      "message" => {
        "num_parts" => 1,
        "sender" => "Jims Autos",
        "content" => "This is your message"
      },
      "messages" => [{
        "id" => "1151346216",
        "recipient" => 447123456789
      },
      {
        "id" => "1151347780",
        "recipient" => 447987654321
      }],
      "status" => "success"
    }
    ```
  """
  @spec send_sms(String.t(), String.t(), String.t()) :: map()
  def send_sms(from, to, body) do
    sms_payload = send_sms_payload(from, to, body)

    case Request.post(@send_sms_path, sms_payload) do
      {:ok, response} -> response.body
      {:error, error} -> raise TxtLocalEx.Errors.ApiError, error.reason
    end
  end

  # Private API

  defp send_sms_payload(from, to, body) do
    %{"message" => body, "sender" => from, "numbers" => to}
  end
end
