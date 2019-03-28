defmodule TxtLocalEx.HttpMessengerTest do
  import Mock

  use ExUnit.Case

  alias TxtLocalEx.HttpMessenger

  defmacro with_successful_response_mock(block) do
    quote do
      with_mock HTTPoison,
        request: fn method, url, body, headers, opts ->
          RequestMock.successful_api_response(method, url, body, headers, opts)
        end do
        unquote(block)
      end
    end
  end

  defmacro with_invalid_api_response_mock(block) do
    quote do
      with_mock HTTPoison,
        request: fn method, url, body, headers, opts ->
          RequestMock.invalid_api_response(method, url, body, headers, opts)
        end do
        unquote(block)
      end
    end
  end

  defmacro with_rate_limit_exceeded_mock(block) do
    quote do
      with_mock ExRated,
        check_rate: fn _ets_bucket_name, _time_scale_in_ms, api_limit ->
          {:error, :rand.uniform(api_limit)}
        end do
        unquote(block)
      end
    end
  end

  describe "send_sms/4" do
    test "returns success with valid attributes" do
      with_successful_response_mock do
        api_key = "API-KEY"
        sender_number = "SENDER"
        receiver_number = "RECEIVER"
        message_body = "message text"

        api_response =
          HttpMessenger.send_sms(api_key, sender_number, receiver_number, message_body)

        assert api_response["status"] == "success"
      end
    end

    test "raises exception with invalid API response" do
      with_invalid_api_response_mock do
        api_key = "API-KEY"
        sender_number = "SENDER"
        receiver_number = "RECEIVER"
        message_body = "message text"

        assert_raise TxtLocalEx.Errors.ApiError, ~r/error decoding response body/, fn ->
          HttpMessenger.send_sms(api_key, sender_number, receiver_number, message_body)
        end
      end
    end

    test "raises exception if API rate-limit exceeded" do
      with_rate_limit_exceeded_mock do
        api_key = "API-KEY"
        sender_number = "SENDER"
        receiver_number = "RECEIVER"
        message_body = "message text"

        assert_raise TxtLocalEx.Errors.ApiLimitExceeded, ~r/API rate limit exceeded/, fn ->
          HttpMessenger.send_sms(api_key, sender_number, receiver_number, message_body)
        end
      end
    end
  end
end
