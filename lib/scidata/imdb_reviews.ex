defmodule Scidata.IMDBReviews do
  @moduledoc """
  Module for downloading the [Large Movie Review Dataset](https://ai.stanford.edu/~amaas/data/sentiment/).
  """

  @base_url "http://ai.stanford.edu/~amaas/data/sentiment/"
  @dataset_file "aclImdb_v1.tar.gz"

  alias Scidata.Utils

  @type train_sentiment :: :pos | :neg | :unsup
  @type test_sentiment :: :pos | :neg

  @doc """
  Downloads the IMDB reviews training dataset or fetches it locally.

  `example_types` specifies which examples in the dataset should be returned
  according to each example's label: `:pos` for positive examples, `:neg` for
  negative examples, and `:unsup` for unlabeled examples. If no `example_types`
  are provided, `:pos` and `:neg` examples are fetched.
  """
  @spec download(example_types: [train_sentiment]) :: %{
          review: [binary(), ...],
          sentiment: [1 | 0 | nil]
        }
  def download(opts \\ []), do: download_dataset(:train, opts)

  @doc """
  Downloads the IMDB reviews test dataset or fetches it locally.

  `example_types` is the same as in `download/2`, but `:unsup` is
  unavailable because all unlabeled examples are in the training set.
  """
  @spec download_test(example_types: [test_sentiment]) :: %{
          review: [binary(), ...],
          sentiment: [1 | 0]
        }
  def download_test(opts \\ []), do: download_dataset(:test, opts)

  defp download_dataset(dataset_type, opts) do
    example_types = opts[:example_types] || [:pos, :neg]
    base_url = opts[:base_url] || @base_url
    dataset_file = opts[:dataset_file] || @dataset_file

    files = Utils.get!(base_url <> dataset_file).body
    regex = ~r"#{dataset_type}/(#{Enum.join(example_types, "|")})/"

    {inputs, labels} =
      for {fname, contents} <- files,
          List.to_string(fname) =~ regex,
          reduce: {[], []} do
        {inputs, labels} ->
          {[contents | inputs], [get_label(fname) | labels]}
      end

    %{review: inputs, sentiment: labels}
  end

  defp get_label(fname) do
    fname = List.to_string(fname)

    cond do
      fname =~ "pos" -> 1
      fname =~ "neg" -> 0
      fname =~ "unsup" -> nil
    end
  end
end
