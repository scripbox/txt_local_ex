defmodule TxtLocalEx.TestMessenger do
  @behaviour TxtLocalEx.Messenger

  @api_name "TXT_LOCAL_TEST"

  # Public API

  @doc """
  The send_sms/4 function sends an sms to a
  given phone number from a given phone number.
  ## Example:
    ```
    iex(1)> TxtLocalEx.TestMessenger.send_sms("API-KEY", "SENDER", "RECEIVER", "message text")
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
  @spec send_sms(String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) :: map()
  def send_sms(_, from, _, _, _, _) when from == "",
    do: %{
      "errors" => [%{"code" => 43, "message" => "Invalid sender name"}],
      "status" => "failure"
    }

  def send_sms(_, _, to, _, _, _) when to == "",
    do: %{
      "errors" => [%{"code" => 4, "message" => "No recipients specified"}],
      "status" => "failure"
    }

  def send_sms(_, _, _, body, _, _) when body == "",
    do: %{"errors" => [%{"code" => 5, "message" => "No message content"}], "status" => "failure"}

  def send_sms(_, from, to, body, _receipt_url, _custom) do
    send_sms_response(from, to, body)
  end

  @doc """
  The time_to_next_bucket/0 function gets the time in ms to next bucket limit.
  ## Example:
      ```
      iex(1)> TxtLocalEx.Messenger.TestMessenger.time_to_next_bucket(api_key)
      {:ok, 0} # 0 ms to next bucket reset
      ```
  """
  @spec time_to_next_bucket(String.t()) :: tuple()
  def time_to_next_bucket(_) do
    {:ok, 0}
  end

  @doc """
  The name/0 function returns the name of the API Client.
  ## Example:
      ```
      iex(1)> TxtLocalEx.Messenger.TestMessenger.name
      "[TxtLocal] Test"
      ```
  """
  @spec name() :: String.t()
  def name do
    @api_name
  end

  @doc """
  The message_status/2 function can be used to determine the delivery status of a sent message.
  ## Example:
    ```
    iex(1)> TxtLocalEx.TestMessenger.message_status("API-KEY", "MESSAGE-ID")
    %{
      "message" => %{
        "id" => 1151895224,
        "recipient" => 918123456789,
        "type" => "sms",
        "status" => "D",
        "date" => "2013-07-04 14:31:18"
      },
      "status" => "success"
    }
    ```
  """
  @spec message_status(String.t(), String.t()) :: map()
  def message_status(api_key, message_id) do
    message_status_response(message_id)
  end

  # Private API
  defp send_sms_response(from, to, body) do
    %{
      "balance" => 1162,
      "batch_id" => 123_456_789,
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

  defp message_status_response(message_id) do
    %{
      "message" => %{
        "id" => message_id,
        "recipient" => 918_123_456_789,
        "type" => "sms",
        "status" => "D",
        "date" => "2013-07-04 14:31:18"
      },
      "status" => "success"
    }
  end
end
