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
  @label_descriptions ~w(t_shirt/top trouser pullover dress coat sandal shirt
                         sneaker bag ankle_boot)

  @doc """
  Downloads the FashionMNIST training dataset or fetches it locally.

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
    transform_images = opts[:transform_images] || (& &1)
    transform_labels = opts[:transform_labels] || (& &1)

    {download_images(@train_image_file, transform_images),
     download_labels(@train_label_file, transform_labels)}
  end

  @doc """
  Downloads the FashionMNIST test dataset or fetches it locally.

  Accepts the same options as `download/1`.
  """
  def download_test(opts \\ []) do
    transform_images = opts[:transform_images] || (& &1)
    transform_labels = opts[:transform_labels] || (& &1)

    {download_images(@test_image_file, transform_images),
     download_labels(@test_label_file, transform_labels)}
  end

  @doc """
  Shows descriptions of dataset labels.

  ## Examples
      iex> transform_labels = fn {b, t, _} -> b |> Nx.from_binary(t) end
      iex> {_, labels} = Scidata.FashionMNIST.download(transform_labels: transform_labels)
      {{<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...>>,
        {:u, 8}, {60000, 28, 28}}, #Nx.Tensor<
         u8[60000]
         [9, 0, 0, 3, 0, 2, 7, 2, 5, 5, 0, 9, 5, 5, 7, 9, 1, 0, 6, 4, 3, 1, 4, 8, 4, 3, 0, 2,
          4, 4, 5, 3, 6, 6, 0, 8, 5, 2, 1, 6, 6, 7, 9, 5, 9, 2, 7, 3, ...]
      >}
      iex> label_names = Scidata.FashionMNIST.labels_info()
      ["t_shirt/top", "trouser", "pullover", "dress", "coat", "sandal", "shirt",
       "sneaker", "bag", "ankle_boot"]
      iex> labels |> Nx.to_flat_list() |> Enum.map(fn label_index -> Enum.at(label_names, label_index) end)
      ["ankle_boot", "t_shirt/top", "t_shirt/top", "dress", "t_shirt/top", "pullover",
       "sneaker", "pullover", "sandal", "sandal", "t_shirt/top", "ankle_boot", ...]
  """
  def labels_info(), do: @label_descriptions

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
end
