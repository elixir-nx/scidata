defmodule Scidata.FashionMNIST do
  @moduledoc """
  Module for downloading the [FashionMNIST dataset](https://github.com/zalandoresearch/fashion-mnist#readme).
  """

  require Scidata.Utils
  alias Scidata.Utils

  @base_url "http://fashion-mnist.s3-website.eu-central-1.amazonaws.com/"
  @train_image_file "train-images-idx3-ubyte.gz"
  @train_label_file "train-labels-idx1-ubyte.gz"
  @test_image_file "t10k-images-idx3-ubyte.gz"
  @test_label_file "t10k-labels-idx1-ubyte.gz"

  @doc """
  Downloads the FashionMNIST training dataset or fetches it locally.

  Returns a tuple of format:

      {{images_binary, images_type, images_shape},
       {labels_binary, labels_type, labels_shape}}

  If you want to one-hot encode the labels, you can:

      labels_binary
      |> Nx.from_binary(labels_type)
      |> Nx.new_axis(-1)
      |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))

  ## Options.

    * `:base_url` - optional. Dataset base URL.
      Defaults to `"http://fashion-mnist.s3-website.eu-central-1.amazonaws.com/"`
    * `:train_image_file` - optional. Training set image filename.
      Defaults to `"train-images-idx3-ubyte.gz"`
    * `:train_label_file` - optional. Training set label filename.
      Defaults to `"train-images-idx1-ubyte.gz"`
    * `:test_image_file` - optional. Test set image filename.
      Defaults to `"test-images-idx3-ubyte.gz"`
    * `:test_label_file` - optional. Test set label filename.
      Defaults to `"test-labels-idx1-ubyte.gz"`
    * `:cache_dir` - optional. Cache directory.
      Defaults to `System.tmp_dir!()`

  ## Examples

      iex> Scidata.FashionMNIST.download()
      {{<<105, 109, 97, 103, 101, 115, 45, 105, 100, 120, 51, 45, 117, 98, 121, 116,
          101, 0, 236, 253, 7, 88, 84, 201, 215, 232, 11, 23, 152, 38, 57, 51, 166,
          81, 71, 157, 209, 49, 135, 49, 141, 99, 206, 142, 57, 141, 89, 68, ...>>,
        {:u, 8}, {3739854681, 226418, 1634299437}},
       {<<0, 3, 116, 114, 97, 105, 110, 45, 108, 97, 98, 101, 108, 115, 45, 105, 100,
          120, 49, 45, 117, 98, 121, 116, 101, 0, 53, 221, 9, 130, 36, 73, 110, 100,
          81, 219, 220, 150, 91, 214, 249, 251, 20, 141, 247, 53, 114, ...>>, {:u, 8},
        {3739854681}}}

  """
  def download(opts \\ []) do
    {download_images(:train, opts), download_labels(:train, opts)}
  end

  @doc """
  Downloads the FashionMNIST test dataset or fetches it locally.
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
