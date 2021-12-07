defmodule Scidata.MNIST do
  @moduledoc """
  Module for downloading the [MNIST dataset](http://yann.lecun.com/exdb/mnist/).
  """

  alias Scidata.Utils

  @base_url "https://storage.googleapis.com/cvdf-datasets/mnist/"
  @train_image_file "train-images-idx3-ubyte.gz"
  @train_label_file "train-labels-idx1-ubyte.gz"
  @test_image_file "t10k-images-idx3-ubyte.gz"
  @test_label_file "t10k-labels-idx1-ubyte.gz"

  @doc """
  Downloads the MNIST training dataset or fetches it locally.

  Returns a tuple of format:

      {{images_binary, images_type, images_shape},
       {labels_binary, labels_type, labels_shape}}

  If you want to one-hot encode the labels, you can:

      labels_binary
      |> Nx.from_binary(labels_type)
      |> Nx.new_axis(-1)
      |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))

  """
  def download() do
    {download_images(@train_image_file), download_labels(@train_label_file)}
  end

  @doc """
  Downloads the MNIST test dataset or fetches it locally.
  """
  def download_test() do
    {download_images(@test_image_file), download_labels(@test_label_file)}
  end

  defp download_images(image_file) do
    data = Utils.get!(@base_url <> image_file).body
    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> = data
    {images, {:u, 8}, {n_images, 1, n_rows, n_cols}}
  end

  defp download_labels(label_file) do
    data = Utils.get!(@base_url <> label_file).body
    <<_::32, n_labels::32, labels::binary>> = data
    {labels, {:u, 8}, {n_labels}}
  end
end
