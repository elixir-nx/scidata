defmodule Scidata.Iris do
  @moduledoc """
  Module for downloading the [Iris Data Set](https://archive.ics.uci.edu/dataset/53/iris).
  """

  @base_url "https://archive.ics.uci.edu/static/public/53/iris.zip"
  @dataset_file "iris.data"

  alias Scidata.Utils

  @doc """
  Downloads the Iris dataset or fetches it locally.

  ## Information about the dataset are available in file `iris.names` inside the
     [zip file](https://archive.ics.uci.edu/static/public/53/iris.zip).

  ### Attribute

    1. sepal length in cm
    2. sepal width in cm
    3. petal length in cm
    4. petal width in cm

  ### Label

    * 0: Iris Setosa
    * 1: Iris Versicolour
    * 2: Iris Virginica

  ## Options.

    * `:base_url` - Dataset base URL.

      Defaults to `"https://archive.ics.uci.edu/static/public/53/iris.zip"`

    * `:dataset_file` - Dataset filename.

      Defaults to `"iris.data"`

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

    data
    |> String.split()
    |> Enum.reverse()
    |> Enum.reduce({[], []}, fn row_str, {feature_acc, label_acc} ->
      row = String.split(row_str, ",")
      {features, [label]} = Enum.split(row, 4)

      features =
        Enum.map(features, fn val ->
          {val, ""} = Float.parse(val)
          val
        end)

      label = get_label(label)
      {[features | feature_acc], [label | label_acc]}
    end)
  end

  defp get_label(label) do
    cond do
      label =~ "Iris-setosa" -> 0
      label =~ "Iris-versicolor" -> 1
      label =~ "Iris-virginica" -> 2
    end
  end
end
