defmodule Scidata.Squad do
  @moduledoc """
  Module for downloading the [SQuAD1.1 dataset](https://rajpurkar.github.io/SQuAD-explorer).
  """

  require Scidata.Utils
  alias Scidata.Utils

  @base_url "https://rajpurkar.github.io/SQuAD-explorer/dataset/"
  @train_dataset_file "train-v1.1.json"
  @test_dataset_file "dev-v1.1.json"

  @doc """
  Downloads the SQuAD dataset.

  ## Examples

      iex> Scidata.Squad.download()
      %{
        [
          %{
            "paragraphs" => [
              %{
                "context" => "In many cities along the North American...",
                "qas" => [
                  %{
                    "answers" => [%{"answer_start" => 324, "text" => "hundreds"}],
                    "id" => "56d8a0ddbfea0914004b7706",
                    "question" => "How many people protested on the San Francisco torch route?"
                  },
                  ...
                ]
              }
              ...
            ]
          }
        ]
      }
  """

  def download() do
    download_dataset(@train_dataset_file)
  end

  def download_test() do
    download_dataset(@test_dataset_file)
  end

  defp download_dataset(dataset_name) do
    content =
      Utils.get!(@base_url <> dataset_name).body
      |> Jason.decode!()

    content["data"]
  end
end
