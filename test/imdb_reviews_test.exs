defmodule IMDBReviewsTest do
  use ExUnit.Case

  describe "download" do
    test "retrieves training set" do
      {train_inputs, train_targets} = Scidata.IMDBReviews.download([:pos, :neg, :unsup])
      assert length(train_inputs) == 75000
      assert length(train_targets) == 75000
    end

    test "retrieves test set" do
      {test_inputs, test_targets} = Scidata.IMDBReviews.download_test([:pos, :neg])
      assert length(test_inputs) == 25000
      assert length(test_targets) == 25000
    end
  end
end
