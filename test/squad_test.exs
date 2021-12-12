defmodule SquadTest do
  use ExUnit.Case

  @moduletag timeout: 120_000

  describe "download/0" do
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
  end

  describe "download_test/0" do
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

  describe "to_columns/1" do
    test "returns full map for each dataset" do
      train_map = Scidata.Squad.download() |> Scidata.Squad.to_columns()

      assert train_map |> Map.keys() |> Enum.sort() == [
               "answer_start",
               "answer_text",
               "context",
               "id",
               "question",
               "title"
             ]

      Enum.each(train_map, fn {_k, entries} ->
        assert length(entries) == 87599
      end)
    end
  end
end
