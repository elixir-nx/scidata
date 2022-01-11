defmodule IMDBReviewsTest do
  use ExUnit.Case

  @moduletag timeout: 120_000

  describe "download" do
    test "retrieves training set" do
      %{review: train_inputs, sentiment: train_targets} = Scidata.IMDBReviews.download()

      assert length(train_inputs) == 25000
      assert length(train_targets) == 25000

      %{review: train_inputs, sentiment: train_targets} =
        Scidata.IMDBReviews.download(example_types: [:pos, :neg])

      assert length(train_inputs) == 25000
      assert length(train_targets) == 25000

      %{review: train_inputs, sentiment: train_targets} =
        Scidata.IMDBReviews.download(example_types: [:pos, :neg, :unsup])

      assert length(train_inputs) == 75000
      assert length(train_targets) == 75000
    end

    test "retrieves test set" do
      %{review: test_inputs, sentiment: test_targets} =
        Scidata.IMDBReviews.download_test(example_types: [:pos, :neg])

      assert length(test_inputs) == 25000
      assert length(test_targets) == 25000
      assert [0, 0, 0, 0, 0] = Enum.take(test_targets, -5)
    end

    test "utilizes transform opts" do
      clip = fn inputs -> Enum.map(inputs, &String.slice(&1, 0..20)) end

      %{review: reviews, sentiment: targets} =
        Scidata.IMDBReviews.download(example_types: [:pos], transform_inputs: clip)

      assert Enum.take(reviews, 10) == [
               "The story centers aro",
               "'The Adventures Of Ba",
               "This film and it's se",
               "I love this movie lik",
               "A hit at the time but",
               "Very smart, sometimes",
               "With the mixed review",
               "This movie really kic",
               "I'd always wanted Dav",
               "Like I said its a hid"
             ]

      assert Enum.take(targets, 10) == [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    end
  end
end
