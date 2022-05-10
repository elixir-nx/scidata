defmodule Scidata.Wine do
  @moduledoc """
  Module for downloading the [Wine Data Set](https://archive.ics.uci.edu/ml/datasets/wine).
  """

  @base_url "https://archive.ics.uci.edu/ml/machine-learning-databases/wine/"
  @dataset_file "wine.data"

  alias Scidata.Utils

  @doc """
  Downloads the Wine dataset or fetches it locally.

  ## Information ([source](https://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.names))

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

      Defaults to `"https://archive.ics.uci.edu/ml/machine-learning-databases/wine/"`

    * `:dataset_file` - Dataset filename.

      Defaults to `"wine.data"`

    * `:cache_dir` - Cache directory.

      Defaults to `System.tmp_dir!()`

  """
  def download(opts \\ []) do
    base_url = opts[:base_url] || @base_url
    dataset_file = opts[:dataset_file] || @dataset_file

    label_attr =
      Utils.get!(base_url <> dataset_file, opts).body
      |> String.split()
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn row ->
          [label | val_list] = row
          {label, ""} = Integer.parse(label)
          val_list =
            Enum.map(val_list, fn val ->
              {val, ""} =
                case val do
                  "." <> _other ->
                    Float.parse("0" <> val)

                  _ ->
                    Float.parse(val)
                end
              val
            end)
          [label - 1 | val_list]
      end)
    labels = Enum.map(label_attr, &hd(&1))
    attributes = Enum.map(label_attr, &tl(&1))
    {attributes, labels}
  end
end
