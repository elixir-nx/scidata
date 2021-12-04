defmodule Scidata.YelpPolarityReviews do
  @moduledoc """
  Module for downloading the [Yelp Reviews dataset](https://www.yelp.com/dataset).
  """

  @base_url "https://s3.amazonaws.com/fast-ai-nlp/"

  @dataset_file "yelp_review_polarity_csv.tgz"

  alias Scidata.Utils

  @doc """
  Downloads the Yelp Polarity Reviews training dataset or fetches it locally.
  """
  @spec download() :: %{review: [binary(), ...], sentiment: 2 | 1}
  def download(), do: download_dataset(:train)

  @doc """
  Downloads the Yelp Polarity Reviews test dataset or fetches it locally.
  """
  @spec download_test() :: %{
          review: [binary(), ...],
          sentiment: 2 | 1
        }
  def download_test(), do: download_dataset(:test)

  defp download_dataset(dataset_type) do
    files = Utils.get!(@base_url <> @dataset_file).body
    regex = ~r"#{dataset_type}"

    [records | _] =
      for {fname, contents} <- files do
        if List.to_string(fname) =~ regex do
          contents
          |> StringIO.open()
          |> elem(1)
          |> IO.binstream(:line)
          |> CSV.decode!()
          |> Enum.to_list()
        end
      end

    %{
      review: records |> Enum.map(&List.last(&1)),
      sentiment: records |> Enum.map(fn x -> x |> List.first() |> String.to_integer() end)
    }
  end
end
