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
  @label_mapping %{
    accordion: 0,
    airplanes: 1,
    anchor: 2,
    ant: 3,
    background_google: 4,
    barrel: 5,
    bass: 6,
    beaver: 7,
    binocular: 8,
    bonsai: 9,
    brain: 10,
    brontosaurus: 11,
    buddha: 12,
    butterfly: 13,
    camera: 14,
    cannon: 15,
    car_side: 16,
    ceiling_fan: 17,
    cellphone: 18,
    chair: 19,
    chandelier: 20,
    cougar_body: 21,
    cougar_face: 22,
    crab: 23,
    crayfish: 24,
    crocodile: 25,
    crocodile_head: 26,
    cup: 27,
    dalmatian: 28,
    dollar_bill: 29,
    dolphin: 30,
    dragonfly: 31,
    electric_guitar: 32,
    elephant: 33,
    emu: 34,
    euphonium: 35,
    ewer: 36,
    faces: 37,
    faces_easy: 38,
    ferry: 39,
    flamingo: 40,
    flamingo_head: 41,
    garfield: 42,
    gerenuk: 43,
    gramophone: 44,
    grand_piano: 45,
    hawksbill: 46,
    headphone: 47,
    hedgehog: 48,
    helicopter: 49,
    ibis: 50,
    inline_skate: 51,
    joshua_tree: 52,
    kangaroo: 53,
    ketch: 54,
    lamp: 55,
    laptop: 56,
    leopards: 57,
    llama: 58,
    lobster: 59,
    lotus: 60,
    mandolin: 61,
    mayfly: 62,
    menorah: 63,
    metronome: 64,
    minaret: 65,
    motorbikes: 66,
    nautilus: 67,
    octopus: 68,
    okapi: 69,
    pagoda: 70,
    panda: 71,
    pigeon: 72,
    pizza: 73,
    platypus: 74,
    pyramid: 75,
    revolver: 76,
    rhino: 77,
    rooster: 78,
    saxophone: 79,
    schooner: 80,
    scissors: 81,
    scorpion: 82,
    sea_horse: 83,
    snoopy: 84,
    soccer_ball: 85,
    stapler: 86,
    starfish: 87,
    stegosaurus: 88,
    stop_sign: 89,
    strawberry: 90,
    sunflower: 91,
    tick: 92,
    trilobite: 93,
    umbrella: 94,
    watch: 95,
    water_lilly: 96,
    wheelchair: 97,
    wild_cat: 98,
    windsor_chair: 99,
    wrench: 100,
    yin_yang: 101
  }

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
  def download(opts \\ []) do
    unless Code.ensure_loaded?(StbImage) do
      raise "StbImage is missing, please add `{:stb_image, \"~> 0.1\"}` as a dependency to your mix.exs"
    end
    download_dataset(:train, opts)
  end

  defp download_dataset(_dataset_type, opts) do
    # Skip first file since it's a temporary file.
    [_ | files] = Utils.get!(@base_url).body

    records =
      files
      |> Task.async_stream(&generate_records/1,
        max_concurrency: Keyword.get(opts, :max_concurrency, System.schedulers_online)
      )
      |> Enum.to_list()

    images = Enum.map(records, fn {:ok, record} -> elem(record, 0) end)
    labels = Enum.map(records, fn {:ok, record} -> elem(record, 1) end)
    shapes = Enum.map(records, fn {:ok, record} -> elem(record, 2) end)

    {{images, {:u, 8}, shapes}, {IO.iodata_to_binary(labels), {:u, 8}, @labels_shape}}
  end

  defp generate_records({fname, image}) do
    class_name =
      fname
      |> List.to_string()
      |> String.downcase()
      |> String.split("/")
      |> Enum.at(1)
      |> String.to_atom()

    label = Map.fetch!(@label_mapping, class_name)
    {:ok, image_bin, image_shape, _img_type} = StbImage.from_memory(image)

    {image_bin, label, image_shape}
  end
end
