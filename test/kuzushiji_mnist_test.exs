defmodule KuzushijiMNISTTest do
  use ExUnit.Case

  @moduletag timeout: 120_000

  describe "download" do
    test "retrieves training set" do
      {{_images, {:u, 8}, {n_images, 1, n_rows, n_cols}}, {_labels, {:u, 8}, {n_labels}}} =
        Scidata.KMNIST.download()

      assert n_images == 60000
      assert n_rows == 28
      assert n_cols == 28
      assert n_labels == 60000
    end

    test "retrieves test set" do
      {{_images, {:u, 8}, {n_images, 1, n_rows, n_cols}}, {_labels, {:u, 8}, {n_labels}}} =
        Scidata.KMNIST.download_test()

      assert n_images == 10000
      assert n_rows == 28
      assert n_cols == 28
      assert n_labels == 10000
    end
  end
end
