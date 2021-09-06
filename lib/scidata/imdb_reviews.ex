defmodule Scidata.IMDBReviews do
  @moduledoc """
  Module for downloading the [Large Movie Review Dataset](https://ai.stanford.edu/~amaas/data/sentiment/).
  """

  @base_url "http://ai.stanford.edu/~amaas/data/sentiment/"
  @dataset_file "aclImdb_v1.tar.gz"

  alias Scidata.Utils

  @type train_sentiment :: :pos | :neg | :unsup
  @type test_sentiment :: :pos | :neg
  @type opts :: [
          transform_inputs: ([binary, ...] -> any),
          transform_labels: ([integer, ...] -> any)
        ]

  @doc """
  Downloads the IMDB reviews training dataset or fetches it locally.

  `example_types` specifies which examples in the dataset should be returned
  according to each example's label: `:pos` for positive examples, `:neg` for
  negative examples, and `:unsup` for unlabeled examples.
  """
  @spec download(example_types: [test_sentiment]) :: %{review: [binary(), ...], sentiment: 1 | 0}
  def download(opts \\ []), do: download_dataset(:train, opts)

  @doc """
  Downloads the IMDB reviews test dataset or fetches it locally.

  `example_types` is the same argument in `download/2` but excludes `:unsup`
  because all unlabeled examples are in the training set.
  """
  @spec download_test(example_types: [test_sentiment]) :: %{
          review: [binary(), ...],
          sentiment: 1 | 0
        }
  def download_test(opts \\ []), do: download_dataset(:test, opts)

  defp download_dataset(dataset_type, opts) do
    example_types = opts[:example_types] || [:pos, :neg]
    transform_inputs = opts[:transform_inputs] || (& &1)
    transform_labels = opts[:transform_labels] || (& &1)

    files = Utils.get!(@base_url <> @dataset_file).body
    regex = ~r"#{dataset_type}/(#{Enum.join(example_types, "|")})/"

    {inputs, labels} =
      for {fname, contents} <- files,
          List.to_string(fname) =~ regex,
          reduce: {[], []} do
        {inputs, labels} ->
          {[contents | inputs], [get_label(fname) | labels]}
      end

    %{review: transform_inputs.(inputs), sentiment: transform_labels.(labels)}
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
