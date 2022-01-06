defmodule Scidata.Caltech101 do
  @moduledoc """
  Module for downloading the [Caltech101 dataset](http://www.vision.caltech.edu/Image_Datasets/Caltech101).
  """

  require Scidata.Utils
  alias Scidata.Utils

  # NOTE: The original url on the website is "https://drive.google.com/u/0/uc?export=download&confirm=R4MY&id=137RyRjvTBkBiIfeYBNZBtViDHQ6_Ewsp".
  # However, I was unable to get around the redirection issue when downloading large files from GDrive.
  @base_url "https://s3.amazonaws.com/fast-ai-imageclas/caltech_101.tgz"
  @labels_shape {9144, 1}

  @doc """
  Downloads the Caltech101 training dataset or fetches it locally.

  Returns a tuple of format:

      {{images_binary, images_type, images_shape},
       {labels_binary, labels_type, labels_shape}}

  If you want to one-hot encode the labels, you can:

      labels_binary
      |> Nx.from_binary(labels_type)
      |> Nx.new_axis(-1)
      |> Nx.equal(Nx.tensor(Enum.to_list(1..102)))

  """
  def download() do
    download_dataset(:train)
  end

  defp download_dataset(_dataset_type) do
    # Skip first file since it's a temporary file.
    [_ | files] = Utils.get!(@base_url).body

    {:ok, label_mapping} = get_mapping(:label)
    {:ok, image_mapping} = get_mapping(:image)

    records =
      files
      |> Task.async_stream(&generate_records(&1, label_mapping, image_mapping),
        max_concurrency: Application.get_env(:scidata, :max_concurrency)
      )
      |> Enum.to_list()

    images = Enum.map(records, fn {:ok, record} -> elem(record, 0) end)
    labels = Enum.map(records, fn {:ok, record} -> elem(record, 1) end)
    shapes = Enum.map(records, fn {:ok, record} -> elem(record, 2) end)

    {{images, {:u, 8}, shapes}, {labels, {:u, 8}, @labels_shape}}
  end

  defp get_mapping(:label) do
    fpath = Path.join([File.cwd!(), "lib/scidata/labels/caltech101_labels.json"])
    do_get_mapping(fpath)
  end

  defp get_mapping(:image) do
    fpath = Path.join([File.cwd!(), "lib/scidata/content/caltech101_image_shapes.json"])
    do_get_mapping(fpath)
  end

  defp do_get_mapping(fpath) do
    with {:ok, body} <- File.read(fpath),
         {:ok, mapping} <- Jason.decode(body),
         do: {:ok, mapping}
  end

  defp generate_records({fname, image}, label_mapping, image_mapping) do
    [_, class_name, image_fname] =
      fname
      |> List.to_string()
      |> String.downcase()
      |> String.split("/")

    label = Map.get(label_mapping, class_name)
    shape = image_mapping |> Map.get("#{label}/#{image_fname}") |> List.to_tuple()

    {image, label, shape}
  end
end
