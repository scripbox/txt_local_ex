defmodule TxtLocalEx.HttpMessenger do
  @behaviour TxtLocalEx.Messenger
  @ets_bucket_prefix "txt-local-rate-limited-api"
  @dry_run_on "1"

  # Define API endpoints
  @send_sms_path "/send/?"
  @message_status_path "/status_message/?"

  @api_name "TXT_LOCAL_API"

  alias TxtLocalEx.Request

  # Public API

  @doc """
  The send_sms/4 function sends an sms to a
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
    check_rate_limit!(api_key)

    sms_payload = send_sms_payload(api_key, from, to, body, receipt_url, custom)

    case Request.request(:post, @send_sms_path, sms_payload) do
      {:ok, response} -> response.body
      {:error, error} -> raise error
    end
  end

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
    check_rate_limit!(api_key)

    sms_payload = message_status_payload(api_key, message_id)

    case Request.request(:post, @message_status_path, sms_payload) do
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
          args: api_key
        }
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
