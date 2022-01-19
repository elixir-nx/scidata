defmodule Scidata.MixProject do
  use Mix.Project

  @version "0.1.4"
  @repo_url "https://github.com/elixir-nx/scidata"

  def project do
    [
      app: :scidata,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      package: package(),
      description: "Datasets for science",

      # Docs
      name: "Scidata",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ssl, :inets]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.24.0", only: :dev, runtime: false},
      {:nimble_csv, "~> 1.1"},
      {:jason, "~> 1.0"},
      {:stb_image, "~> 0.1.2", optional: true}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @repo_url}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @repo_url,
      groups_for_modules: [
        Text: [
          Scidata.IMDBReviews,
          Scidata.Squad,
          Scidata.YelpFullReviews,
          Scidata.YelpPolarityReviews
        ],
        Vision: [
          Scidata.Caltech101,
          Scidata.CIFAR10,
          Scidata.CIFAR100,
          Scidata.FashionMNIST,
          Scidata.KuzushijiMNIST,
          Scidata.MNIST
        ]
      ]
    ]
  end
end
