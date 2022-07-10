defmodule CIFAR10 do
  use ExUnit.Case

  @moduletag timeout: 120_000

  describe "download" do
    test "retrieves training set" do
      {{_images, {:u, 8}, {n_images, n_channels, n_rows, n_cols}}, {_labels, {:u, 8}, {n_labels}}} =
        Scidata.CIFAR10.download()

      assert n_images == 50000
      assert n_channels == 3
      assert n_rows == 32
      assert n_cols == 32
      assert n_labels == 50000
    end

    test "retrieves test set" do
      {{_images, {:u, 8}, {n_images, n_channels, n_rows, n_cols}}, {_labels, {:u, 8}, {n_labels}}} =
        Scidata.CIFAR10.download_test()

      assert n_images == 10000
      assert n_channels == 3
      assert n_rows == 32
      assert n_cols == 32
      assert n_labels == 10000
    end
  end
end
