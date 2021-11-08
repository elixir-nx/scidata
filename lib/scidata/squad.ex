defmodule Scidata.Squad do
  @moduledoc """
  Module for downloading the [SQuAD1.1 dataset](https://rajpurkar.github.io/SQuAD-explorer).
  """

  require Scidata.Utils
  alias Scidata.Utils

  @base_url "https://rajpurkar.github.io/SQuAD-explorer/dataset/"
  @dataset_file "train-v1.1.json"

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
    download_dataset()
  end

  defp download_dataset() do
    content =
      Utils.get!(@base_url <> @dataset_file).body
      |> Jason.decode!()

    content["data"]
  end
end
