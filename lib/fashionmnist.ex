defmodule Scidata.FashionMNIST do
  require Scidata.Utils
  alias Scidata.Utils

  @default_data_path "tmp/fashionmnist"
  @base_url 'http://fashion-mnist.s3-website.eu-central-1.amazonaws.com/'
  @train_image_file 'train-images-idx3-ubyte.gz'
  @train_label_file 'train-labels-idx1-ubyte.gz'
  @test_image_file 't10k-images-idx3-ubyte.gz'
  @test_label_file 't10k-labels-idx1-ubyte.gz'

  defp download_images(image_file, data_path, transform) do
    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> =
      Utils.unzip_cache_or_download(@base_url, image_file, data_path)

    transform.({images, {:u, 8}, {n_images, n_rows, n_cols}})
  end

  defp download_labels(label_file, data_path, transform) do
    <<_::32, n_labels::32, labels::binary>> =
      Utils.unzip_cache_or_download(@base_url, label_file, data_path)

    transform.({labels, {:u, 8}, {n_labels}})
  end

  @doc """
  Downloads the FashionMNIST training dataset or fetches it locally.

  ## Options

    * `:datapath` - path where the dataset .gz should be stored locally
    * `:transform_images` - accepts accept a tuple like
      `{binary_data, tensor_type, data_shape}` which can be used for
      converting the `binary_data` to a tensor with a function like

          fn {labels_binary, type, _shape} ->
            labels_binary
            |> Nx.from_binary(type)
            |> Nx.new_axis(-1)
            |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))
            |> Nx.to_batched_list(32)
          end

  * `:transform_labels` - similar to `:transform_images` but applied to
      dataset labels

  * `:test_set` - indicate whether the training set or the test set
      should be fetched

  ## Examples

      iex> Scidata.FashionMNIST.download()
      {{<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...>>,
        {:u, 8}, {60000, 28, 28}},
      {<<9, 0, 0, 3, 0, 2, 7, 2, 5, 5, 0, 9, 5, 5, 7, 9, 1, 0, 6, 4, 3, 1, 4, 8, 4,
          3, 0, 2, 4, 4, 5, 3, 6, 6, 0, 8, 5, 2, 1, 6, 6, 7, 9, 5, 9, 2, 7, ...>>,
        {:u, 8}, {60000}}}

  """
  def download(opts \\ []) do
    {data_path, transform_images, transform_labels} = Utils.get_download_args(opts)

    {download_images(@train_image_file, data_path, transform_images),
     download_labels(@train_label_file, data_path, transform_labels)}
  end

  @doc """
  Downloads the FashionMNIST test dataset or fetches it locally.

  Accepts the same options as `download/1`.
  """
  def download_test(opts \\ []) do
    {data_path, transform_images, transform_labels} = Utils.get_download_args(opts)

    {download_images(@test_image_file, data_path, transform_images),
     download_labels(@test_label_file, data_path, transform_labels)}
  end
end
