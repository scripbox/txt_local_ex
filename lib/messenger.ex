defmodule TxtLocalEx.Messenger do
  @moduledoc ~S"""
  Behaviour for creating TxtLocalEx.Messenger messengers
  For more in-depth examples check out the
  [messengers in TxtLocalEx](https://github.com/scripbox/txt_local_ex/tree/master/lib/txt_local_ex/messengers).
  """

  @callback send_sms(
              api_key :: String.t(),
              from :: String.t(),
              to :: String.t(),
              body :: String.t(),
              receipt_url :: String.t(),
              custom :: String.t()
            ) :: map

  @callback bulk_send(
              api_key :: String.t(),
              from :: String.t(),
              messages :: List.t()
            ) :: map

  @callback time_to_next_bucket(String.t()) :: tuple

  @callback name() :: String.t()

  @callback message_status(
              api_key :: String.t(),
              message_id :: String.t()
            ) :: map

  @callback batch_status(
              api_key :: String.t(),
              batch_id :: String.t()
            ) :: map
end
