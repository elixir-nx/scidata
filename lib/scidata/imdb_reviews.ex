defmodule Scidata.IMDBReviews do
  @base_url "http://ai.stanford.edu/~amaas/data/sentiment/"
  @dataset_file "aclImdb_v1.tar.gz"

  alias Scidata.Utils

  def download(
        example_types \\ [:pos, :neg],
        opts \\ []
      ) do
    download_dataset(example_types, :train, opts)
  end

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
      files
      |> Enum.filter(fn {fname, _} ->
        file_match?(fname, dataset_type, example_types)
      end)
      |> Enum.reduce(
        {[], []},
        fn {fname, contents}, {inputs, labels} ->
          {[contents | inputs], [get_label(fname) | labels]}
        end
      )

    {transform_inputs.(inputs), transform_labels.(labels)}
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
