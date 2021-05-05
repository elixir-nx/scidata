defmodule Scidata.IMDBReviews do
  @base_url "http://ai.stanford.edu/~amaas/data/sentiment/"
  @dataset_file "aclImdb_v1.tar.gz"

  alias Scidata.Utils

  def download(opts \\ []) do
    download_dataset(:train, opts)
  end

  def download_test(opts \\ []) do
    download_dataset(:test, opts)
  end

  defp download_dataset(dataset_type, opts) do
    transform_inputs = opts[:transform_inputs] || (& &1)
    transform_labels = opts[:transform_labels] || (& &1)

    files = Utils.get!(@base_url <> @dataset_file).body

    pos_files =
      Enum.filter(files, fn {fname, _} ->
        file_match?(fname, dataset_type, :pos)
      end)

    neg_files =
      Enum.filter(files, fn {fname, _} ->
        file_match?(fname, dataset_type, :neg)
      end)

    :rand.seed(:exsss, {101, 102, 103})

    {inputs, labels} =
      pos_files
      |> Enum.zip(Stream.repeatedly(fn -> 1 end))
      |> Enum.concat(Enum.zip(neg_files, Stream.repeatedly(fn -> 0 end)))
      |> Enum.shuffle()
      |> Enum.reduce(
        {[], []},
        fn {{_fname, contents}, label}, {inputs, labels} ->
          {[contents | inputs], [label | labels]}
        end
      )

    {transform_inputs.(inputs), transform_labels.(labels)}
  end

  defp file_match?(fname, dataset_type, label_type) do
    String.match?(List.to_string(fname), ~r/#{dataset_type}\/#{label_type}/)
  end
end
