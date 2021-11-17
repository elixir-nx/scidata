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
  Downloads the SQuAD dataset.

  ## Examples

      iex> Scidata.Squad.download()
      %{
        [
          %{
            "paragraphs" => [
              %{
                "context" => "In many cities along the North American...",
                "qas" => [
                  %{
                    "answers" => [%{"answer_start" => 324, "text" => "hundreds"}],
                    "id" => "56d8a0ddbfea0914004b7706",
                    "question" => "How many people protested on the San Francisco torch route?"
                  },
                  ...
                ]
              }
              ...
            ]
          }
        ]
      }
  """

  def download() do
    download_dataset(@train_dataset_file)
  end

  def download_test() do
    download_dataset(@test_dataset_file)
  end

  defp download_dataset(dataset_name) do
    content =
      Utils.get!(@base_url <> dataset_name).body
      |> Jason.decode!()

    content["data"]
  end

  def flatten(results) do
    results
    |> Enum.reduce(
      %{id: [], title: [], context: [], question: [], answer: []},
      &process_example/2
    )
  end

  def process_example(%{"paragraphs" => paragraphs, "title" => title}, acc) do
    paragraphs
    |> Enum.reduce(acc, fn %{"context" => context, "qas" => qas},
                           %{
                             id: ids,
                             title: titles,
                             context: contexts,
                             question: questions,
                             answer: answers
                           } ->
      next_questions = qas |> Enum.map(& &1["question"])

      next_answers =
        qas |> Enum.map(&(&1["answers"] |> Utils.map_list_to_table(["answer_start", "text"])))

      next_ids = qas |> Enum.map(& &1["id"])

      next_contexts = Stream.repeatedly(fn -> context end) |> Enum.take(length(next_questions))
      next_titles = Stream.repeatedly(fn -> title end) |> Enum.take(length(next_questions))

      %{
        id: [next_ids | ids],
        title: [next_titles | titles],
        context: [next_contexts | contexts],
        question: [next_questions | questions],
        answer: [next_answers | answers]
      }
    end)
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, :lists.reverse(List.flatten(v))) end)
  end

  def get_join_tables(results) do
    results
    |> Enum.reduce(
      {
        %{title: [], title_id: []},
        %{context: [], context_id: [], title_id: []},
        %{
          context_id: [],
          question_id: [],
          question: [],
          answer: []
        }
      },
      &to_tables/2
    )
  end

  defp to_tables(%{"paragraphs" => paragraphs, "title" => title}, acc) do
    {title_acc, context_acc, qa_acc} = acc

    %{title: titles, title_id: title_ids} = title_acc

    next_title_id = length(titles) + 1

    next_titles = %{
      title_acc
      | title: titles ++ [title],
        title_id: title_ids ++ [next_title_id]
    }

    {next_contexts, next_qas} =
      paragraphs
      |> Enum.reduce(
        {context_acc, qa_acc},
        fn %{"context" => context, "qas" => qas},
           {
             %{
               context: contexts,
               context_id: context_ids,
               title_id: title_ids
             } = curr_context_acc,
             %{
               answer: answers,
               context_id: foreign_context_ids,
               question: questions,
               question_id: question_ids
             } = curr_qa_acc
           } ->
          next_context_id = length(contexts) + 1

          next_questions = qas |> Enum.map(& &1["question"])
          next_answers = qas |> Enum.map(& &1["answers"])
          next_ids = qas |> Enum.map(& &1["id"])

          next_context_acc = %{
            curr_context_acc
            | context: contexts ++ [context],
              context_id: context_ids ++ [next_context_id],
              title_id: title_ids ++ [next_title_id]
          }

          next_qa_acc = %{
            curr_qa_acc
            | answer: answers ++ next_answers,
              context_id:
                foreign_context_ids ++
                  (Stream.repeatedly(fn -> next_context_id end)
                   |> Enum.take(length(next_questions))),
              question: questions ++ next_questions,
              question_id: question_ids ++ next_ids
          }

          {next_context_acc, next_qa_acc}
        end
      )

    {next_titles, next_contexts, next_qas}
  end
end
