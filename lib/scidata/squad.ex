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

  def download() do
    download_dataset(@train_dataset_file)
  end

  @doc """
  Downloads the SQuAD test dataset

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

  def download_test() do
    download_dataset(@test_dataset_file)
  end

  defp download_dataset(dataset_name) do
    content =
      Utils.get!(@base_url <> dataset_name).body
      |> Jason.decode!()

    content["data"]
  end

  @doc """
  Converts the squad dataset to a tuple containing three maps.

  ## Examples

      iex> Scidata.Squad.to_maps(entries)
      {
        %{
          title: ["University_of_Notre_Dame", "Beyoncé", ...],
          title_id: [1, 2, ...]
        },
        %{
          context: ["Architecturally, the school has a C...", ...],
          context_id: [1, 2, ...],
          title_id: [1, 1, ...]
        },
        %{
          answer_start: [92, 381, ...],
          answer_text: ["a golden statue of...", "a Marian place...", ...],
          context_id: [1, 1, ...],
          question: ["What sits on top of the...", "What is the...", ...],
          question_id: ["5733be284776f4190066117e", "5733be284776f41900661181", ...]
        }
      }
  """

  def to_maps(results) do
    {titles, contexts, qas} =
      results
      |> Enum.reduce(
        {
          %{title: [], title_id: []},
          %{context: [], context_id: [], title_id: []},
          %{
            context_id: [],
            question_id: [],
            question: [],
            answer_text: [],
            answer_start: []
          }
        },
        &add_to_maps/2
      )

    {reverse_and_flatten(titles), reverse_and_flatten(contexts), reverse_and_flatten(qas)}
  end

  defp add_to_maps(%{"paragraphs" => paragraphs, "title" => title}, acc) do
    {title_acc, context_acc, qa_acc} = acc

    %{title: titles, title_id: title_ids} = title_acc

    next_title_id = length(titles) + 1

    next_titles = %{
      title_acc
      | title: [title | titles],
        title_id: [next_title_id | title_ids]
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
               context_id: foreign_context_ids,
               question: questions,
               question_id: question_ids,
               answer_start: answer_starts,
               answer_text: answer_texts
             } = curr_qa_acc
           } ->
          next_context_id = length(contexts) + 1

          next_questions = qas |> Enum.map(& &1["question"])
          next_question_ids = qas |> Enum.map(& &1["id"])

          answers = qas |> Enum.map(& &1["answers"])
          # Each answer is a singleton
          next_answer_starts = answers |> Enum.map(&hd(&1)["answer_start"])
          next_answer_texts = answers |> Enum.map(&hd(&1)["text"])

          next_context_acc = %{
            curr_context_acc
            | context: [context | contexts],
              context_id: [next_context_id | context_ids],
              title_id: [next_title_id | title_ids]
          }

          next_foreign_context_ids =
            Stream.repeatedly(fn -> next_context_id end)
            |> Enum.take(length(next_questions))

          next_qa_acc = %{
            curr_qa_acc
            | context_id: [next_foreign_context_ids | foreign_context_ids],
              question: [next_questions | questions],
              question_id: [next_question_ids | question_ids],
              answer_start: [next_answer_starts | answer_starts],
              answer_text: [next_answer_texts | answer_texts]
          }

          {next_context_acc, next_qa_acc}
        end
      )

    {next_titles, next_contexts, next_qas}
  end

  defp reverse_and_flatten(acc) do
    Enum.reduce(acc, %{}, fn {k, v}, acc -> Map.put(acc, k, :lists.reverse(List.flatten(v))) end)
  end
end
