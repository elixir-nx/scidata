defmodule YelpPolarityReviewsTest do
  use ExUnit.Case

  @moduletag timeout: 120_000

  describe "download" do
    test "retrieves training set" do
      %{review: train_inputs, sentiment: train_targets} = Scidata.YelpPolarityReviews.download()

      assert length(train_inputs) == 560_000
      assert length(train_targets) == 560_000
      assert train_targets |> Enum.uniq() |> Enum.sort() == [0, 1]
    end

    test "retrieves test set" do
      %{review: test_inputs, sentiment: test_targets} =
        Scidata.YelpPolarityReviews.download_test()

      assert length(test_inputs) == 38000
      assert length(test_targets) == 38000
      assert test_targets |> Enum.uniq() |> Enum.sort() == [0, 1]
    end
  end
end
