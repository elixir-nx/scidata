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
      {{<<255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
          255, 255, 255, 231, 176, 237, 255, 255, 255, 255, 255, 252, 242, 229, 195,
          212, 182, 255, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254,
          254, 254, 254, ...>>, {:u, 8}, {50000, 3, 32, 32}},
       {<<11, 19, 15, 29, 4, 0, 14, 11, 1, 1, 5, 86, 18, 90, 3, 28, 10, 23, 11, 31, 5,
          39, 17, 96, 2, 82, 9, 17, 10, 71, 5, 39, 18, 8, 8, 97, 16, 80, 10, 71, 16,
          74, 17, 59, 2, 70, 5, ...>>, {:u, 8}, {50000, 2}}}

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

  @doc """
  Shows names of coarse and fine labels of the dataset.

  Label values returned by `download/1` correspond to indices in the lists
  returned here.

  ## Examples

      iex> {_, labels} = Scidata.CIFAR100.download()
      {{<<255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
          255, 255, 255, 231, 176, 237, 255, 255, 255, 255, 255, 252, 242, 229, 195,
          212, 182, 255, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254,
          254, 254, 254, ...>>, {:u, 8}, {50000, 3, 32, 32}},
      {<<11, 19, 15, 29, 4, 0, 14, 11, 1, 1, 5, 86, 18, 90, 3, 28, 10, 23, 11, 31, 5,
          39, 17, 96, 2, 82, 9, 17, 10, 71, 5, 39, 18, 8, 8, 97, 16, 80, 10, 71, 16,
          74, 17, 59, 2, 70, 5, ...>>, {:u, 8}, {50000, 2}}}
      iex> {coarse_class_names, fine_class_names} = Scidata.CIFAR100.labels_info()
      {["aquatic_mammals", "fish", "flowers", "food_containers",
        "fruit_and_vegetables", "household_electrical_devices", "household_furniture",
        "insects", "large_carnivores", "large_man-made_outdoor_things",
        "large_natural_outdoor_scenes", "large_omnivores_and_herbivores",
        "medium_mammals", "non-insect_invertebrates", "people", "reptiles",
        "small_mammals", "trees", "vehicles_1", "vehicles_2"],
      ["apple", "aquarium_fish", "baby", "bear", "beaver", "bed", "bee", "beetle",
        "bicycle", "bottle", "bowl", "boy", "bridge", "bus", "butterfly", "camel",
        "can", "castle", "caterpillar", "cattle", "chair", "chimpanzee", "clock",
        "cloud", "cockroach", "couch", "crab", "crocodile", "cup", "dinosaur",
        "dolphin", "elephant", "flatfish", "forest", "fox", "girl", "hamster",
        "house", "kangaroo", "keyboard", "lamp", "lawn_mower", "leopard", "lion",
        "lizard", "lobster", "man", "maple_tree", ...]}
      iex> {labels_bin, labels_type, labels_shape} = labels
      {<<11, 19, 15, 29, 4, 0, 14, 11, 1, 1, 5, 86, 18, 90, 3, 28, 10, 23, 11, 31, 5,
         39, 17, 96, 2, 82, 9, 17, 10, 71, 5, 39, 18, 8, 8, 97, 16, 80, 10, 71, 16,
         74, 17, 59, 2, 70, 5, 87, 17, ...>>, {:u, 8}, {50000, 2}}
      iex> labels_tensor = labels_bin |> Nx.from_binary(labels_type) |> Nx.reshape(labels_shape)
      #Nx.Tensor<
        u8[50000][2]
        [
          [11, 19],
          [15, 29],
          [4, 0],
          [14, 11],
          [1, 1],
          ...
        ]
      >
      iex> coarse_labels = labels_tensor |> Nx.slice([0,0], [50000, 1]) \
      |> Nx.reshape({50000}) |> Nx.to_flat_list() \
      |> Enum.map(fn label_index -> Enum.at(coarse, label_index) end)
      ["large_omnivores_and_herbivores", "reptiles", "fruit_and_vegetables", "people",
      "fish", "household_electrical_devices", "vehicles_1", "food_containers",
      "large_natural_outdoor_scenes", "large_omnivores_and_herbivores", ...]
      iex> fine_labels = labels_tensor |> Nx.slice([0,1], [50000, 1]) \
      |> Nx.reshape({50000}) |> Nx.to_flat_list \
      |> Enum.map(fn label_index -> Enum.at(fine, label_index) end)
      ["cattle", "dinosaur", "apple", "boy", "aquarium_fish", "telephone", "train",
      "cup", "cloud", "elephant", "keyboard", "willow_tree", "sunflower", "castle", ...]
      iex> Enum.zip(coarse_labels, fine_labels)
      [
        {"large_omnivores_and_herbivores", "cattle"},
        {"reptiles", "dinosaur"},
        {"fruit_and_vegetables", "apple"},
        {"people", "boy"},
        {"fish", "aquarium_fish"},
        {"household_electrical_devices", "telephone"},
        {"vehicles_1", "train"},
        ...
      ]

  """
  def labels_info() do
    files = Utils.get!(@base_url <> @dataset_file).body

    coarse_labels =
      files
      |> Enum.find(fn {fname, _} ->
        String.match?(List.to_string(fname), ~r/coarse_label_names/)
      end)
      |> elem(1)
      |> String.trim_trailing()
      |> String.split("\n")

    fine_labels =
      files
      |> Enum.find(fn {fname, _} ->
        String.match?(List.to_string(fname), ~r/fine_label_names/)
      end)
      |> elem(1)
      |> String.trim_trailing()
      |> String.split("\n")

    {coarse_labels, fine_labels}
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
