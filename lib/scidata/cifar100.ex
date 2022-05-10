defmodule Scidata.CIFAR100 do
  @moduledoc """
  Module for downloading the [CIFAR100 dataset](https://www.cs.toronto.edu/~kriz/cifar.html).
  """

  require Scidata.Utils
  alias Scidata.Utils

  @base_url "https://www.cs.toronto.edu/~kriz/"
  @dataset_file "cifar-100-binary.tar.gz"
  @train_images_shape {50000, 3, 32, 32}
  @train_labels_shape {50000, 2}
  @test_images_shape {10000, 3, 32, 32}
  @test_labels_shape {10000, 2}

  @doc """
  Downloads the CIFAR100 training dataset or fetches it locally.

  Returns a tuple of format:

      {{images_binary, images_type, images_shape},
       {labels_binary, labels_type, labels_shape}}

  If you want to one-hot encode the labels, you can:

      labels_binary
      |> Nx.from_binary(labels_type)
      |> Nx.new_axis(-1)
      |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))

  ## Options.

    * `:base_url` - Dataset base URL.
      Defaults to `"https://www.cs.toronto.edu/~kriz/"`
    * `:dataset_file` - Dataset filename.
      Defaults to `"cifar-100-binary.tar.gz"`
    * `:cache_dir` - Cache directory.
      Defaults to `System.tmp_dir!()`

  ## Examples

      iex> Scidata.CIFAR100.download()
      {{<<59, 43, 50, 68, 98, 119, 139, 145, 149, 149, 131, 125, 142, 144, 137, 129,
      137, 134, 124, 139, 139, 133, 136, 139, 152, 163, 168, 159, 158, 158, 152,
      148, 16, 0, 18, 51, 88, 120, 128, 127, 126, 116, 106, 101, 105, 113, 109,
      112, ...>>, {:u, 8}, {50000, 3, 32, 32}},
      {<<6, 9, 9, 4, 1, 1, 2, 7, 8, 3, 4, 7, 7, 2, 9, 9, 9, 3, 2, 6, 4, 3, 6, 6, 2,
          6, 3, 5, 4, 0, 0, 9, 1, 3, 4, 0, 3, 7, 3, 3, 5, 2, 2, 7, 1, 1, 1, ...>>,
        {:u, 8}, {50000, 2}}}

  """
  def download(opts \\ []) do
    download_dataset(:train, opts)
  end

  @doc """
  Downloads the CIFAR100 test dataset or fetches it locally.

  Accepts the same options as `download/1`.
  """
  def download_test(opts \\ []) do
    download_dataset(:test, opts)
  end

  defp parse_images(content) do
    {images, labels} =
      for <<example::size(3074)-binary <- content>>, reduce: {[], []} do
        {images, labels} ->
          <<label::size(2)-binary, image::size(3072)-binary>> = example
          {[image | images], [label | labels]}
      end

    {Enum.reverse(images), Enum.reverse(labels)}
  end

  defp download_dataset(dataset_type, opts) do
    base_url = opts[:base_url] || @base_url
    dataset_file = opts[:dataset_file] || @dataset_file

    files = Utils.get!(base_url <> dataset_file, opts).body

    {images, labels} =
      files
      |> Enum.filter(fn {fname, _} ->
        String.match?(
          List.to_string(fname),
          case dataset_type do
            :train -> ~r/train.bin/
            :test -> ~r/test.bin/
          end
        )
      end)
      |> Enum.map(fn {_, content} -> Task.async(fn -> parse_images(content) end) end)
      |> Enum.map(&Task.await(&1, :infinity))
      |> Enum.unzip()

    images = IO.iodata_to_binary(images)
    labels = IO.iodata_to_binary(labels)

    {{images, {:u, 8},
      if(dataset_type == :test, do: @test_images_shape, else: @train_images_shape)},
     {labels, {:u, 8},
      if(dataset_type == :test, do: @test_labels_shape, else: @train_labels_shape)}}
  end
end
