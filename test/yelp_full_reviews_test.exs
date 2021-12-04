defmodule YelpFullReviewsTest do
  use ExUnit.Case

  @moduletag timeout: 120_000

  describe "download" do
    test "retrieves training set" do
      %{review: train_inputs, rating: train_targets} = Scidata.YelpFullReviews.download()

      assert length(train_inputs) == 650_000
      assert length(train_targets) == 650_000
      assert train_targets |> Enum.uniq() |> Enum.sort() == [1, 2, 3, 4, 5]
    end

    test "retrieves test set" do
      %{review: test_inputs, rating: test_targets} = Scidata.YelpFullReviews.download_test()

      assert length(test_inputs) == 50000
      assert length(test_targets) == 50000
      assert test_targets |> Enum.uniq() |> Enum.sort() == [1, 2, 3, 4, 5]
    end
  end
end
