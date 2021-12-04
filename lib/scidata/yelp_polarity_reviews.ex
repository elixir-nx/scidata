defmodule Scidata.YelpPolarityReviews do
  @moduledoc """
  Module for downloading the [Yelp Reviews dataset](https://www.yelp.com/dataset).
  """

  @base_url "https://s3.amazonaws.com/fast-ai-nlp/"

  @dataset_file "yelp_review_polarity_csv.tgz"

  alias Scidata.Utils
  alias NimbleCSV.RFC4180, as: CSV

  @doc """
  Downloads the Yelp Polarity Reviews training dataset or fetches it locally.
  """
  @spec download() :: %{review: [binary(), ...], sentiment: [1 | 0]}
  def download(), do: download_dataset(:train)

  @doc """
  Downloads the Yelp Polarity Reviews test dataset or fetches it locally.
  """
  @spec download_test() :: %{
          review: [binary(), ...],
          sentiment: [1 | 0]
        }
  def download_test(), do: download_dataset(:test)

  defp download_dataset(dataset_type) do
    files = Utils.get!(@base_url <> @dataset_file).body
    regex = ~r"#{dataset_type}"

    records =
      for {fname, contents} <- files,
          List.to_string(fname) =~ regex,
          reduce: [[]] do
        _ -> CSV.parse_string(contents, skip_headers: false)
      end

    %{
      review: records |> Enum.map(&List.last(&1)),
      sentiment: get_rating(records)
    }
  end

  defp get_rating(records) do
    Enum.map(records, fn
      ["1" | _] -> 0
      ["2" | _] -> 1
    end)
  end
end
