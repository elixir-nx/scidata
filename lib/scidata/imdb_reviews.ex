defmodule Scidata.IMDBReviews do
  @moduledoc """
  Module for downloading the [Large Movie Review Dataset](https://ai.stanford.edu/~amaas/data/sentiment/).
  """

  @base_url "http://ai.stanford.edu/~amaas/data/sentiment/"
  @dataset_file "aclImdb_v1.tar.gz"

  alias Scidata.Utils

  @type sentiments :: [atom]
  @type transform_type :: atom
  @type transform_fn :: ([binary, ...] -> any)
  @type transform_opt :: {transform_type, transform_fn}
  @type opts :: [transform_opt]

  @doc """
  Downloads the IMDB reviews training dataset or fetches it locally.

  `example_types` specifies which examples in the dataset should be returned
  according to each example's label: `:pos` for positive examples, `:neg` for
  negative examples, and `:unsup` for unlabeled examples.
  """
  @spec download(sentiments, opts()) ::
          %{review: any(), sentiment: any()}
  def download(
        example_types \\ [:pos, :neg],
        opts \\ []
      ) do
    download_dataset(example_types, :train, opts)
  end

  @doc """
  Downloads the IMDB reviews test dataset or fetches it locally.

  `example_types` is the same argument in `download/2` but excludes `:unsup`
  because all unlabeled examples are in the training set.
  """
  @spec download_test(sentiments, opts()) ::
          %{review: any(), sentiment: any()}
  def download_test(
        example_types \\ [:pos, :neg],
        opts \\ []
      ) do
    download_dataset(example_types, :test, opts)
  end

  defp download_dataset(example_types, dataset_type, opts) do
    transform_inputs = opts[:transform_inputs] || (& &1)
    transform_labels = opts[:transform_labels] || (& &1)

    files = Utils.get!(@base_url <> @dataset_file).body

    {inputs, labels} =
      for {fname, contents} <- files,
          file_match?(fname, dataset_type, example_types),
          reduce: {[], []} do
        {inputs, labels} ->
          {[contents | inputs], [get_label(fname) | labels]}
      end

    %{review: transform_inputs.(inputs), sentiment: transform_labels.(labels)}
  end

  defp file_match?(fname, dataset_type, example_types) do
    pattern = ~r/#{dataset_type}\/(#{Enum.join(example_types, "|")})\//
    String.match?(List.to_string(fname), pattern)
  end

  defp get_label(fname) do
    cond do
      String.match?(List.to_string(fname), ~r/pos/) -> 1
      String.match?(List.to_string(fname), ~r/neg/) -> 0
      String.match?(List.to_string(fname), ~r/unsup/) -> nil
    end
  end
end
