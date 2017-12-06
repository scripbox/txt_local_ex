defmodule TxtLocalEx.Messenger do
  @moduledoc ~S"""
  Behaviour for creating TxtLocalEx.Messenger messengers
  For more in-depth examples check out the
  [messengers in TxtLocalEx](https://github.com/scripbox/txt_local_ex/tree/master/lib/txt_local_ex/messengers).
  """

  @callback send_sms(from :: String.t, to :: String.t, body :: String.t, receipt_url :: String.t) :: map
end
