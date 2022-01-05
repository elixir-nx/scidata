defmodule Caltech101Test do
  use ExUnit.Case

  @moduletag timeout: 120_000

  describe "download" do
    test "retrieves training set" do
      {{_images, {:u, 8}, shapes}, {labels, {:u, 8}, labels_shape}} =
        Scidata.Caltech101.download()

      assert length(labels) == elem(labels_shape, 0)
      assert length(shapes) == elem(labels_shape, 0)
      assert labels |> Enum.uniq() |> length() == 102
    end
  end
end
