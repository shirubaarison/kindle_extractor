defmodule KindleExtractor.Dictionary do

  alias KindleExtractor.Tree

  def load_dictionary(dictionary) do
    1..28
    |> Enum.reduce([], fn n, acc ->
      bank = "term_bank_#{n}.json"
      case load_term_bank(dictionary, bank) do
        [] -> acc
        json -> [json | acc]
      end
    end)
    |> Enum.concat()
  end

  defp load_term_bank(dictionary, bank) do
    with {:ok, body} <- File.read("dictionaries/" <> dictionary <> "/" <> bank),
         {:ok, json} <- Jason.decode(body), do: json
  end

  def load_tree(json) do
    Enum.reduce(json, nil, fn elem, tree ->
      [word, reading, _, _, _, definition | _] = elem
      Tree.insert(tree, word, reading, definition)
    end)
  end

  def search(tree, word) do
    case Tree.search(tree, word) do
      word -> word
    end
  end
end
