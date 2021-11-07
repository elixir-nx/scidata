defmodule Scidata.Squad do
  @moduledoc """
  Module for downloading the [Squad dataset](https://rajpurkar.github.io/SQuAD-explorer).
  """

  require Scidata.Utils
  alias Scidata.Utils

  @base_url "https://rajpurkar.github.io/SQuAD-explorer/dataset/"
  @dataset_file "train-v1.1.json"

  @title "SQuAD: 100,000+ Questions for Machine Comprehension of Text"
  @author "Pranav Rajpurkar, Jian Zhang, Konstantin Lopyrev, Percy Liang"
  @year "2016"
  @month "November"

  @description """
  Stanford Question Answering Dataset (SQuAD) is a reading comprehension
  dataset, consisting of questions posed by crowdworkers on a set of Wikipedia
  articles, where the answer to every question is a segment of text, or span,
  from the corresponding reading passage, or the question might be unanswerable.
  """

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
  def info do
    %{
      "article" => %{
        "title" => @title,
        "author" => @author,
        "year" => @year,
        "month" => @month
      },
      "description" => @description
    }
  end

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
