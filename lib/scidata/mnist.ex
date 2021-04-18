defmodule Scidata.MNIST do
  alias Scidata.Utils

  @base_url "https://storage.googleapis.com/cvdf-datasets/mnist/"
  @train_image_file "train-images-idx3-ubyte.gz"
  @train_label_file "train-labels-idx1-ubyte.gz"
  @test_image_file "t10k-images-idx3-ubyte.gz"
  @test_label_file "t10k-labels-idx1-ubyte.gz"

  defp download_images(image_file, transform) do
    data = Utils.get!(@base_url <> image_file).body
    <<_::32, n_images::32, n_rows::32, n_cols::32, images::binary>> = data

    transform.({images, {:u, 8}, {n_images, n_rows, n_cols}})
  end

  defp download_labels(label_file, transform) do
    data = Utils.get!(@base_url <> label_file).body
    <<_::32, n_labels::32, labels::binary>> = data

    transform.({labels, {:u, 8}, {n_labels}})
  end

  @doc """
  Downloads the MNIST training dataset or fetches it locally.

  ## Options

    * `:datapath` - path where the dataset .gz should be stored locally

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

  """
  def download(opts \\ []) do
    transform_images = opts[:transform_images] || (& &1)
    transform_labels = opts[:transform_labels] || (& &1)

    {download_images(@train_image_file, transform_images),
     download_labels(@train_label_file, transform_labels)}
  end

  @doc """
  Downloads the MNIST test dataset or fetches it locally.

  Accepts the same options as `download/1`.
  """
  def download_test(opts \\ []) do
    transform_images = opts[:transform_images] || (& &1)
    transform_labels = opts[:transform_labels] || (& &1)

    {download_images(@test_image_file, transform_images),
     download_labels(@test_label_file, transform_labels)}
  end
end
