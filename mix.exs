defmodule SciData.MixProject do
  use Mix.Project

  def project do
    [
      app: :scidata,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ssl, :inets]
    ]
  end

  defp deps do
    []
  end
end
