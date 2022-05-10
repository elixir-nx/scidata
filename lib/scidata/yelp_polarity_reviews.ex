defmodule Scidata.YelpPolarityReviews do
  @moduledoc """
  Module for downloading the [Yelp Polarity Reviews dataset](https://course.fast.ai/datasets#nlp).
  """

  @base_url "https://s3.amazonaws.com/fast-ai-nlp/"

  @dataset_file "yelp_review_polarity_csv.tgz"

  alias Scidata.Utils
  alias NimbleCSV.RFC4180, as: CSV

  @doc """
  Downloads the Yelp Polarity Reviews training dataset or fetches it locally.

  ## Options.

    * `:base_url` - Dataset base URL.
      Defaults to `"https://s3.amazonaws.com/fast-ai-nlp/"`
    * `:dataset_file` - Dataset filename.
      Defaults to `"yelp_review_polarity_csv.tgz"`
    * `:cache_dir` - Cache directory.
      Defaults to `System.tmp_dir!()`

  """
  @spec download(Keyword.t()) :: %{review: [binary(), ...], sentiment: [1 | 0]}
  def download(opts \\ []), do: download_dataset(:train, opts)

  @doc """
  Downloads the Yelp Polarity Reviews test dataset or fetches it locally.

  ## Options.

    * `:base_url` - Dataset base URL.
      Defaults to `"https://s3.amazonaws.com/fast-ai-nlp/"`
    * `:dataset_file` - Dataset filename.
      Defaults to `"yelp_review_polarity_csv.tgz"`
    * `:cache_dir` - Cache directory.
      Defaults to `System.tmp_dir!()`

  """
  @spec download_test(Keyword.t()) :: %{
          review: [binary(), ...],
          sentiment: [1 | 0]
        }
  def download_test(opts \\ []), do: download_dataset(:test, opts)

  defp download_dataset(dataset_type, opts) do
    base_url = opts[:base_url] || @base_url
    dataset_file = opts[:dataset_file] || @dataset_file

    files = Utils.get!(base_url <> dataset_file, opts).body
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
