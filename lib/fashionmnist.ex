defmodule Scidata.FashionMNIST do
  alias Scidata.Utils

  @default_data_path "tmp/fashionmnist"
  @base_url 'http://fashion-mnist.s3-website.eu-central-1.amazonaws.com/'
  @train_image_file 'train-images-idx3-ubyte.gz'
  @train_label_file 'train-labels-idx1-ubyte.gz'
  @test_image_file 't10k-images-idx3-ubyte.gz'
  @test_label_file 't10k-labels-idx1-ubyte.gz'

  defp download_images(opts) do
    data_path = opts[:data_path] || @default_data_path
    transform = opts[:transform_images] || fn out -> out end
    image_file = if(opts[:test_set], do: @test_image_file, else: @train_image_file)

    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> =
      Utils.unzip_cache_or_download(@base_url, image_file, data_path)

    transform.({images, {:u, 8}, {n_images, n_rows, n_cols}})
  end

  defp download_labels(opts) do
    data_path = opts[:data_path] || @default_data_path
    transform = opts[:transform_labels] || fn out -> out end
    label_file = if(opts[:test_set], do: @test_label_file, else: @train_label_file)

    <<_::32, n_labels::32, labels::binary>> =
      Utils.unzip_cache_or_download(@base_url, label_file, data_path)

    transform.({labels, {:u, 8}, {n_labels}})
  end

  @doc """
  Downloads the FashionMNIST dataset or fetches it locally.
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
  * `test_set` - indicate whether the training set or the test set
        should be fetched

  Examples:
    iex> Scidata.FashionMNIST.download()
    Fetching train-images-idx3-ubyte.gz from http://fashion-mnist.s3-website.eu-central-1.amazonaws.com/

    Fetching train-labels-idx1-ubyte.gz from http://fashion-mnist.s3-website.eu-central-1.amazonaws.com/

    {{<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...>>,
      {:u, 8}, {60000, 28, 28}},
    {<<9, 0, 0, 3, 0, 2, 7, 2, 5, 5, 0, 9, 5, 5, 7, 9, 1, 0, 6, 4, 3, 1, 4, 8, 4,
        3, 0, 2, 4, 4, 5, 3, 6, 6, 0, 8, 5, 2, 1, 6, 6, 7, 9, 5, 9, 2, 7, ...>>,
      {:u, 8}, {60000}}}

    iex> transform_labels = fn {labels_binary, type, _shape} ->
    iex>             labels_binary
    iex>             |> Nx.from_binary(type)
    iex>             |> Nx.new_axis(-1)
    iex>             |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))
    iex>             |> Nx.to_batched_list(32)
    iex>         end
    #Function<7.126501267/1 in :erl_eval.expr/5>
    iex> Scidata.FashionMNIST.download(transform_labels: transform_labels)
    Using train-images-idx3-ubyte.gz from tmp/fashionmnist

    Using train-labels-idx1-ubyte.gz from tmp/fashionmnist

    {{<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...>>,
    {:u, 8}, {60000, 28, 28}}, #Nx.Tensor<
    u8[60000][10]
    [
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
      [1, 0, 0, 0, 0, 0, 0, 0, ...],
      ...
    ]
    >}
  """
  def download(opts \\ []),
    do: {download_images(opts), download_labels(opts)}
end
