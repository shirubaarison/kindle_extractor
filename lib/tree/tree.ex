defmodule KindleExtractor.Tree do
  alias KindleExtractor.Tree
  alias KindleExtractor.Meaning

  defstruct value: nil, left: nil, right: nil, reading: nil, definition: nil

  def insert(nil, value, reading, definition) do
    %Tree{value: value, reading: reading, definition: definition}
  end

  def insert(%Tree{value: root_value, left: left, right: right} = node, value, reading, definition) do
    cond do
      value < root_value -> %Tree{node | left: insert(left, value, reading, definition)}
      value > root_value -> %Tree{node | right: insert(right, value, reading, definition)}
      true -> node
    end
  end

  def search(nil, _value), do: {:error, "Word not found"}
  def search(%Tree{value: root_value, left: left, right: right,
              reading: reading, definition: definition}, value) do
    cond do
      value < root_value -> search(left, value)
      value > root_value -> search(right, value)
      true -> %Meaning{reading: reading, definition: definition}
    end
  end
end
