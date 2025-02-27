defmodule KindleExtractor.Dictionary do

  alias KindleExtractor.Tree

  def load_dictionary(dictionary) do
    folder_path = "dictionaries/" <> dictionary

    case list_files(folder_path) do
      {:ok, files} ->
        file_count = Enum.reduce(files, 0, fn file, acc ->
          case File.stat(Path.join(folder_path, file)) do
            {:ok, _info} -> acc + 1
            _ -> acc
          end
        end)

        full_dict =
          1..file_count
            |> Enum.reduce([], fn n, acc ->
              bank = "term_bank_#{n}.json"
              case load_term_bank(folder_path, bank) do
                [] -> acc
                {:error, :enoent} -> acc
                json -> [json | acc]
              end
            end)
            |> Enum.concat()

        {:ok, full_dict}
      {:error} -> {:error, "Invalid dict name or not found"}
    end
  end

  defp load_term_bank(path, bank) do
    with {:ok, body} <- File.read(path <> "/" <> bank),
         {:ok, json} <- Jason.decode(body), do: json
  end

  # only works with japanese dictionaries (JMdict...)
  # todo: work with english too
  def load_tree(json) do
      Enum.reduce(json, nil, fn elem, _ ->
        [word, reading, _, _, _, definition | _] = elem
        Tree.insert(word, reading, definition)
      end)

    :ok
  end

  def search(tree, word) do
    case Tree.search(tree, word) do
      word -> word
    end
  end

  defp list_files(path) do
    case File.ls(path) do
      {:ok, files} -> {:ok, files}
      {:error, _reason} -> {:error}
    end
  end
end
