defmodule Scidata.CIFAR10 do
  @moduledoc """
  Module for downloading the [CIFAR10 dataset](https://www.cs.toronto.edu/~kriz/cifar.html).
  """

  require Scidata.Utils
  alias Scidata.Utils

  @base_url "https://www.cs.toronto.edu/~kriz/"
  @dataset_file "cifar-10-binary.tar.gz"
  @train_images_shape {50000, 3, 32, 32}
  @train_labels_shape {50000}
  @test_images_shape {10000, 3, 32, 32}
  @test_labels_shape {10000}

  @doc """
  Downloads the CIFAR10 training dataset or fetches it locally.

  Returns a tuple of format:

      {{images_binary, images_type, images_shape},
       {labels_binary, labels_type, labels_shape}}

  If you want to one-hot encode the labels, you can:

      labels_binary
      |> Nx.from_binary(labels_type)
      |> Nx.new_axis(-1)
      |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))

  ## Examples

      iex> Scidata.CIFAR10.download()
      {{<<59, 43, 50, 68, 98, 119, 139, 145, 149, 149, 131, 125, 142, 144, 137, 129,
      137, 134, 124, 139, 139, 133, 136, 139, 152, 163, 168, 159, 158, 158, 152,
      148, 16, 0, 18, 51, 88, 120, 128, 127, 126, 116, 106, 101, 105, 113, 109,
      112, ...>>, {:u, 8}, {50000, 3, 32, 32}},
      {<<6, 9, 9, 4, 1, 1, 2, 7, 8, 3, 4, 7, 7, 2, 9, 9, 9, 3, 2, 6, 4, 3, 6, 6, 2,
          6, 3, 5, 4, 0, 0, 9, 1, 3, 4, 0, 3, 7, 3, 3, 5, 2, 2, 7, 1, 1, 1, ...>>,
        {:u, 8}, {50000}}}

  """
  def download() do
    download_dataset(:train)
  end

  @doc """
  Downloads the CIFAR10 test dataset or fetches it locally.

  Accepts the same options as `download/1`.
  """
  def download_test() do
    download_dataset(:test)
  end

  defp parse_images(content) do
    for <<example::size(3073)-binary <- content>>, reduce: {<<>>, <<>>} do
      {images, labels} ->
        <<label::size(8)-bitstring, image::size(3072)-binary>> = example

        {images <> image, labels <> label}
    end
  end

  defp download_dataset(dataset_type) do
    files = Utils.get!(@base_url <> @dataset_file).body

    {imgs, labels} =
      files
      |> Enum.filter(fn {fname, _} ->
        String.match?(
          List.to_string(fname),
          case dataset_type do
            :train -> ~r/data_batch/
            :test -> ~r/test_batch/
          end
        )
      end)
      |> Enum.map(fn {_, content} -> Task.async(fn -> parse_images(content) end) end)
      |> Enum.map(&Task.await(&1, :infinity))
      |> Enum.reduce({<<>>, <<>>}, fn {image, label}, {image_acc, label_acc} ->
        {image_acc <> image, label_acc <> label}
      end)

    {{imgs, {:u, 8}, if(dataset_type == :test, do: @test_images_shape, else: @train_images_shape)},
     {labels, {:u, 8}, if(dataset_type == :test, do: @test_labels_shape, else: @train_labels_shape)}}
  end
end
