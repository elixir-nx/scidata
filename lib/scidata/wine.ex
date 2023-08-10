defmodule Scidata.Wine do
  @moduledoc """
  Module for downloading the [Wine Data Set](https://archive.ics.uci.edu/dataset/109/wine).
  """

  @base_url "https://archive.ics.uci.edu/static/public/109/wine.zip"
  @dataset_file "wine.data"

  alias Scidata.Utils

  @doc """
  Downloads the Wine dataset or fetches it locally.

  ## Information about the dataset are available in file `iris.names` inside the
     [zip file](https://archive.ics.uci.edu/static/public/109/wine.zip).

  ### Attribute

    1.  Alcohol
    2.  Malic acid
    3.  Ash
    4.  Alcalinity of ash
    5.  Magnesium
    6.  Total phenols
    7.  Flavanoids
    8.  Nonflavanoid phenols
    9.  Proanthocyanins
    10. Color intensity
    11. Hue
    12. OD280/OD315 of diluted wines
    13. Proline

  ### Label

    * 0
    * 1
    * 2

  ## Options.

    * `:base_url` - Dataset base URL.

      Defaults to `"https://archive.ics.uci.edu/static/public/109/wine.zip"`

    * `:dataset_file` - Dataset filename.

      Defaults to `"wine.data"`

    * `:cache_dir` - Cache directory.

      Defaults to `System.tmp_dir!()`

  """
  def download(opts \\ []) do
    base_url = opts[:base_url] || @base_url
    dataset_file = opts[:dataset_file] || @dataset_file

    # Temporary fix to cope with bad cert on source site
    opts = Keyword.put(opts, :ssl_verify, :verify_none)

    [{_, data}] =
      Utils.get!(base_url, opts).body
      |> Enum.filter(fn {fname, _} ->
        String.match?(
          List.to_string(fname),
          ~r/#{dataset_file}/
        )
      end)

    label_attr =
      data
      |> String.split()
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn row ->
        [label | val_list] = row
        label = String.to_integer(label)

        val_list =
          Enum.map(val_list, fn val ->
            {val, ""} = Float.parse("0" <> val)
            val
          end)

        [label - 1 | val_list]
      end)

    labels = Enum.map(label_attr, &hd(&1))
    attributes = Enum.map(label_attr, &tl(&1))
    {attributes, labels}
  end
end
