defmodule TxtLocalEx.HttpMessenger do
  @behaviour TxtLocalEx.Messenger
  @ets_bucket_prefix "txt-local-rate-limited-api"
  @dry_run_on "1"

  # Define API endpoints
  @send_sms_path "/send/?"
  @bulk_send_path "/bulk_json/?"
  @message_status_path "/status_message/?"
  @batch_status_path "/status_batch/?"

  @api_name "TXT_LOCAL_API"

  alias TxtLocalEx.Request

  # Public API

  @doc """
  The send_sms/6 function sends an sms to a
  given phone number from a given phone number.
  ## Example:
    ```
    iex(1)> TxtLocalEx.HttpMessenger.send_sms("API-KEY", "SENDER", "RECEIVER", "message text")
    %{
      "balance" => 1162,
      "batch_id" => 123456789,
      "cost" => 2,
      "message" => %{
        "content" => "This is your message",
        "num_parts" => 1,
        "sender" => "Jims Autos"
      },
      "messages" => [
        %{"id" => "1151346216", "recipient" => 447123456789},
        %{"id" => "1151347780", "recipient" => 447987654321}
      ],
      "num_messages" => 2,
      "status" => "success"
    }
    ```
  """
  @spec send_sms(String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) :: map()
  def send_sms(api_key, from, to, body, receipt_url \\ "", custom \\ "") do
    # raises ApiLimitExceeded if rate limit exceeded
    if rate_limit_enabled?(), do: check_rate_limit!(api_key)

    sms_payload = send_sms_payload(api_key, from, to, body, receipt_url, custom)

    case Request.request(:post, @send_sms_path, sms_payload) do
      {:ok, response} -> response.body
      {:error, error} -> raise error
    end
  end

  @doc """
  The bulk_send/3 function sends different messages to multiple recipients in bulk.
  ## Example:
    ```
    iex(1)> messages = [
      %{
        "number" => "mobile-number",
        "text" => "This is your message"
      }
    ]
    iex(2)> TxtLocalEx.HttpMessenger.bulk_send("API-KEY", "SENDER", messages)
    %{
      "balance_post_send" => 12344,
      "balance_pre_send" => 12346,
      "messages" => [
        %{
          "balance" => 12345,
          "batch_id" => 596486325,
          "cost" => 2,
          "custom" => "message-custom-id",
          "message" => %{
            "content" => "This is your message",
            "num_parts" => 2,
            "sender" => "SBTEST"
          },
          "messages" => [%{"id" => 1, "recipient" => "mobile-number"}],
          "num_messages" => 1,
          "receipt_url" => ""
        }
      ],
      "status" => "success",
      "total_cost" => 2
    }
  """
  @spec bulk_send(String.t(), String.t(), List.t(), String.t() | nil) :: map()
  def bulk_send(api_key, from, messages, receipt_url \\ nil)

  def bulk_send(_api_key, _from, [], _), do: %{messages: []}

  def bulk_send(api_key, from, messages, receipt_url) when is_list(messages) do
    # raises ApiLimitExceeded if rate limit exceeded
    check_rate_limit!(api_key)

    payload = bulk_send_payload(api_key, from, messages, receipt_url)

    case Request.request(:post, @bulk_send_path, payload) do
      {:ok, response} -> response.body
      {:error, error} -> raise TxtLocalEx.Errors.ApiError, error.reason
    end
  end

  def bulk_send(_api_key, _from, _messages, _), do: {:error, "Invalid messages payload"}

  @doc """
  The time_to_next_bucket/0 function gets the time in seconds to next bucket limit.
  ## Example:
      ```
      iex(1)> TxtLocalEx.HttpMessenger.time_to_next_bucket("API-KEY")
      {:ok, 5} # 5 secconds to next bucket reset
      ```
  """
  @spec time_to_next_bucket(String.t()) :: tuple()
  def time_to_next_bucket(api_key) do
    {_, _, ms_to_next_bucket, _, _} =
      ExRated.inspect_bucket(ets_bucket_name(api_key), time_scale_in_ms(), api_limit())

    sec_to_next_bucket = round(ms_to_next_bucket / 1000.0)
    {:ok, sec_to_next_bucket}
  end

  @doc """
  The name/0 function returns the name of the API Client.
  ## Example:
      ```
      iex(1)> TxtLocalEx.HttpMessenger.name
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
    iex(1)> TxtLocalEx.HttpMessenger.message_status("API-KEY", "MESSAGE-ID")
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
    # raises ApiLimitExceeded if rate limit exceeded
    if rate_limit_enabled?(), do: check_rate_limit!(api_key)

    message_payload = message_status_payload(api_key, message_id)

    case Request.request(:post, @message_status_path, message_payload) do
      {:ok, response} -> response.body
      {:error, error} -> raise TxtLocalEx.Errors.ApiError, error.reason
    end
  end

  @doc """
  The batch_status/2 function can be used to generate a delivery report for an entire batch send
  ## Example:
    ```
    iex(1)> TxtLocalEx.HttpMessenger.batch_status("API-KEY", "BATCH-ID")
    %{
      "batch_id" => 136546495,
      "num_messages" => 2,
      "num_delivered" => 2,
      "num_undelivered" => 0,
      "num_unknown" => 0,
      "num_invalid" => 0,
      "messages" => [%{"recipient" => 918123456789, "status" => "D"}],
      "status" => "success"
    }
    ```
  """
  @spec batch_status(String.t(), String.t()) :: map()
  def batch_status(api_key, batch_id) do
    # raises ApiLimitExceeded if rate limit exceeded
    check_rate_limit!(api_key)

    batch_payload = batch_status_payload(api_key, batch_id)

    case Request.request(:post, @batch_status_path, batch_payload) do
      {:ok, response} -> response.body
      {:error, error} -> raise error
    end
  end

  # Private API

  defp send_sms_payload(api_key, from, to, body, "", "") do
    %{
      "apiKey" => api_key,
      "message" => body,
      "sender" => from,
      "numbers" => to,
      "test" => dry_run?()
    }
  end

  defp send_sms_payload(api_key, from, to, body, receipt_url, "") do
    %{
      "apiKey" => api_key,
      "message" => body,
      "sender" => from,
      "numbers" => to,
      "receipt_url" => receipt_url,
      "test" => dry_run?()
    }
  end

  defp send_sms_payload(api_key, from, to, body, receipt_url, custom) do
    %{
      "apiKey" => api_key,
      "message" => body,
      "sender" => from,
      "numbers" => to,
      "receipt_url" => receipt_url,
      "custom" => custom,
      "test" => dry_run?()
    }
  end

  defp message_status_payload(api_key, message_id) do
    %{
      "apiKey" => api_key,
      "message_id" => message_id
    }
  end

  defp batch_status_payload(api_key, batch_id) do
    %{
      "apiKey" => api_key,
      "batch_id" => batch_id
    }
  end

  defp bulk_send_payload(api_key, from, messages, receipt_url) do
    data_payload =
      %{
        "sender" => from,
        "messages" => messages,
        "receiptUrl" => receipt_url,
        "test" => dry_run?()
      }
      |> Jason.encode!()

    %{
      "apiKey" => api_key,
      "data" => data_payload
    }
  end

  defp dry_run? do
    Application.get_env(:txt_local_ex, :dry_run) == @dry_run_on
  end

  defp check_rate_limit!(api_key) do
    case ExRated.check_rate(ets_bucket_name(api_key), time_scale_in_ms(), api_limit()) do
      {:ok, current_count} ->
        {:ok, current_count}

      {:error, current_count} ->
        raise %TxtLocalEx.Errors.ApiLimitExceeded{
          reason: "API rate limit exceeded - #{current_count}",
          args: [time_scale_in_ms(), api_limit()]
        }
    end
  end

  defp rate_limit_enabled? do
    {
      Application.get_env(:txt_local_ex, :rate_limit_count),
      Application.get_env(:txt_local_ex, :rate_limit_scale)
    }
    |> case do
      {nil, _} ->
        false

      {_, nil} ->
        false

      {_, _} ->
        true
    end
  end

  defp time_scale_in_ms do
    {time_scale, _} = Integer.parse(Application.get_env(:txt_local_ex, :rate_limit_scale))
    time_scale
  end

  defp api_limit do
    {api_limit_rate, _} = Integer.parse(Application.get_env(:txt_local_ex, :rate_limit_count))
    api_limit_rate
  end

  defp ets_bucket_name(api_key) do
    @ets_bucket_prefix <> api_key
  end
end
