import Config

config :scidata, 
  max_concurrency: "MAX_CONCURRENCY" |> System.get_env("#{System.schedulers_online}") |> String.to_integer
