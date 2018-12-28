defmodule TxtLocalEx.HttpMessengerTest do
  import Mock

  use ExUnit.Case

  alias TxtLocalEx.HttpMessenger

  defmacro with_request_mock(block) do
    quote do
      with_mock HTTPoison,
        request: fn method, url, body, headers, opts ->
          RequestMock.request(method, url, body, headers, opts)
        end do
        unquote(block)
      end
    end
  end

  describe "send_sms/4" do
    test "returns success with valid attributes" do
      with_request_mock do
        api_key = "API-KEY"
        sender_number = "SENDER"
        receiver_number = "RECEIVER"
        message_body = "message text"

        api_response =
          HttpMessenger.send_sms(api_key, sender_number, receiver_number, message_body)

        assert api_response["status"] == "success"
      end
    end
  end
end
