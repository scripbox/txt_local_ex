use Mix.Config

config :txt_local_ex,
  # in milli seconds
  rate_limit_scale: "60000",
  rate_limit_count: "1000",
  dry_run: "1",
  default_options: []
