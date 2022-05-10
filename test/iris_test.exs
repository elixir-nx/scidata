defmodule IrisTest do
  use ExUnit.Case

  @moduletag timeout: 120_000

  describe "download" do
    test "retrieves training set" do
      {features, labels} = Scidata.Iris.download()

      assert length(labels) == 150
      assert length(features) == length(labels)

      assert labels |> Enum.uniq() |> Enum.sort() == [0, 1, 2]
      assert features |> Enum.map(&length(&1)) |> Enum.uniq() |> Enum.sort() == [4]
    end
  end
end
