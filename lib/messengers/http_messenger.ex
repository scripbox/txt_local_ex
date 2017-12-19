defmodule TxtLocalEx.HttpMessenger do
  @behaviour TxtLocalEx.Messenger
  @ets_bucket_name "txt-local-rate-limited-api"

  # Define API endpoints
  @send_sms_path "/send/?"

  alias TxtLocalEx.Request

  # Public API

  @doc """
  The send_sms/4 function sends an sms to a
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
  @spec send_sms(String.t(), String.t(), String.t(), String.t()) :: map()
  def send_sms(from, to, body, receipt_url \\ "", custom \\ "") do
    check_rate_limit!() # raises ApiLimitExceeded if rate limit exceeded

    sms_payload = send_sms_payload(from, to, body, receipt_url, custom)

    case Request.post(@send_sms_path, sms_payload) do
      {:ok, response} -> response.body
      {:error, error} -> raise TxtLocalEx.Errors.ApiError, error.reason
    end
  end

  @doc """
  The time_to_next_bucket/0 function gets the time in seconds to next bucket limit.
  ## Example:
      ```
      iex(1)> TxtLocalEx.HttpMessenger.time_to_next_bucket
      {:ok, 5} # 5 secconds to next bucket reset
      ```
  """
  @spec time_to_next_bucket() :: tuple()
  def time_to_next_bucket do
    {_, _, ms_to_next_bucket, _, _} = ExRated.inspect_bucket(@ets_bucket_name,
                                                             time_scale_in_ms(),
                                                             api_limit())
    sec_to_next_bucket = round(ms_to_next_bucket / 1000.0)
    {:ok, sec_to_next_bucket}
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
    "TXT_LOCAL_API"
  end

  # Private API

  defp send_sms_payload(from, to, body, "", "") do
    %{"message" => body, "sender" => from, "numbers" => to, "test" => dry_run?()}
  end
  defp send_sms_payload(from, to, body, receipt_url, "") do
    %{"message" => body, "sender" => from, "numbers" => to, "receipt_url" => receipt_url, "test" => dry_run?()}
  end
  defp send_sms_payload(from, to, body, receipt_url, custom) do
    %{"message" => body, "sender" => from, "numbers" => to, "receipt_url" => receipt_url, "custom" => custom, "test" => dry_run?()}
  end

  defp dry_run? do
    Application.get_env(:txt_local_ex, :dry_run) == "1"
  end

  defp check_rate_limit! do
    case ExRated.check_rate(@ets_bucket_name, time_scale_in_ms(), api_limit()) do
      {:ok, current_count} -> {:ok, current_count}
      {:error, current_count} ->
        raise TxtLocalEx.Errors.ApiLimitExceeded, "API rate limit exceeded - #{current_count}"
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
end
