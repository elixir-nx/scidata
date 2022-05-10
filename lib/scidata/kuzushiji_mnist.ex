defmodule Scidata.KuzushijiMNIST do
  @moduledoc """
  Module for downloading the [Kuzushiji-MNIST dataset](https://github.com/rois-codh/kmnist).
  """

  alias Scidata.Utils

  @base_url "http://codh.rois.ac.jp/kmnist/dataset/kmnist/"
  @train_image_file "train-images-idx3-ubyte.gz"
  @train_label_file "train-labels-idx1-ubyte.gz"
  @test_image_file "t10k-images-idx3-ubyte.gz"
  @test_label_file "t10k-labels-idx1-ubyte.gz"

  @doc """
  Downloads the Kuzushiji MNIST training dataset or fetches it locally.

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
      Defaults to `"http://codh.rois.ac.jp/kmnist/dataset/kmnist/"`
    * `:train_image_file` - Training set image filename.
      Defaults to `"train-images-idx3-ubyte.gz"`
    * `:train_label_file` - Training set label filename.
      Defaults to `"train-images-idx1-ubyte.gz"`
    * `:test_image_file` - Test set image filename.
      Defaults to `"test-images-idx3-ubyte.gz"`
    * `:test_label_file` - Test set label filename.
      Defaults to `"test-labels-idx1-ubyte.gz"`
    * `:cache_dir` - Cache directory.
      Defaults to `System.tmp_dir!()`

  """
  def download(opts \\ []) do
    {download_images(:train, opts), download_labels(:train, opts)}
  end

  @doc """
  Downloads the Kuzushiji MNIST test dataset or fetches it locally.
  """
  def download_test(opts \\ []) do
    {download_images(:test, opts), download_labels(:test, opts)}
  end

  defp download_images(:train, opts) do
    download_images(opts[:train_image_file] || @train_image_file, opts)
  end

  defp download_images(:test, opts) do
    download_images(opts[:test_image_file] || @test_image_file, opts)
  end

  defp download_images(filename, opts) do
    base_url = opts[:base_url] || @base_url

    data = Utils.get!(base_url <> filename, opts).body
    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> = data
    {images, {:u, 8}, {n_images, 1, n_rows, n_cols}}
  end

  defp download_labels(:train, opts) do
    download_labels(opts[:train_label_file] || @train_label_file, opts)
  end

  defp download_labels(:test, opts) do
    download_labels(opts[:test_label_file] || @test_label_file, opts)
  end

  defp download_labels(filename, opts) do
    base_url = opts[:base_url] || @base_url

    data = Utils.get!(base_url <> filename, opts).body
    <<_::32, n_labels::32, labels::binary>> = data
    {labels, {:u, 8}, {n_labels}}
  end
end
