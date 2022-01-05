defmodule Scidata.Caltech101 do
  @moduledoc """
  Module for downloading the [Caltech101 dataset](http://www.vision.caltech.edu/Image_Datasets/Caltech101).
  """

  require Scidata.Utils
  alias Scidata.Utils

  # NOTE: The original url on the website is "https://drive.google.com/u/0/uc?export=download&confirm=R4MY&id=137RyRjvTBkBiIfeYBNZBtViDHQ6_Ewsp".
  # However, I was unable to get around the redirection issue when downloading large files from GDrive.
  @base_url "https://s3.amazonaws.com/fast-ai-imageclas/caltech_101.tgz"
  @label_mapping %{
    accordion: 1,
    airplanes: 2,
    anchor: 3,
    ant: 4,
    background_google: 5,
    barrel: 6,
    bass: 7,
    beaver: 8,
    binocular: 9,
    bonsai: 10,
    brain: 11,
    brontosaurus: 12,
    buddha: 13,
    butterfly: 14,
    camera: 15,
    cannon: 16,
    car_side: 17,
    ceiling_fan: 18,
    cellphone: 19,
    chair: 20,
    chandelier: 21,
    cougar_body: 22,
    cougar_face: 23,
    crab: 24,
    crayfish: 25,
    crocodile: 26,
    crocodile_head: 27,
    cup: 28,
    dalmatian: 29,
    dollar_bill: 30,
    dolphin: 31,
    dragonfly: 32,
    electric_guitar: 33,
    elephant: 34,
    emu: 35,
    euphonium: 36,
    ewer: 37,
    faces: 38,
    faces_easy: 39,
    ferry: 40,
    flamingo: 41,
    flamingo_head: 42,
    garfield: 43,
    gerenuk: 44,
    gramophone: 45,
    grand_piano: 46,
    hawksbill: 47,
    headphone: 48,
    hedgehog: 49,
    helicopter: 50,
    ibis: 51,
    inline_skate: 52,
    joshua_tree: 53,
    kangaroo: 54,
    ketch: 55,
    lamp: 56,
    laptop: 57,
    leopards: 58,
    llama: 59,
    lobster: 60,
    lotus: 61,
    mandolin: 62,
    mayfly: 63,
    menorah: 64,
    metronome: 65,
    minaret: 66,
    motorbikes: 67,
    nautilus: 68,
    octopus: 69,
    okapi: 70,
    pagoda: 71,
    panda: 72,
    pigeon: 73,
    pizza: 74,
    platypus: 75,
    pyramid: 76,
    revolver: 77,
    rhino: 78,
    rooster: 79,
    saxophone: 80,
    schooner: 81,
    scissors: 82,
    scorpion: 83,
    sea_horse: 84,
    snoopy: 85,
    soccer_ball: 86,
    stapler: 87,
    starfish: 88,
    stegosaurus: 89,
    stop_sign: 90,
    strawberry: 91,
    sunflower: 92,
    tick: 93,
    trilobite: 94,
    umbrella: 95,
    watch: 96,
    water_lilly: 97,
    wheelchair: 98,
    wild_cat: 99,
    windsor_chair: 100,
    wrench: 101,
    yin_yang: 102
  }

  @labels_shape {9145, 1}

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

  defp parse_images(fname) do
    {:ok, mat} = fname |> List.to_string() |> OpenCV.imread()
    {:ok, {rows, cols, channels}} = OpenCV.Mat.shape(mat)
    {:ok, binary_data} = OpenCV.Mat.to_binary(mat)
    {binary_data, rows, cols, channels}
  end

  defp generate_records({fname, _image}) do
    label =
      fname
      |> List.to_string()
      |> String.split("/")
      |> Enum.at(1)
      |> String.downcase()
      |> String.to_atom()
      |> (&Map.get(@label_mapping, &1)).()

    {image, rows, cols, channels} = parse_images(fname)

    {image, label, {rows, cols, channels}}
  end

  defp download_dataset(_dataset_type) do
    files = Utils.get!(@base_url).body

    records =
      files
      |> Task.async_stream(&generate_records/1,
        max_concurrency: Application.get_env(:scidata, :max_concurrency)
      )
      |> Enum.to_list()

    images = Enum.map(records, fn {:ok, record} -> elem(record, 0) end)
    labels = Enum.map(records, fn {:ok, record} -> elem(record, 1) end)
    shapes = Enum.map(records, fn {:ok, record} -> elem(record, 2) end)

    {{images, {:u, 8}, shapes}, {labels, {:u, 8}, @labels_shape}}
  end
end
