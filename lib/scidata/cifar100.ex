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

  ## Options

    * `:transform_images` - A function that transforms images, defaults to
      `& &1`.

      It accepts a tuple like `{binary_data, tensor_type, data_shape}` which
      can be used for converting the `binary_data` to a tensor with a function
      like:

          fn {labels_binary, type, _shape} ->
            labels_binary
            |> Nx.from_binary(type)
            |> Nx.new_axis(-1)
            |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))
            |> Nx.to_batched_list(32)
          end

    * `:transform_labels` - similar to `:transform_images` but applied to
      dataset labels

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
    for <<example::size(3074)-binary <- content>>, reduce: {<<>>, <<>>} do
      {images, labels} ->
        <<label::size(2)-binary, image::size(3072)-binary>> = example

        {images <> image, labels <> label}
    end
  end

  defp download_dataset(dataset_type, opts) do
    transform_images = opts[:transform_images] || (& &1)
    transform_labels = opts[:transform_labels] || (& &1)

    files = Utils.get!(@base_url <> @dataset_file).body

    {imgs, labels} =
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
      |> Enum.reduce({<<>>, <<>>}, fn {image, label}, {image_acc, label_acc} ->
        {image_acc <> image, label_acc <> label}
      end)

    {transform_images.(
       {imgs, {:u, 8},
        if(dataset_type == :test, do: @test_images_shape, else: @train_images_shape)}
     ),
     transform_labels.(
       {labels, {:u, 8},
        if(dataset_type == :test, do: @test_labels_shape, else: @train_labels_shape)}
     )}
  end
end
