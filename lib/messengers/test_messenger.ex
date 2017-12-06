defmodule TxtLocalEx.TestMessenger do
  @behaviour TxtLocalEx.Messenger

  # Public API

  @doc """
  The send_sms/4 function sends an sms to a
  given phone number from a given phone number.
  ## Example:
    ```
    iex(1)> TxtLocalEx.TestMessenger.send_sms("15005550006", "15005550001", "test message")
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
  @spec send_sms(String.t(), String.t(), String.t(), String.t()) :: map()
  def send_sms(from, _, _, _) when from == "", do:
    %{"errors" => [%{"code" => 43, "message" => "Invalid sender name"}], "status" => "failure"}
  def send_sms(_, to, _, _) when to == "", do:
    %{"errors" => [%{"code" => 4, "message" => "No recipients specified"}], "status" => "failure"}
  def send_sms(_, _, body, _) when body == "", do:
    %{"errors" => [%{"code" => 5, "message" => "No message content"}], "status" => "failure"}
  def send_sms(from, to, body, _receipt_url \\ "") do
    %{
      "balance" => 1162,
      "batch_id" => 123456789,
      "cost" => 2,
      "num_messages" => 2,
      "message" => %{
        "num_parts" => 1,
        "sender" => from,
        "content" => body
      },
      "messages" => [
        %{
          "id" => "1151346216",
          "recipient" => to
        }
      ],
      "status" => "success"
    }
  end
end
