defmodule Scidata.CIFAR10 do
  alias Scidata.Utils

  @default_data_path "tmp/cifar10"
  @base_url 'https://www.cs.toronto.edu/~kriz/'
  @dataset_file 'cifar-10-binary.tar.gz'

  defp parse_images(content) do
    for <<example::size(3073)-binary <- content>>, reduce: {<<>>, <<>>} do
      {images, labels} ->
        <<label::size(8)-bitstring, image::size(3072)-binary>> = example

        {images <> image, labels <> label}
    end
  end

  @doc """
  Downloads the CIFAR10 dataset or fetches it locally.
  ## Options
  * `datapath` - path where the dataset .gz should be stored locally
  * `transform_images/1` - accepts accept a tuple like
      `{binary_data, tensor_type, data_shape}` which can be used for
      converting the `binary_data` to a tensor with a function like
          fn {labels_binary, type, _shape} ->
            labels_binary
            |> Nx.from_binary(type)
            |> Nx.new_axis(-1)
            |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))
            |> Nx.to_batched_list(32)
          end
  * `transform_labels/1` - similar to `transform_images/1` but applied to
      dataset labels

  Examples:
    iex> Scidata.CIFAR10.download()
    Fetching cifar-10-binary.tar.gz from https://www.cs.toronto.edu/~kriz/

    {{<<59, 43, 50, 68, 98, 119, 139, 145, 149, 149, 131, 125, 142, 144, 137, 129,
    137, 134, 124, 139, 139, 133, 136, 139, 152, 163, 168, 159, 158, 158, 152,
    148, 16, 0, 18, 51, 88, 120, 128, 127, 126, 116, 106, 101, 105, 113, 109,
    112, ...>>, {:u, 8}, {50000, 3, 32, 32}},
    {<<6, 9, 9, 4, 1, 1, 2, 7, 8, 3, 4, 7, 7, 2, 9, 9, 9, 3, 2, 6, 4, 3, 6, 6, 2,
        6, 3, 5, 4, 0, 0, 9, 1, 3, 4, 0, 3, 7, 3, 3, 5, 2, 2, 7, 1, 1, 1, ...>>,
      {:u, 8}, {50000}}}
  """
  def download(opts \\ []) do
    data_path = opts[:data_path] || @default_data_path
    transform_images = opts[:transform_images] || fn out -> out end
    transform_labels = opts[:transform_labels] || fn out -> out end

    gz = Utils.unzip_cache_or_download(@base_url, @dataset_file, data_path)

    with {:ok, files} <- :erl_tar.extract({:binary, gz}, [:memory, :compressed]) do
      {imgs, labels} =
        files
        |> Enum.filter(fn {fname, _} -> String.match?(List.to_string(fname), ~r/data_batch/) end)
        |> Enum.map(fn {_, content} -> Task.async(fn -> parse_images(content) end) end)
        |> Enum.map(&Task.await(&1, :infinity))
        |> Enum.reduce({<<>>, <<>>}, fn {image, label}, {image_acc, label_acc} ->
          {image_acc <> image, label_acc <> label}
        end)

      {transform_images.({imgs, {:u, 8}, {50000, 3, 32, 32}}),
       transform_labels.({labels, {:u, 8}, {50000}})}
    end
  end
end
