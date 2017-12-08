# TxtLocalEx

An Elixir client for sending SMS with **txtLocal** APIs

## Install

1. Add `txt_local_ex` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:txt_local_ex, "~> 0.0.1"}]
  end
  ```

2. Ensure `txt_local_ex` is started before your application:

  ```elixir
  def application do
    [applications: [:txt_local_ex]]
  end
  ```


## Configure

Add the following to your `config.exs` file:

```elixir
config :txt_local_ex,
  api_key: "YOUR_API_KEY",
  rate_limit_scale: "RATE_LIMIT_SCALE", # in milli seconds
  rate_limit_count: "RATE_LIMIT_COUNT" # number of api calls allowed within the time scale
```

* **For Development/Test environments**

Add the following to your `config/dev.exs`/`config/test.exs` file:

```elixir
config :your_app, :txt_local_ex_api, TxtLocalEx.InMemoryMessenger
```

* **For Staging/Production environments**

Add the following to your `config/staging.exs`/`config/production.exs` file:

```elixir
config :your_app, :txt_local_ex_api, TxtLocalEx.HttpMessenger
```

## Usage

1. Set the messenger to use at the top level
```elixir
  @txt_local_api_client Application.get_env(:your_app, :txt_local_ex_api)
```

2. Send SMS
  * The `send_sms/3` function sends an sms to a given phone number from a given phone number.

  ```elixir
 # @txt_local_api_client.send_sms("from_number", "to_number", "body_text")
 iex(1)> @txt_local_api_client.send_sms("15005550001", "15005550002", "message text")
```
