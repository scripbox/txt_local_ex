defmodule TxtLocalEx.TestMessenger do
  @behaviour TxtLocalEx.Messenger

  @api_name "TXT_LOCAL_TEST"

  # Public API

  @doc false
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

  @doc false
  @spec bulk_send(String.t(), String.t(), List.t(), String.t() | nil) :: map()
  def bulk_send(api_key, from, messages, receipt_url \\ nil)

  def bulk_send(_api_key, _from, [], _receipt_url), do: %{messages: []}

  def bulk_send(api_key, from, messages, receipt_url) when is_list(messages) do
    bulk_send_response(api_key, from, messages, receipt_url)
  end

  @doc false
  @spec time_to_next_bucket(String.t()) :: tuple()
  def time_to_next_bucket(_) do
    {:ok, 0}
  end

  @doc false
  @spec name() :: String.t()
  def name do
    @api_name
  end

  @doc false
  @spec message_status(String.t(), String.t()) :: map()
  def message_status(_api_key, message_id) do
    message_status_response(message_id)
  end

  @doc false
  @spec batch_status(String.t(), String.t()) :: map()
  def batch_status(_api_key, batch_id) do
    batch_status_response(batch_id)
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

  defp batch_status_response(batch_id) do
    %{
      "batch_id" => batch_id,
      "messages" => [%{"recipient" => 918_123_456_789, "status" => "D"}],
      "num_delivered" => 1,
      "num_invalid" => 0,
      "num_messages" => 1,
      "num_undelivered" => 0,
      "num_unknown" => 0,
      "status" => "success"
    }
  end

  defp bulk_send_response(_api_key, _from, messages, receipt_url) do
    response_messages =
      messages
      |> Enum.with_index()
      |> Enum.map(fn {_message, i} ->
        %{
          "balance" => 12345,
          "batch_id" => i + 1000,
          "cost" => 2,
          "custom" => "",
          "message" => %{
            "content" => "This is your message",
            "num_parts" => 2,
            "sender" => "SENDER-ID"
          },
          "messages" => [%{"id" => i + 1, "recipient" => "mobile-number"}],
          "num_messages" => 1,
          "receipt_url" => receipt_url
        }
      end)

    %{
      "balance_post_send" => 12344,
      "balance_pre_send" => 12346,
      "messages" => response_messages,
      "status" => "success",
      "total_cost" => 2
    }
  end
end
