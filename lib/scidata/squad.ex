defmodule Scidata.Squad do
  @moduledoc """
  Module for downloading the [SQuAD1.1 dataset](https://rajpurkar.github.io/SQuAD-explorer).
  """

  require Scidata.Utils
  alias Scidata.Utils

  @base_url "https://rajpurkar.github.io/SQuAD-explorer/dataset/"
  @train_dataset_file "train-v1.1.json"
  @test_dataset_file "dev-v1.1.json"

  @doc """
  Downloads the SQuAD training dataset

  ## Options.

    * `:base_url` - Dataset base URL.
      Defaults to `"https://rajpurkar.github.io/SQuAD-explorer/dataset/"`
    * `:train_dataset_file` - Training set filename.
      Defaults to `"train-v1.1.json"`
    * `:cache_dir` - Cache directory.
      Defaults to `System.tmp_dir!()`

  ## Examples

      iex> Scidata.Squad.download()
      [
        %{
          "paragraphs" => [
            %{
              "context" => "Architecturally, the school has a...",
              "qas" => [
                %{
                  "answers" => [%{"answer_start" => 515, "text" => "Saint Bernadette Soubirous"}],
                  "id" => "5733be284776f41900661182",
                  "question" => "To whom did the..."
                }, ...
              ]
            }
          ],
          "title" => "University_of_Notre_Dame"
        }, ...
      ]
  """

  def download(opts \\ []) do
    download_dataset(opts[:train_dataset_file] || @train_dataset_file, opts)
  end

  @doc """
  Downloads the SQuAD test dataset

  ## Options.

    * `:base_url` - Dataset base URL.
      Defaults to `"https://rajpurkar.github.io/SQuAD-explorer/dataset/"`
    * `:test_dataset_file` - Test set filename.
      Defaults to `"dev-v1.1.json"`
    * `:cache_dir` - Cache directory.
      Defaults to `System.tmp_dir!()`

  ## Examples

      iex> Scidata.Squad.download_test()
      [
        %{
          "paragraphs" => [
            %{
              "context" => "Super Bowl 50 was an American football game t...",
              "qas" => [
                %{
                  "answers" => [
                    %{"answer_start" => 177, "text" => "Denver Broncos"},...
                  ],
                  "id" => "56be4db0acb8001400a502ec",
                  "question" => "Which NFL team represented the AFC at Super Bowl 50?"
                },
              ]
            }
          ],
          "title" => "Super_Bowl_50"
        }, ...
      ]
  """

  def download_test(opts \\ []) do
    download_dataset(opts[:test_dataset_file] || @test_dataset_file, opts)
  end

  defp download_dataset(dataset_name, opts) do
    base_url = opts[:base_url] || @base_url

    content =
      Utils.get!(base_url <> dataset_name, opts).body
      |> Jason.decode!()

    content["data"]
  end

  @doc """
  Convert result of `download/0` or `download_test/0` to map for use with [Explorer.DataFrame](https://github.com/elixir-nx/explorer).

  ## Examples

      iex> columns_for_df = Scidata.Squad.download() |> Scidata.Squad.to_columns()
      %{
        "answer_start" => [515, ...],
        "context" => ["Architecturally, the...", ...],
        "id" => ["5733be284776f41900661182", ...],
        "question" => ["To whom did the Vir...", ...],
        "answer_text" => ["Saint Bernadette Soubirous", ...],
        "title" => ["University_of_Notre_Dame", ...]
      }
      iex> Explorer.DataFrame.from_map(columns_for_df)
      #Explorer.DataFrame<
      [rows: 87599, columns: 6]
      ...
      >
  """

  def to_columns(entries) do
    table = %{
      "answer_start" => [],
      "context" => [],
      "id" => [],
      "question" => [],
      "answer_text" => [],
      "title" => []
    }

    for %{"paragraphs" => paragraph, "title" => title} <- entries,
        %{"context" => context, "qas" => qas} <- paragraph,
        %{"id" => id, "question" => question, "answers" => answers} <- qas,
        %{"answer_start" => answer_start, "text" => answer_text} <- answers,
        reduce: table do
      %{
        "answer_start" => answer_starts,
        "context" => contexts,
        "id" => ids,
        "question" => questions,
        "answer_text" => answer_texts,
        "title" => titles
      } ->
        %{
          "answer_start" => [answer_start | answer_starts],
          "context" => [context | contexts],
          "id" => [id | ids],
          "question" => [question | questions],
          "answer_text" => [answer_text | answer_texts],
          "title" => [title | titles]
        }
    end
    |> Enum.map(fn {key, values} -> {key, :lists.reverse(values)} end)
    |> Enum.into(%{})
  end
end
