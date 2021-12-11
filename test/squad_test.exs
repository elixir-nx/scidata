defmodule SquadTest do
  use ExUnit.Case

  @moduletag timeout: 120_000

  describe "download" do
    test "retrieves training set" do
      examples = Scidata.Squad.download()

      assert length(examples) == 442

      first_example = hd(examples)
      last_example = List.last(examples)

      assert first_example["title"] == "University_of_Notre_Dame"
      assert length(first_example["paragraphs"]) == 55

      assert last_example["title"] == "Kathmandu"
      assert length(last_example["paragraphs"]) == 58
    end

    test "retrieves test set" do
      examples = Scidata.Squad.download_test()

      assert length(examples) == 48

      first_example = hd(examples)
      last_example = List.last(examples)

      assert first_example["title"] == "Super_Bowl_50"
      assert length(first_example["paragraphs"]) == 54

      assert last_example["title"] == "Force"
      assert length(last_example["paragraphs"]) == 44
    end
  end
end
