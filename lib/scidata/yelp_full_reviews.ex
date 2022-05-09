defmodule Scidata.YelpFullReviews do
  @moduledoc """
  Module for downloading the [Yelp Reviews dataset](https://www.yelp.com/dataset).
  """

  @base_url "https://s3.amazonaws.com/fast-ai-nlp/"

  @dataset_file "yelp_review_full_csv.tgz"

  alias Scidata.Utils
  alias NimbleCSV.RFC4180, as: CSV

  @doc """
  Downloads the Yelp Reviews training dataset or fetches it locally.

  ## Options.

    * `:base_url` - optional. Dataset base URL.
      Defaults to `"https://s3.amazonaws.com/fast-ai-nlp/"`
    * `:dataset_file` - optional. Dataset filename.
      Defaults to `"yelp_review_full_csv.tgz"`
    * `:cache_dir` - optional. Cache directory.
      Defaults to `System.tmp_dir!()`

  """
  @spec download(Keyword.t()) :: %{review: [binary(), ...], rating: [5 | 4 | 3 | 2 | 1]}
  def download(opts \\ []), do: download_dataset(:train, opts)

  @doc """
  Downloads the Yelp Reviews test dataset or fetches it locally.

  ## Options.

    * `:base_url` - optional. Dataset base URL.
      Defaults to `"https://s3.amazonaws.com/fast-ai-nlp/"`
    * `:dataset_file` - optional. Dataset filename.
      Defaults to `"yelp_review_full_csv.tgz"`
    * `:cache_dir` - optional. Cache directory.
      Defaults to `System.tmp_dir!()`

  """
  @spec download_test(Keyword.t()) :: %{
          review: [binary(), ...],
          rating: [5 | 4 | 3 | 2 | 1]
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
      rating: records |> Enum.map(fn x -> x |> List.first() |> String.to_integer() end)
    }
  end
end
